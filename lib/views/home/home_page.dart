import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../viewmodels/cart_view_model.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../models/user.dart';
import '../cart/cart_page.dart';
import '../order/order_page.dart';
import '../auth/profile_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 1; // 기본적으로 Coupang 탭 선택
  late WebViewController _webViewController;
  
  @override
  void initState() {
    super.initState();
    _initializeWebViewController();
  }

  void _initializeWebViewController() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setUserAgent('Mozilla/5.0 (Linux; Android 10; SM-G973F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // 로딩 진행률 처리
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            _hideAppBanners();
            _extractProductPrice();
          },
          onWebResourceError: (WebResourceError error) {},
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
      ..loadRequest(Uri.parse('https://m.coupang.com'));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // 탭별 웹뷰 설정
    switch (index) {
      case 0: // Home
        _webViewController.loadRequest(Uri.parse('https://m.coupang.com'));
        break;
      case 1: // Coupang
        _webViewController.loadRequest(Uri.parse('https://m.coupang.com'));
        break;
      case 2: // Order
        break;
      case 3: // Cart
        break;
      case 4: // Profile
        break;
    }
  }

  Future<void> _orderAction() async {
    try {
      // 상품 정보 추출
      await _extractProductPrice();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('주문 처리 완료!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _hideAppBanners() async {
    await _webViewController.runJavaScript('''
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
      
      final result = await _webViewController.runJavaScriptReturningResult('''
        (function() {
          var priceElement = document.querySelector('.total-price');
          return priceElement ? priceElement.textContent : null;
        })()
      ''');
      
      if (result != null && result.toString() != 'null') {
        String price = result.toString().replaceAll('"', '');
        print('추출된 가격: $price');
        
        // CartViewModel에 가격 업데이트
        // cartViewModel.updateCurrentPrice(price);
      }
    } catch (e) {
      print('가격 추출 오류: $e');
    }
  }

  List<Widget> get _pages => [
    // Home Tab - WebView
    WebViewWidget(controller: _webViewController),
    // Coupang Tab - WebView 
    WebViewWidget(controller: _webViewController),
    // Order Tab
    const OrderPage(),
    // Cart Tab
    const CartPage(),
    // Profile Tab
    const ProfilePage(),
  ];
  
  Widget _buildOrderButton() {
    // Order/Cart 탭에서만 보이기
    if (_selectedIndex != 1) return const SizedBox.shrink();
    
    return Positioned(
      bottom: 100,
      right: 20,
      child: FloatingActionButton(
        onPressed: _orderAction,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add_shopping_cart, color: Colors.white),
      ),
    );
  }
  
  
  
  

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex == 0 || _selectedIndex == 1) {
          if (await _webViewController.canGoBack()) {
            _webViewController.goBack();
            return false;
          }
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Raou'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            Consumer<CartViewModel>(
              builder: (context, cartViewModel, child) {
                return Stack(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 3;
                        });
                      },
                      icon: const Icon(Icons.shopping_cart),
                    ),
                    if (cartViewModel.itemCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: Text(
                            '${cartViewModel.itemCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            _pages[_selectedIndex],
            _buildOrderButton(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag),
              label: 'Coupang',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_shopping_cart),
              label: 'Order',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

