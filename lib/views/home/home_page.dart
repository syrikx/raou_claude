import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import '../../utils/html_capture_settings.dart';
import '../../viewmodels/cart_view_model.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../widgets/raou_navigation_bar.dart';
import '../../shared/utils/ui_helper.dart';
import '../../shared/utils/app_logger.dart';
import '../../shared/utils/app_validator.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/utils/datetime_helper.dart';
import '../cart/cart_page.dart';
import '../order/order_page.dart';
import '../auth/profile_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late WebViewController controller;
  String _currentUrl = 'https://www.coupang.com/'; // 현재 URL 상태
  bool _isLoading = false; // 페이지 로딩 상태
  String _lastCapturedHtml = ''; // 마지막으로 캐치한 HTML (중복 방지용)
  Timer? _changeDetectionTimer; // 주기적 변화 감지 타이머
  
  @override
  void initState() {
    super.initState();
    _initializeWebViewController();
  }

  void _initializeWebViewController() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // URL 변화 감지 설정
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            AppLogger.network('페이지 로딩 시작', url: url);
            setState(() {
              _currentUrl = url;
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            AppLogger.network('페이지 로딩 완료', url: url);
            setState(() {
              _currentUrl = url;
              _isLoading = false;
            });
            
            // 페이지 로딩 완료 후 초기 HTML 캐치 및 변화 감지 시작
            _captureInitialState(url);
            _startChangeDetection();
          },
          onWebResourceError: (WebResourceError error) {
            AppLogger.error('페이지 로딩 오류', error: error.description, tag: 'WebView');
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            AppLogger.network('네비게이션 요청', url: request.url);
            
            // 특정 URL 차단이 필요한 경우
            if (request.url.startsWith('mailto:')) {
              AppLogger.warning('메일 링크 차단', tag: 'Navigation');
              return NavigationDecision.prevent;
            }
            
            // 외부 앱 실행 방지 (선택사항)
            if (!request.url.startsWith('http://') && !request.url.startsWith('https://')) {
              AppLogger.warning('외부 앱 링크 차단: ${request.url}', tag: 'Navigation');
              return NavigationDecision.prevent;
            }
            
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(AppConstants.coupangBaseUrl));
  }

  // DISABLED: JavaScript functions that might interfere with page loading
  // Future<void> _hideAppBanners() async { ... }
  // Future<void> _extractProductPrice() async { ... }

  // ============================================================================
  // 자동 변화 감지 시스템
  // ============================================================================
  
  /// 페이지 로딩 완료 후 초기 상태 캐치
  Future<void> _captureInitialState(String url) async {
    try {
      await Future.delayed(const Duration(seconds: 2)); // 페이지 안정화 대기
      
      if (!AppValidator.isCoupangUrl(url)) {
        AppLogger.info('쿠팡 페이지가 아니므로 초기 상태 캐치 건너뜀');
        return;
      }
      
      await _captureCurrentState('page_loaded');
    } catch (e) {
      AppLogger.error('초기 상태 캐치 실패', error: e.toString());
    }
  }
  
  /// 주기적 변화 감지 시작
  void _startChangeDetection() {
    _stopChangeDetection(); // 기존 타이머 정리
    
    _changeDetectionTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        if (!mounted || _isLoading) return;
        
        if (AppValidator.isCoupangUrl(_currentUrl)) {
          await _detectAndCaptureChanges();
        }
      } catch (e) {
        AppLogger.error('변화 감지 중 오류', error: e.toString());
      }
    });
    
    AppLogger.info('자동 변화 감지 시작 (3초 간격)');
  }
  
  /// 변화 감지 중단
  void _stopChangeDetection() {
    if (_changeDetectionTimer?.isActive == true) {
      _changeDetectionTimer?.cancel();
      AppLogger.info('자동 변화 감지 중단');
    }
  }
  
  /// 변화 감지 및 캐치
  Future<void> _detectAndCaptureChanges() async {
    try {
      // 현재 DOM의 핵심 부분 해시값 계산
      final currentHash = await controller.runJavaScriptReturningResult("""
        (() => {
          // 쿠팡 페이지의 주요 변화 포인트들을 체크
          const checkPoints = [];
          
          // 1. URL 변화
          checkPoints.push(window.location.href);
          
          // 2. 상품 가격 영역
          const priceElements = document.querySelectorAll('[class*="price"], [class*="Price"]');
          priceElements.forEach(el => checkPoints.push(el.textContent?.trim() || ''));
          
          // 3. 상품 옵션 선택 영역
          const optionElements = document.querySelectorAll('[class*="option"], [class*="Option"], select, input[type="radio"]:checked');
          optionElements.forEach(el => {
            if (el.tagName === 'SELECT') {
              checkPoints.push(el.value);
            } else if (el.type === 'radio') {
              checkPoints.push(el.value + ':checked');
            } else {
              checkPoints.push(el.textContent?.trim() || el.value || '');
            }
          });
          
          // 4. 수량 선택
          const quantityElements = document.querySelectorAll('[class*="quantity"], [class*="Quantity"], input[type="number"]');
          quantityElements.forEach(el => checkPoints.push(el.value || ''));
          
          // 5. 팝업/모달 상태
          const popupElements = document.querySelectorAll('[class*="popup"], [class*="modal"], [class*="overlay"]');
          checkPoints.push(popupElements.length.toString());
          popupElements.forEach(el => {
            if (el.style.display !== 'none' && el.offsetParent !== null) {
              checkPoints.push(el.className + ':visible');
            }
          });
          
          // 6. 장바구니 버튼 상태
          const cartButtons = document.querySelectorAll('[class*="cart"], [class*="Cart"], button[onclick*="cart"]');
          cartButtons.forEach(el => checkPoints.push(el.textContent?.trim() || ''));
          
          // 체크포인트들을 문자열로 결합하여 간단한 해시 생성
          const combined = checkPoints.join('|');
          let hash = 0;
          for (let i = 0; i < combined.length; i++) {
            const char = combined.charCodeAt(i);
            hash = ((hash << 5) - hash) + char;
            hash = hash & hash; // 32bit 정수로 변환
          }
          
          return {
            hash: hash.toString(),
            checkPoints: checkPoints.slice(0, 10), // 디버깅용으로 처음 10개만
            url: window.location.href,
            timestamp: new Date().toISOString()
          };
        })()
      """);
      
      final hashData = jsonDecode(currentHash.toString());
      final currentHashString = hashData['hash'] as String;
      
      // 해시값이 변경되었을 때만 상세 캐치 수행
      if (currentHashString != _lastCapturedHtml) {
        AppLogger.data('페이지 변화 감지', operation: 'change_detected', value: {
          'old_hash': _lastCapturedHtml.isEmpty ? 'initial' : _lastCapturedHtml,
          'new_hash': currentHashString,
          'url': hashData['url'],
          'checkpoints': hashData['checkPoints']
        });
        
        _lastCapturedHtml = currentHashString;
        await _captureCurrentState('content_changed');
      }
    } catch (e) {
      AppLogger.error('변화 감지 실패', error: e.toString());
    }
  }
  
  /// 현재 상태를 캐치하여 서버로 전송
  Future<void> _captureCurrentState(String trigger) async {
    try {
      AppLogger.data('상태 캐치 시작', operation: 'state_capture', value: trigger);
      
      // 현재 설정에 따른 HTML 추출
      final captureFullHtml = await HtmlCaptureSettings.isFullHtmlMode();
      String htmlContent;
      String captureMode;
      
      if (captureFullHtml) {
        // 전체 HTML 추출
        final htmlResult = await controller.runJavaScriptReturningResult("""
          (() => {
            return document.documentElement.outerHTML;
          })()
        """);
        htmlContent = htmlResult.toString();
        captureMode = AppConstants.captureModeFull;
      } else {
        // 핵심 정보만 추출 (기존 로직 사용)
        final htmlResult = await controller.runJavaScriptReturningResult("""
          (() => {
            // 핵심 섹션들 추출
            const sections = [];
            
            // 상품 정보 섹션들
            const selectors = [
              'main .prod-atf, main div[class*="prod-atf"]',
              'main .prod-detail, main div[class*="prod-detail"]', 
              '.price-info, .prod-price, [class*="price"], [class*="Price"]',
              '.prod-buy-options, .buy-options, [class*="buy"]',
              '.prod-image, .product-images, [class*="image"]',
              '[class*="option"], [class*="Option"]', // 옵션 선택 영역
              '[class*="quantity"], [class*="Quantity"]', // 수량 선택 영역
              '[class*="popup"], [class*="modal"], [class*="overlay"]' // 팝업/모달
            ];
            
            selectors.forEach((selector, index) => {
              const elements = document.querySelectorAll(selector);
              elements.forEach(el => {
                if (el && !sections.some(s => s.includes(el.outerHTML))) {
                  sections.push('<div class="extracted-section" data-section="section-' + index + '">');
                  sections.push(el.outerHTML);
                  sections.push('</div>');
                }
              });
            });
            
            if (sections.length > 0) {
              return '<!DOCTYPE html><html><head><title>쿠팡 상태 캐치 - ' + new Date().toISOString() + '</title></head><body>' + 
                     '<div class="coupang-captured-content" data-trigger="' + '$trigger' + '">' + 
                     sections.join('\\n') + 
                     '</div></body></html>';
            } else {
              const mainContent = document.querySelector('main');
              return mainContent ? 
                '<!DOCTYPE html><html><head><title>쿠팡 메인 콘텐츠</title></head><body>' + mainContent.outerHTML + '</body></html>' :
                '<!DOCTYPE html><html><head><title>추출 실패</title></head><body><p>콘텐츠를 찾을 수 없습니다.</p></body></html>';
            }
          })()
        """);
        htmlContent = htmlResult.toString();
        captureMode = AppConstants.captureModeProduct;
      }
      
      // 추가 상세 정보 수집
      final pageDetails = await controller.runJavaScriptReturningResult("""
        (() => {
          return {
            url: window.location.href,
            title: document.title,
            timestamp: new Date().toISOString(),
            trigger: '$trigger',
            // 선택된 옵션들
            selectedOptions: Array.from(document.querySelectorAll('select, input[type="radio"]:checked, input[type="checkbox"]:checked')).map(el => ({
              name: el.name || el.id || 'unknown',
              value: el.value,
              text: el.textContent?.trim() || el.value
            })),
            // 현재 수량
            quantity: document.querySelector('input[type="number"]')?.value || '1',
            // 팝업 상태
            popupVisible: document.querySelectorAll('[class*="popup"], [class*="modal"]').length > 0
          };
        })()
      """);
      
      final details = jsonDecode(pageDetails.toString());
      final timestamp = DateTimeHelper.format(DateTime.now());
      
      // 서버로 전송
      await _uploadStateToGist(htmlContent, details, timestamp, captureMode, trigger);
      
    } catch (e) {
      AppLogger.error('상태 캐치 실패', error: e.toString());
    }
  }
  
  /// 상태 정보를 서버로 업로드
  Future<void> _uploadStateToGist(String htmlContent, Map<String, dynamic> details, String timestamp, String captureMode, String trigger) async {
    try {
      const String serverUrl = AppConstants.postCoupangEndpoint;
      
      final data = {
        'timestamp': timestamp,
        'url': details['url'],
        'html_content': htmlContent,
        'source': 'Raou_App_Auto_Capture',
        'app_version': '1.3.2',
        'user_agent': 'RaouApp/1.3.2 (Flutter)',
        'capture_mode': captureMode,
        'trigger': trigger, // 캐치 트리거 (page_loaded, content_changed, manual)
        'page_details': {
          'title': details['title'],
          'selected_options': details['selectedOptions'],
          'quantity': details['quantity'],
          'popup_visible': details['popupVisible'],
          'capture_time': details['timestamp'],
        }
      };
      
      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'RaouApp/1.3.2 (Flutter Auto-Capture)',
          'X-Capture-Trigger': trigger,
        },
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.network('자동 상태 캐치 업로드 성공', method: 'POST', statusCode: response.statusCode);
        
        if (mounted && trigger == 'manual') {
          UIHelper.showSuccessSnack(
            '페이지 상태가 자동으로 저장되었습니다!\\n트리거: $trigger\\n시각: $timestamp',
            context: context,
            seconds: 3,
          );
        }
      } else {
        AppLogger.warning('자동 상태 캐치 업로드 실패', tag: 'AUTO_CAPTURE');
      }
    } catch (e) {
      AppLogger.error('자동 상태 캐치 업로드 오류', error: e.toString());
    }
  }


  void onOrderPressed() async {
    try {
      AppLogger.userAction('주문 버튼 클릭', params: {'action': 'manual_capture_start'});
      
      // URL 검증
      if (!AppValidator.isCoupangUrl(_currentUrl)) {
        AppLogger.warning('쿠팡 URL이 아님', tag: 'HTML_CAPTURE');
        UIHelper.showWarningSnack('쿠팡 페이지에서만 HTML 캡처가 가능합니다.', context: context);
        return;
      }
      
      // 수동 캐치 수행 (새로운 자동 시스템 사용)
      await _captureCurrentState('manual');
      
      AppLogger.userAction('수동 캐치 완료', params: {'trigger': 'manual', 'url': _currentUrl});
      
    } catch (e) {
      AppLogger.error('수동 HTML 캐치 중 오류 발생', error: e.toString());
      UIHelper.showErrorSnack('HTML 캐치 중 오류가 발생했습니다.', context: context);
    }
    
    // 주문 페이지로 이동
    UIHelper.navigateTo(const OrderPage(), context: context);
  }

  @override
  void dispose() {
    _stopChangeDetection(); // 변화 감지 타이머 정리
    super.dispose();
  }

  // ============================================================================
  // 네비게이션 액션 메서드들
  // ============================================================================

  void onHomePressed() {
    AppLogger.userAction('홈 버튼 클릭');
    controller.loadRequest(Uri.parse(AppConstants.coupangBaseUrl));
  }

  void onCoupangPressed() {
    AppLogger.userAction('쿠팡 버튼 클릭');
    controller.loadRequest(Uri.parse(AppConstants.coupangBaseUrl));
  }

  void onCartPressed() {
    UIHelper.navigateTo(const CartPage(), context: context);
  }

  void onProfilePressed() {
    UIHelper.navigateTo(const ProfilePage(), context: context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          if (await controller.canGoBack()) {
            controller.goBack();
            return false;
          }
          return true;
        },
        child: Scaffold(
          body: Stack(
            children: [
              // WebView는 전체 영역 사용 (쿠팡 주문 버튼을 가리기 위해)
              Positioned.fill(child: WebViewWidget(controller: controller)),
              // 네비게이션 바가 WebView를 덮도록 배치
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Consumer<CartViewModel>(
                  builder: (context, cartViewModel, child) {
                    return RaouNavigationBar(
                      onHomePressed: onHomePressed,
                      onCoupangPressed: onCoupangPressed,
                      onOrderPressed: onOrderPressed,
                      onCartPressed: onCartPressed,
                      onProfilePressed: onProfilePressed,
                      cartItemCount: cartViewModel.itemCount,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}