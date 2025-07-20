import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/cart_view_model.dart';
import '../../viewmodels/product_view_model.dart';
import '../cart/cart_page.dart';
import '../auth/profile_page.dart';
import '../order/order_confirm_page.dart';

// Conditional import for WebView
import 'web_view_stub.dart'
    if (dart.library.io) 'package:webview_flutter/webview_flutter.dart'
    if (dart.library.html) 'web_view_web.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  dynamic _webViewController;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _initializeWebView();
    }
  }

  void _initializeWebView() {
    if (!kIsWeb) {
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (String url) {
              if (mounted) {
                context.read<ProductViewModel>().hideAppBanner();
              }
            },
          ),
        )
        ..loadRequest(Uri.parse('https://www.coupang.com'));

      // Schedule the setWebController call for after the current build frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<ProductViewModel>().setWebController(_webViewController);
        }
      });
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // 웹뷰 관련 처리는 Home/Coupang 탭에서만
    if (index == 1 && !kIsWeb && _webViewController != null) {
      _webViewController.loadRequest(Uri.parse('https://www.coupang.com'));
    }
  }

  Future<void> _onOrderPressed() async {
    if (kIsWeb) {
      _showErrorSnackBar('주문 기능은 모바일 앱에서만 사용 가능합니다.');
      return;
    }
    
    try {
      final productViewModel = context.read<ProductViewModel>();
      final product = await productViewModel.extractProductFromWebView();
      
      if (product != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderConfirmPage(product: product),
          ),
        );
      } else {
        _showErrorSnackBar('상품 정보를 가져올 수 없습니다.');
      }
    } catch (e) {
      _showErrorSnackBar('오류가 발생했습니다: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0: // Home
      case 1: // Coupang
        return kIsWeb
            ? const WebViewPlaceholder()
            : (_webViewController != null
                ? WebViewWidget(controller: _webViewController)
                : const Center(child: CircularProgressIndicator()));
      case 2: // Order
        return const OrderTabContent();
      case 3: // Cart
        return const CartPage();
      case 4: // Profile
        return const ProfilePage();
      default:
        return const Center(child: Text('페이지를 찾을 수 없습니다.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        _currentIndex = 3; // Cart 탭으로 이동
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
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
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
    );
  }
}

class WebViewPlaceholder extends StatelessWidget {
  const WebViewPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.web,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 24),
          const Text(
            'Coupang Shopping',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'WebView is not available on web platform.\nPlease use mobile app for full shopping experience.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('모바일 앱에서 쇼핑 기능을 사용해주세요.'),
                ),
              );
            },
            icon: const Icon(Icons.info),
            label: const Text('Use Mobile App for Shopping'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderTabContent extends StatelessWidget {
  const OrderTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.add_shopping_cart,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 24),
          const Text(
            'Quick Order',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '쿠팡에서 상품을 선택한 후\n주문 버튼을 눌러 빠른 주문을 하세요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () async {
              final homeState = context.findAncestorStateOfType<_HomePageState>();
              if (homeState != null) {
                await homeState._onOrderPressed();
              }
            },
            icon: const Icon(Icons.shopping_cart),
            label: const Text('Extract Product from WebView'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}