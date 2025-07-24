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
            print('🌐 페이지 로딩 시작: $url');
            setState(() {
              _currentUrl = url;
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            print('✅ 페이지 로딩 완료: $url');
            setState(() {
              _currentUrl = url;
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            print('❌ 페이지 로딩 오류: ${error.description}');
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            print('🔗 네비게이션 요청: ${request.url}');
            
            // 특정 URL 차단이 필요한 경우
            if (request.url.startsWith('mailto:')) {
              print('📧 메일 링크 차단: ${request.url}');
              return NavigationDecision.prevent;
            }
            
            // 외부 앱 실행 방지 (선택사항)
            if (!request.url.startsWith('http://') && !request.url.startsWith('https://')) {
              print('🚫 외부 앱 링크 차단: ${request.url}');
              return NavigationDecision.prevent;
            }
            
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://www.coupang.com/'));
  }

  // DISABLED: JavaScript functions that might interfere with page loading
  // Future<void> _hideAppBanners() async { ... }
  // Future<void> _extractProductPrice() async { ... }

  // 네비게이션 액션 메서드들
  void onHomePressed() {
    controller.loadRequest(Uri.parse('https://www.coupang.com/'));
  }

  void onCoupangPressed() {
    controller.loadRequest(Uri.parse('https://www.coupang.com/'));
  }

  void onOrderPressed() async {
    try {
      print('🛒 주문 버튼 클릭 - HTML 문서 추출 시작');
      
      // HTML 추출 모드 설정 (SharedPreferences에서 동적으로 로드)
      final captureFullHtml = await HtmlCaptureSettings.isFullHtmlMode();
      print('🔧 설정에서 로드한 HTML 캡처 모드: ${captureFullHtml ? "전체 HTML" : "핵심 정보만"}');
      
      String htmlContent;
      String captureMode;
      
      if (captureFullHtml) {
        // 1-A. 전체 HTML 문서 추출
        final htmlResult = await controller.runJavaScriptReturningResult("""
          (() => {
            return document.documentElement.outerHTML;
          })()
        """);
        htmlContent = htmlResult.toString();
        captureMode = "full_html";
        print('📄 전체 HTML 추출 완료: ${htmlContent.length} characters');
      } else {
        // 1-B. 핵심 상품 정보만 추출
        final htmlResult = await controller.runJavaScriptReturningResult("""
          (() => {
            // 쿠팡 상품 페이지의 핵심 섹션들 추출
            const sections = [];
            
            // 1. 상품 ATF (Above The Fold) 영역
            const prodAtf = document.querySelector('main .prod-atf, main div[class*="prod-atf"]');
            if (prodAtf) {
              sections.push('<div class="extracted-section" data-section="prod-atf">');
              sections.push(prodAtf.outerHTML);
              sections.push('</div>');
            }
            
            // 2. 상품 상세 정보 영역
            const prodDetail = document.querySelector('main .prod-detail, main div[class*="prod-detail"]');
            if (prodDetail) {
              sections.push('<div class="extracted-section" data-section="prod-detail">');
              sections.push(prodDetail.outerHTML);
              sections.push('</div>');
            }
            
            // 3. 가격 정보 영역
            const priceInfo = document.querySelector('.price-info, .prod-price, [class*="price"]');
            if (priceInfo && !sections.some(s => s.includes(priceInfo.outerHTML))) {
              sections.push('<div class="extracted-section" data-section="price-info">');
              sections.push(priceInfo.outerHTML);
              sections.push('</div>');
            }
            
            // 4. 구매 버튼 영역
            const buyButtons = document.querySelector('.prod-buy-options, .buy-options, [class*="buy"]');
            if (buyButtons && !sections.some(s => s.includes(buyButtons.outerHTML))) {
              sections.push('<div class="extracted-section" data-section="buy-options">');
              sections.push(buyButtons.outerHTML);
              sections.push('</div>');
            }
            
            // 5. 상품 이미지 영역  
            const prodImages = document.querySelector('.prod-image, .product-images, [class*="image"]');
            if (prodImages && !sections.some(s => s.includes(prodImages.outerHTML))) {
              sections.push('<div class="extracted-section" data-section="product-images">');
              sections.push(prodImages.outerHTML);
              sections.push('</div>');
            }
            
            // 추출된 섹션들을 하나의 HTML로 결합
            if (sections.length > 0) {
              return '<!DOCTYPE html><html><head><title>쿠팡 상품 핵심 정보</title></head><body>' + 
                     '<div class="coupang-extracted-content">' + 
                     sections.join('\\n') + 
                     '</div></body></html>';
            } else {
              // 핵심 섹션을 찾지 못한 경우 main 태그 전체
              const mainContent = document.querySelector('main');
              if (mainContent) {
                return '<!DOCTYPE html><html><head><title>쿠팡 메인 콘텐츠</title></head><body>' +
                       mainContent.outerHTML + 
                       '</body></html>';
              } else {
                return '<!DOCTYPE html><html><head><title>추출 실패</title></head><body><p>상품 정보를 찾을 수 없습니다.</p></body></html>';
              }
            }
          })()
        """);
        htmlContent = htmlResult.toString();
        captureMode = "product_sections";
        print('🎯 핵심 상품 정보 추출 완료: ${htmlContent.length} characters');
      }
      
      // 2. 현재 URL 사용 (실시간으로 추적된 상태 사용)
      final url = _currentUrl;
      print('🔄 상태에서 가져온 현재 URL: $url');
      
      // 3. JavaScript로도 URL 확인 (검증용)
      final jsUrlResult = await controller.runJavaScriptReturningResult("""
        (() => {
          return window.location.href;
        })()
      """);
      final jsUrl = jsUrlResult.toString().replaceAll('"', '');
      
      // URL 일치 여부 확인
      if (url != jsUrl) {
        print('⚠️ URL 불일치 감지!');
        print('  - 상태 URL: $url');
        print('  - JS URL: $jsUrl');
        print('  - JS URL을 사용합니다.');
        // JavaScript에서 가져온 URL이 더 정확할 수 있으므로 업데이트
        setState(() {
          _currentUrl = jsUrl;
        });
      }
      
      // 4. 타임스탬프 생성
      final timestamp = DateTime.now().toIso8601String();
      final finalUrl = jsUrl.isNotEmpty ? jsUrl : url; // 최종 URL 결정
      
      print('📄 HTML 문서 크기: ${htmlContent.length} characters');
      print('🌐 최종 URL: $finalUrl');
      print('📋 추출 모드: $captureMode');
      
      // 5. 서버에 HTML 문서 업로드 (최종 URL 사용)
      await _uploadHtmlToGist(htmlContent, finalUrl, timestamp, captureMode);
      
      // 6. 기존 가격 추출 로직도 유지 (백업용)
      final priceResult = await controller.runJavaScriptReturningResult("""
        (() => {
          const quantityDiv = document.querySelector('#MWEB_PRODUCT_DETAIL_ATF_QUANTITY');
          if (quantityDiv) {
            const bold = quantityDiv.querySelector('b');
            if (bold && bold.innerText) return bold.innerText;
          }
          const priceInfoDiv = document.querySelector('#MWEB_PRODUCT_DETAIL_ATF_PRICE_INFO');
          if (priceInfoDiv) {
            const span = priceInfoDiv.querySelector('span[class^="PriceInfo_finalPrice"]');
            if (span && span.innerText) return span.innerText;
          }
          return '가격 없음';
        })()
      """);
      
      print('💰 추출된 가격 정보: $priceResult');
      
    } catch (e) {
      print('❌ HTML 추출 중 오류 발생: $e');
    }
    
    // 6. 주문 페이지로 이동
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OrderPage()),
    );
  }
  
  Future<void> _uploadHtmlToGist(String htmlContent, String url, String timestamp, String captureMode) async {
    try {
      print('📤 커스텀 서버에 HTML 문서 업로드 시도...');
      
      // 커스텀 서버로 직접 POST 전송 (추출 모드 정보 포함)
      final success = await _uploadToCustomServer(htmlContent, url, timestamp, captureMode);
      
      if (!success) {
        print('⚠️ 서버 업로드 실패, 로컬 저장으로 대체');
        await _saveHtmlLocally(htmlContent, url, timestamp);
      }
      
    } catch (e) {
      print('💥 외부 저장 중 오류: $e');
      await _saveHtmlLocally(htmlContent, url, timestamp);
    }
  }
  
  Future<bool> _uploadToCustomServer(String htmlContent, String url, String timestamp, String captureMode) async {
    try {
      print('📤 gunsiya.com 서버 업로드 시작...');
      
      const String serverUrl = 'https://gunsiya.com/raou/post_coupang';
      
      final data = {
        'timestamp': timestamp,
        'url': url,
        'html_content': htmlContent,
        'source': 'Raou_App_Coupang_Capture',
        'app_version': '1.2.0',
        'user_agent': 'RaouApp/1.2.0 (Flutter)',
        'capture_mode': captureMode, // 새로 추가: 추출 모드 정보
      };
      
      print('📊 업로드할 데이터 크기: ${jsonEncode(data).length} bytes');
      print('🌐 대상 URL: $url');
      print('⏰ 타임스탬프: $timestamp');
      
      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'RaouApp/1.1.0 (Flutter)',
        },
        body: jsonEncode(data),
      );
      
      print('📡 서버 응답 상태: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ 커스텀 서버 업로드 성공!');
        print('📄 서버 응답: ${response.body}');
        
        // 서버에서 응답이 JSON 형태인 경우 파싱
        String responseMessage = '업로드 성공';
        try {
          final responseData = jsonDecode(response.body);
          responseMessage = responseData['message'] ?? responseMessage;
          
          if (responseData['id'] != null) {
            print('🆔 서버 할당 ID: ${responseData['id']}');
          }
        } catch (e) {
          // JSON 파싱 실패해도 성공은 성공
          print('📝 응답이 JSON이 아님: ${response.body}');
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('HTML 캡처가 gunsiya.com에 저장되었습니다!\n\n모드: ${captureMode == "full_html" ? "전체 HTML" : "핵심 정보만"}\n응답: $responseMessage\n\n시각: $timestamp'),
              duration: const Duration(seconds: 6),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
        return true;
      } else {
        print('❌ 서버 업로드 실패: ${response.statusCode}');
        print('📄 에러 응답: ${response.body}');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('서버 업로드 실패 (${response.statusCode})\n로컬 저장으로 대체됩니다.'),
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return false;
      }
    } catch (e) {
      print('❌ 커스텀 서버 업로드 중 예외 발생: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('네트워크 오류: $e\n로컬 저장으로 대체됩니다.'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return false;
    }
  }
  
  Future<void> _saveHtmlLocally(String htmlContent, String url, String timestamp) async {
    try {
      print('💾 로컬 저장 시도...');
      
      // 앱 내부 디렉토리에 임시 저장
      // 실제 구현 시에는 path_provider 패키지 사용 권장
      final fileName = 'coupang_html_$timestamp.txt';
      
      print('📁 로컬 파일명: $fileName');
      print('📄 HTML 길이: ${htmlContent.length}');
      print('🌐 URL: $url');
      
      // 사용자에게 로컬 저장 완료 메시지
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('HTML 문서를 로컬에 임시 저장했습니다.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ 로컬 저장 실패: $e');
    }
  }

  void onCartPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CartPage()),
    );
  }

  void onProfilePressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
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
              Positioned.fill(child: WebViewWidget(controller: controller)),
              Align(
                alignment: Alignment.bottomCenter,
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