import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
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
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setUserAgent('Mozilla/5.0 (Linux; Android 10; SM-G973F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // 로딩 진행률 처리 가능
          },
          onPageStarted: (String url) {
            // 페이지 로딩 시작
          },
          onPageFinished: (String url) {
            _hideAppBanners();
            _extractProductPrice();
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView 오류: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains('coupang://') ||
                request.url.contains('itunes.apple.com') ||
                request.url.contains('apps.apple.com')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://raou.kr/'));
  }

  Future<void> _hideAppBanners() async {
    await controller.runJavaScript('''
      // 앱 다운로드 배너 숨기기
      var appBanners = document.querySelectorAll('[class*="app"], [class*="banner"], [id*="app"], [id*="banner"]');
      appBanners.forEach(function(banner) {
        if (banner.textContent.includes('앱') || banner.textContent.includes('App') || banner.textContent.includes('다운로드')) {
          banner.style.display = 'none';
        }
      });
    ''');
  }
  
  Future<void> _extractProductPrice() async {
    try {
      final cartViewModel = context.read<CartViewModel>();
      
      final result = await controller.runJavaScriptReturningResult('''
        (function() {
          var priceElement = document.querySelector('.total-price');
          return priceElement ? priceElement.textContent : null;
        })()
      ''');
      
      if (result != null && result.toString() != 'null') {
        String price = result.toString().replaceAll('"', '');
        print('추출된 가격: $price');
      }
    } catch (e) {
      print('가격 추출 오류: $e');
    }
  }

  // 네비게이션 액션 메서드들
  void onHomePressed() {
    controller.loadRequest(Uri.parse('https://raou.kr/'));
  }

  void onCoupangPressed() {
    controller.loadRequest(Uri.parse('https://www.coupang.com/'));
  }

  void onOrderPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OrderPage()),
    );
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