import 'package:flutter/foundation.dart';
import '../models/product.dart';
import 'base_view_model.dart';

class ProductViewModel extends BaseViewModel {
  dynamic _webController;
  Product? _currentProduct;

  Product? get currentProduct => _currentProduct;
  dynamic get webController => _webController;

  void setWebController(dynamic controller) {
    if (!kIsWeb) {
      _webController = controller;
      notifyListeners();
    }
  }

  Future<Product?> extractProductFromWebView() async {
    if (kIsWeb || _webController == null) return null;

    return await handleAsyncOperation(() async {
      final result = await _webController!.runJavaScriptReturningResult('''
        (function() {
          try {
            var productData = {};
            
            // 상품명 추출
            var nameElement = document.querySelector('h1.prod-buy-header__title') || 
                             document.querySelector('.prod-buy-header__title') ||
                             document.querySelector('h1');
            if (nameElement) {
              productData.name = nameElement.textContent.trim();
            }
            
            // 가격 추출
            var priceElement = document.querySelector('.total-price strong') ||
                              document.querySelector('.price-value') ||
                              document.querySelector('[class*="price"]');
            if (priceElement) {
              var priceText = priceElement.textContent.replace(/[^0-9]/g, '');
              productData.price = priceText;
            }
            
            // 이미지 URL 추출
            var imageElement = document.querySelector('.prod-image__detail img') ||
                              document.querySelector('.product-image img') ||
                              document.querySelector('img[src*="product"]');
            if (imageElement) {
              productData.imageUrl = imageElement.src;
            }
            
            // 현재 URL
            productData.url = window.location.href;
            
            // 상품 ID (URL에서 추출)
            var urlParts = window.location.pathname.split('/');
            var productId = urlParts[urlParts.length - 1] || Date.now().toString();
            productData.id = productId;
            
            return JSON.stringify(productData);
          } catch (error) {
            return JSON.stringify({error: error.message});
          }
        })();
      ''');

      if (result.toString().contains('error')) {
        throw Exception('Failed to extract product data from webpage');
      }

      // JavaScript에서 반환된 JSON 문자열을 파싱
      // 실제 구현에서는 더 정교한 파싱이 필요할 수 있습니다
      final Map<String, dynamic> data = {};
      
      final product = Product.fromCoupangData({
        'id': data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'name': data['name'] ?? 'Unknown Product',
        'description': data['description'] ?? '',
        'price': data['price'] ?? '0',
        'imageUrl': data['imageUrl'] ?? '',
        'category': 'General',
        'quantity': 1,
        'url': data['url'] ?? '',
      });

      _currentProduct = product;
      notifyListeners();
      return product;
    });
  }

  Future<void> hideAppBanner() async {
    if (kIsWeb || _webController == null) return;

    await handleAsyncOperation(() async {
      await _webController!.runJavaScript('''
        (function() {
          try {
            console.log('Hiding app banners...');
            
            // 더 구체적인 선택자로 앱 배너만 타겟팅
            var specificBanners = [
              'div[class*="app-banner"]',
              'div[class*="download-app"]', 
              'div[id*="app-banner"]',
              'div[class*="mobile-app"]',
              '.smart-banner',
              '.app-banner',
              '.download-banner'
            ];
            
            specificBanners.forEach(function(selector) {
              var elements = document.querySelectorAll(selector);
              elements.forEach(function(el) {
                console.log('Hiding element:', el.className);
                el.style.display = 'none';
              });
            });
            
            // 텍스트 내용으로 앱 다운로드 관련 요소 찾기 (더 안전하게)
            var textElements = document.querySelectorAll('div, span, a');
            textElements.forEach(function(el) {
              var text = el.textContent || '';
              if ((text.includes('앱 다운로드') || text.includes('앱으로 보기') || 
                   text.includes('App Store') || text.includes('Play Store')) &&
                  el.offsetHeight < 200) { // 너무 큰 요소는 제외
                console.log('Hiding app download element:', text.substring(0, 50));
                el.style.display = 'none';
              }
            });
            
            console.log('App banner hiding completed');
          } catch (error) {
            console.error('Error hiding app banners:', error);
          }
        })();
      ''');
    });
  }

  Future<void> navigateToUrl(String url) async {
    if (kIsWeb || _webController == null) return;

    await handleAsyncOperation(() async {
      await _webController!.loadRequest(Uri.parse(url));
      // 페이지 로드 후 앱 배너 숨기기
      await Future.delayed(const Duration(seconds: 2));
      await hideAppBanner();
    });
  }

  Future<void> goBack() async {
    if (kIsWeb || _webController == null) return;
    
    final canGoBack = await _webController!.canGoBack();
    if (canGoBack) {
      await _webController!.goBack();
    }
  }

  Future<void> goForward() async {
    if (kIsWeb || _webController == null) return;
    
    final canGoForward = await _webController!.canGoForward();
    if (canGoForward) {
      await _webController!.goForward();
    }
  }

  Future<void> reload() async {
    if (kIsWeb || _webController == null) return;
    await _webController!.reload();
  }

  void clearCurrentProduct() {
    _currentProduct = null;
    notifyListeners();
  }
}