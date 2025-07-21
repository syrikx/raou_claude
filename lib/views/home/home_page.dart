import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/cart_view_model.dart';
import '../../viewmodels/product_view_model.dart';
import '../../viewmodels/order_view_model.dart';
import '../cart/cart_page.dart';
import '../auth/profile_page.dart';
import '../order/order_confirm_page.dart';

// WebView 관련 임포트
import 'package:webview_flutter/webview_flutter.dart';

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
        // Android용 Chrome User-Agent 사용 (HTTP2 호환성 향상)
        ..setUserAgent('Mozilla/5.0 (Linux; Android 10; SM-G973F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36')
        // WebView 추가 설정
        ..enableZoom(true)
        ..setBackgroundColor(Colors.white)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              print('🌐 WebView 로딩 시작: $url');
            },
            onPageFinished: (String url) {
              print('✅ WebView 로딩 완료: $url');
              if (mounted) {
                // DOM Storage 및 쿠키 활성화를 위한 JavaScript 실행
                _webViewController.runJavaScript('''
                  console.log('Raou WebView 초기화 완료');
                  // 필요한 경우 추가 초기화 스크립트
                ''');
              }
            },
            onWebResourceError: (WebResourceError error) {
              print('❌ WebView 오류: ${error.description}');
              print('   오류 코드: ${error.errorCode}');
            },
            onNavigationRequest: (NavigationRequest request) {
              print('🔄 네비게이션 요청: ${request.url}');
              
              // 앱 스토어나 외부 앱으로의 리디렉션 차단
              if (request.url.contains('itunes.apple.com') || 
                  request.url.contains('apps.apple.com') ||
                  request.url.contains('coupang://') ||
                  request.url.startsWith('app-') ||
                  request.url.contains('market://')) {
                print('🚫 외부 앱 리디렉션 차단: ${request.url}');
                return NavigationDecision.prevent;
              }
              
              return NavigationDecision.navigate;
            },
          ),
        )
        // 모바일 최적화된 Coupang 페이지 로드
        ..loadRequest(Uri.parse('https://m.coupang.com'));

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
      // HTTP2 호환성을 위해 모바일 버전 사용
      _webViewController.loadRequest(Uri.parse('https://m.coupang.com'));
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

  // WebView 레이어 (전체 화면)
  Widget _buildWebViewLayer() {
    // 쿠팡 관련 탭에서만 WebView 표시
    if (_currentIndex == 0 || _currentIndex == 1) {
      return kIsWeb
          ? const WebViewPlaceholder()
          : (_webViewController != null
              ? WebViewWidget(controller: _webViewController)
              : const Center(child: CircularProgressIndicator()));
    }
    
    // 다른 탭에서는 해당 콘텐츠 표시
    return Container(
      color: Colors.white,
      child: _buildTabContent(),
    );
  }
  
  // 탭별 콘텐츠 (WebView가 아닌 경우)
  Widget _buildTabContent() {
    switch (_currentIndex) {
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
  
  // 쿠팡 주문 버튼 intercept 레이어
  Widget _buildOrderInterceptLayer() {
    // 쿠팡 탭에서만 활성화
    if (_currentIndex != 1 || kIsWeb || _webViewController == null) {
      return const SizedBox.shrink();
    }
    
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 80, // 하단 네비게이션 바 위
      left: 0,
      right: 0,
      height: 80, // 쿠팡 주문 버튼 영역 높이
      child: GestureDetector(
        onTap: _interceptCoupangOrder,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              '🛒 주문 대행 영역 (쿠팡 주문 버튼 덮개)',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  // 쿠팡 주문 intercept 처리
  Future<void> _interceptCoupangOrder() async {
    try {
      print('🚫 쿠팡 주문 버튼 intercept됨!');
      
      // WebView에서 현재 페이지 정보 추출
      final productViewModel = context.read<ProductViewModel>();
      
      // JavaScript로 상품 정보 추출
      final productInfo = await _extractProductInfo();
      
      if (productInfo != null && mounted) {
        // 주문 정보를 우리 DB에 저장
        await _saveOrderToOurDatabase(productInfo);
        
        // 사용자에게 성공 메시지 표시
        _showOrderInterceptedDialog(productInfo);
      } else {
        _showErrorSnackBar('상품 정보를 추출할 수 없습니다.');
      }
    } catch (e) {
      print('❌ 주문 intercept 오류: $e');
      _showErrorSnackBar('주문 처리 중 오류가 발생했습니다: $e');
    }
  }
  
  // WebView에서 상품 정보 추출
  Future<Map<String, dynamic>?> _extractProductInfo() async {
    if (_webViewController == null) return null;
    
    try {
      // JavaScript로 쿠팡 페이지에서 상품 정보 추출
      final result = await _webViewController.runJavaScriptReturningResult('''
        (function() {
          try {
            // 쿠팡 상품 정보 추출 로직
            const productName = document.querySelector('.prod-buy-header__title, .product-title')?.textContent?.trim();
            const price = document.querySelector('.total-price, .price-info')?.textContent?.trim();
            const seller = document.querySelector('.prod-seller-info, .seller-name')?.textContent?.trim();
            const imageUrl = document.querySelector('.prod-image img, .product-image img')?.src;
            const url = window.location.href;
            
            if (productName && price) {
              return JSON.stringify({
                name: productName,
                price: price,
                seller: seller || '쿠팡',
                imageUrl: imageUrl || '',
                url: url,
                timestamp: new Date().toISOString()
              });
            }
            return null;
          } catch (e) {
            console.error('상품 정보 추출 오류:', e);
            return null;
          }
        })();
      ''');
      
      if (result != null && result.toString() != 'null') {
        final productData = result.toString();
        // JavaScript에서 따옴표로 감싸진 JSON을 파싱
        final cleanData = productData.replaceAll('"', '').replaceAll("'", '"');
        return {'rawData': cleanData, 'extracted': true};
      }
      
      return null;
    } catch (e) {
      print('❌ 상품 정보 추출 실패: $e');
      return null;
    }
  }
  
  // 주문 정보를 우리 DB에 저장
  Future<void> _saveOrderToOurDatabase(Map<String, dynamic> productInfo) async {
    try {
      print('💾 주문 정보 DB 저장 중...');
      print('상품 정보: $productInfo');
      
      // 실제 구현에서는 Firestore나 다른 DB에 저장
      // 지금은 로컬에서 처리
      final orderViewModel = context.read<OrderViewModel>();
      
      // OrderViewModel을 통해 주문 처리
      await orderViewModel.createInterceptedOrder(productInfo);
      
      print('✅ 주문 정보 저장 완료');
    } catch (e) {
      print('❌ DB 저장 오류: $e');
      rethrow;
    }
  }
  
  // 주문 intercept 성공 다이얼로그
  void _showOrderInterceptedDialog(Map<String, dynamic> productInfo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('주문 대행 접수'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🎉 주문이 성공적으로 intercept되었습니다!'),
              const SizedBox(height: 16),
              const Text('📋 주문 정보:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('• 추출된 데이터: ${productInfo['rawData'] ?? 'N/A'}'),
              const SizedBox(height: 8),
              const Text('✅ 우리 시스템에서 주문 대행 처리됩니다.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Order 탭으로 이동
                setState(() {
                  _currentIndex = 2;
                });
              },
              child: const Text('주문 내역 보기'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // WebView가 전체 화면을 차지 (하단 레이어)
          _buildWebViewLayer(),
          
          // 상단 AppBar (오버레이)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).padding.top + kToolbarHeight,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.inversePrimary,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: SafeArea(
                child: AppBar(
                  title: const Text('Raou'),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
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
              ),
            ),
          ),
          
          // 쿠팡 주문 버튼 intercept 레이어
          _buildOrderInterceptLayer(),
          
          // 하단 네비게이션 바 (오버레이)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(0, -2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  currentIndex: _currentIndex,
                  onTap: _onTabTapped,
                  selectedItemColor: Theme.of(context).primaryColor,
                  unselectedItemColor: Colors.grey,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
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
            ),
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
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
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