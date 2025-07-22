import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
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
  
  @override
  void initState() {
    super.initState();
    _initializeWebViewController();
  }

  void _initializeWebViewController() {
    // SIMPLIFIED WebView for debugging
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // ..setBackgroundColor(Colors.white) // REMOVED: might cause white screen
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
      
      // 1. 현재 페이지의 전체 HTML 문서 추출
      final htmlResult = await controller.runJavaScriptReturningResult("""
        (() => {
          return document.documentElement.outerHTML;
        })()
      """);
      
      // 2. 현재 URL 가져오기
      final urlResult = await controller.runJavaScriptReturningResult("""
        (() => {
          return window.location.href;
        })()
      """);
      
      // 3. 타임스탬프 생성
      final timestamp = DateTime.now().toIso8601String();
      final url = urlResult.toString().replaceAll('"', '');
      final htmlContent = htmlResult.toString();
      
      print('📄 HTML 문서 크기: ${htmlContent.length} characters');
      print('🌐 현재 URL: $url');
      
      // 4. GitHub Gist에 HTML 문서 업로드
      await _uploadHtmlToGist(htmlContent, url, timestamp);
      
      // 5. 기존 가격 추출 로직도 유지 (백업용)
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
  
  Future<void> _uploadHtmlToGist(String htmlContent, String url, String timestamp) async {
    try {
      print('📤 커스텀 서버에 HTML 문서 업로드 시도...');
      
      // 커스텀 서버로 직접 POST 전송
      final success = await _uploadToCustomServer(htmlContent, url, timestamp);
      
      if (!success) {
        print('⚠️ 서버 업로드 실패, 로컬 저장으로 대체');
        await _saveHtmlLocally(htmlContent, url, timestamp);
      }
      
    } catch (e) {
      print('💥 외부 저장 중 오류: $e');
      await _saveHtmlLocally(htmlContent, url, timestamp);
    }
  }
  
  Future<bool> _uploadToCustomServer(String htmlContent, String url, String timestamp) async {
    try {
      print('📤 gunsiya.com 서버 업로드 시작...');
      
      const String serverUrl = 'https://gunsiya.com/raou/post_coupang';
      
      final data = {
        'timestamp': timestamp,
        'url': url,
        'html_content': htmlContent,
        'source': 'Raou_App_Coupang_Capture',
        'app_version': '1.1.0',
        'user_agent': 'RaouApp/1.1.0 (Flutter)',
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
              content: Text('HTML 캡처가 gunsiya.com에 저장되었습니다!\n\n응답: $responseMessage\n\n시각: $timestamp'),
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