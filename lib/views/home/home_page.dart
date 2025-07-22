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
    final result = await controller.runJavaScriptReturningResult("""
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