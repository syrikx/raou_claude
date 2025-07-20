import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm_app/viewmodels/cart_view_model.dart';
import 'package:mvvm_app/viewmodels/product_view_model.dart';
import 'package:mvvm_app/models/product.dart';

void main() {
  group('CartViewModel Tests', () {
    late CartViewModel cartViewModel;

    setUp(() {
      cartViewModel = CartViewModel();
    });

    test('CartViewModel initializes correctly', () {
      expect(cartViewModel.isEmpty, isTrue);
      expect(cartViewModel.isNotEmpty, isFalse);
      expect(cartViewModel.itemCount, equals(0));
      expect(cartViewModel.totalAmount, equals(0.0));
      expect(cartViewModel.cartItems, isEmpty);
    });

    test('CartViewModel adds product correctly', () {
      final product = Product(
        id: 'test-1',
        name: 'Test Product',
        description: 'Test Description',
        price: 100.0,
        imageUrl: 'https://example.com/image.jpg',
        category: 'Test',
        quantity: 1,
        url: 'https://example.com/product',
      );

      cartViewModel.addToCart(product, quantity: 2);

      expect(cartViewModel.isEmpty, isFalse);
      expect(cartViewModel.isNotEmpty, isTrue);
      expect(cartViewModel.itemCount, equals(2));
      expect(cartViewModel.totalAmount, equals(200.0));
      expect(cartViewModel.cartItems.length, equals(1));
      expect(cartViewModel.cartItems.first.product.id, equals('test-1'));
    });

    test('CartViewModel updates quantity correctly', () {
      final product = Product(
        id: 'test-1',
        name: 'Test Product',
        description: 'Test Description',
        price: 100.0,
        imageUrl: 'https://example.com/image.jpg',
        category: 'Test',
        quantity: 1,
        url: 'https://example.com/product',
      );

      cartViewModel.addToCart(product, quantity: 1);
      final cartItemId = cartViewModel.cartItems.first.id;

      cartViewModel.updateQuantity(cartItemId, 3);

      expect(cartViewModel.itemCount, equals(3));
      expect(cartViewModel.totalAmount, equals(300.0));
    });

    test('CartViewModel removes product correctly', () {
      final product = Product(
        id: 'test-1',
        name: 'Test Product',
        description: 'Test Description',
        price: 100.0,
        imageUrl: 'https://example.com/image.jpg',
        category: 'Test',
        quantity: 1,
        url: 'https://example.com/product',
      );

      cartViewModel.addToCart(product, quantity: 1);
      final cartItemId = cartViewModel.cartItems.first.id;

      cartViewModel.removeFromCart(cartItemId);

      expect(cartViewModel.isEmpty, isTrue);
      expect(cartViewModel.itemCount, equals(0));
      expect(cartViewModel.totalAmount, equals(0.0));
    });

    test('CartViewModel clears cart correctly', () {
      final product1 = Product(
        id: 'test-1',
        name: 'Test Product 1',
        description: 'Test Description',
        price: 100.0,
        imageUrl: 'https://example.com/image.jpg',
        category: 'Test',
        quantity: 1,
        url: 'https://example.com/product',
      );

      final product2 = Product(
        id: 'test-2',
        name: 'Test Product 2',
        description: 'Test Description',
        price: 200.0,
        imageUrl: 'https://example.com/image.jpg',
        category: 'Test',
        quantity: 1,
        url: 'https://example.com/product',
      );

      cartViewModel.addToCart(product1);
      cartViewModel.addToCart(product2);

      expect(cartViewModel.cartItems.length, equals(2));

      cartViewModel.clearCart();

      expect(cartViewModel.isEmpty, isTrue);
      expect(cartViewModel.cartItems.length, equals(0));
    });
  });

  group('ProductViewModel Tests', () {
    late ProductViewModel productViewModel;

    setUp(() {
      productViewModel = ProductViewModel();
    });

    test('ProductViewModel initializes correctly', () {
      expect(productViewModel.currentProduct, isNull);
      expect(productViewModel.webController, isNull);
    });

    test('ProductViewModel clears current product', () {
      productViewModel.clearCurrentProduct();
      expect(productViewModel.currentProduct, isNull);
    });
  });
}