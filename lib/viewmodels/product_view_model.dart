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
          // 앱 설치 배너 숨기기
          var appBanners = document.querySelectorAll('[class*="app"], [class*="banner"], [id*="app"], [id*="banner"]');
          appBanners.forEach(function(banner) {
            if (banner.textContent.includes('앱') || banner.textContent.includes('App')) {
              banner.style.display = 'none';
            }
          });
          
          // 쿠팡 앱 다운로드 팝업 숨기기
          var popups = document.querySelectorAll('.popup, .modal, .overlay');
          popups.forEach(function(popup) {
            popup.style.display = 'none';
          });
          
          // 메타 태그에서 앱 관련 내용 제거
          var metaTags = document.querySelectorAll('meta[content*="app"]');
          metaTags.forEach(function(meta) {
            meta.remove();
          });
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