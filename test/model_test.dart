import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm_app/models/user.dart';
import 'package:mvvm_app/models/product.dart';
import 'package:mvvm_app/models/cart_item.dart';
import 'package:mvvm_app/models/address.dart';
import 'package:mvvm_app/models/order.dart' as models;

void main() {
  group('User Model Tests', () {
    test('User creates correctly', () {
      final user = User(
        id: 'test-id',
        name: 'Test User',
        email: 'test@example.com',
        profileImageUrl: 'https://example.com/image.jpg',
        joinedAt: DateTime.parse('2024-01-01'),
      );

      expect(user.id, equals('test-id'));
      expect(user.name, equals('Test User'));
      expect(user.email, equals('test@example.com'));
      expect(user.profileImageUrl, equals('https://example.com/image.jpg'));
    });

    test('User JSON serialization works', () {
      final user = User(
        id: 'test-id',
        name: 'Test User',
        email: 'test@example.com',
      );

      final json = user.toJson();
      expect(json['id'], equals('test-id'));
      expect(json['name'], equals('Test User'));
      expect(json['email'], equals('test@example.com'));

      final userFromJson = User.fromJson(json);
      expect(userFromJson.id, equals(user.id));
      expect(userFromJson.name, equals(user.name));
      expect(userFromJson.email, equals(user.email));
    });

    test('User copyWith works correctly', () {
      final user = User(
        id: 'test-id',
        name: 'Test User',
        email: 'test@example.com',
      );

      final updatedUser = user.copyWith(name: 'Updated User');

      expect(updatedUser.id, equals('test-id'));
      expect(updatedUser.name, equals('Updated User'));
      expect(updatedUser.email, equals('test@example.com'));
    });

    test('User equality works correctly', () {
      final user1 = User(
        id: 'test-id',
        name: 'Test User',
        email: 'test@example.com',
      );

      final user2 = User(
        id: 'test-id',
        name: 'Test User',
        email: 'test@example.com',
      );

      final user3 = User(
        id: 'different-id',
        name: 'Test User',
        email: 'test@example.com',
      );

      expect(user1, equals(user2));
      expect(user1, isNot(equals(user3)));
    });
  });

  group('Product Model Tests', () {
    test('Product creates correctly', () {
      final product = Product(
        id: 'product-1',
        name: 'Test Product',
        description: 'A test product',
        price: 99.99,
        imageUrl: 'https://example.com/product.jpg',
        category: 'Electronics',
        quantity: 10,
        url: 'https://example.com/product/1',
      );

      expect(product.id, equals('product-1'));
      expect(product.name, equals('Test Product'));
      expect(product.price, equals(99.99));
      expect(product.category, equals('Electronics'));
    });

    test('Product fromCoupangData works', () {
      final data = {
        'id': 'coupang-1',
        'name': 'Coupang Product',
        'description': 'From Coupang',
        'price': '59900',
        'imageUrl': 'https://coupang.com/image.jpg',
        'category': 'Fashion',
        'quantity': '5',
        'url': 'https://coupang.com/product/1',
      };

      final product = Product.fromCoupangData(data);

      expect(product.id, equals('coupang-1'));
      expect(product.name, equals('Coupang Product'));
      expect(product.price, equals(59900.0));
      expect(product.quantity, equals(5));
    });
  });

  group('CartItem Model Tests', () {
    test('CartItem creates correctly', () {
      final product = Product(
        id: 'product-1',
        name: 'Test Product',
        description: 'A test product',
        price: 100.0,
        imageUrl: 'https://example.com/product.jpg',
        category: 'Electronics',
        quantity: 1,
        url: 'https://example.com/product/1',
      );

      final cartItem = CartItem(
        id: 'cart-1',
        product: product,
        quantity: 2,
        addedAt: DateTime.now(),
      );

      expect(cartItem.id, equals('cart-1'));
      expect(cartItem.product.id, equals('product-1'));
      expect(cartItem.quantity, equals(2));
      expect(cartItem.totalPrice, equals(200.0));
    });

    test('CartItem updateQuantity works', () {
      final product = Product(
        id: 'product-1',
        name: 'Test Product',
        description: 'A test product',
        price: 100.0,
        imageUrl: 'https://example.com/product.jpg',
        category: 'Electronics',
        quantity: 1,
        url: 'https://example.com/product/1',
      );

      final cartItem = CartItem(
        id: 'cart-1',
        product: product,
        quantity: 2,
        addedAt: DateTime.now(),
      );

      final updatedItem = cartItem.updateQuantity(3);

      expect(updatedItem.quantity, equals(3));
      expect(updatedItem.totalPrice, equals(300.0));
      expect(updatedItem.id, equals(cartItem.id));
    });
  });

  group('Address Model Tests', () {
    test('Address creates correctly', () {
      final address = Address(
        id: 'addr-1',
        name: 'Home',
        street: '123 Main St',
        city: 'Seoul',
        state: 'Seoul',
        zipCode: '12345',
        isDefault: true,
      );

      expect(address.id, equals('addr-1'));
      expect(address.name, equals('Home'));
      expect(address.fullAddress, equals('123 Main St, Seoul, Seoul 12345'));
      expect(address.isDefault, isTrue);
    });

    test('Address JSON serialization works', () {
      final address = Address(
        id: 'addr-1',
        name: 'Home',
        street: '123 Main St',
        city: 'Seoul',
        state: 'Seoul',
        zipCode: '12345',
      );

      final json = address.toJson();
      expect(json['id'], equals('addr-1'));
      expect(json['name'], equals('Home'));

      final addressFromJson = Address.fromJson(json);
      expect(addressFromJson.id, equals(address.id));
      expect(addressFromJson.name, equals(address.name));
    });
  });

  group('Order Model Tests', () {
    test('Order creates correctly', () {
      final user = User(
        id: 'user-1',
        name: 'Test User',
        email: 'test@example.com',
      );

      final product = Product(
        id: 'product-1',
        name: 'Test Product',
        description: 'A test product',
        price: 100.0,
        imageUrl: 'https://example.com/product.jpg',
        category: 'Electronics',
        quantity: 1,
        url: 'https://example.com/product/1',
      );

      final cartItem = CartItem(
        id: 'cart-1',
        product: product,
        quantity: 2,
        addedAt: DateTime.now(),
      );

      final address = Address(
        id: 'addr-1',
        name: 'Home',
        street: '123 Main St',
        city: 'Seoul',
        state: 'Seoul',
        zipCode: '12345',
      );

      final order = models.Order(
        id: 'order-1',
        user: user,
        items: [cartItem],
        deliveryAddress: address,
        totalAmount: 200.0,
        deliveryFee: 5.0,
        status: models.OrderStatus.pending,
        createdAt: DateTime.now(),
      );

      expect(order.id, equals('order-1'));
      expect(order.user.id, equals('user-1'));
      expect(order.items.length, equals(1));
      expect(order.totalAmount, equals(200.0));
      expect(order.finalAmount, equals(205.0));
      expect(order.itemCount, equals(2));
      expect(order.status, equals(models.OrderStatus.pending));
    });

    test('Order updateStatus works', () {
      final user = User(
        id: 'user-1',
        name: 'Test User',
        email: 'test@example.com',
      );

      final address = Address(
        id: 'addr-1',
        name: 'Home',
        street: '123 Main St',
        city: 'Seoul',
        state: 'Seoul',
        zipCode: '12345',
      );

      final order = models.Order(
        id: 'order-1',
        user: user,
        items: [],
        deliveryAddress: address,
        totalAmount: 200.0,
        status: models.OrderStatus.pending,
        createdAt: DateTime.now(),
      );

      final updatedOrder = order.updateStatus(models.OrderStatus.confirmed);

      expect(updatedOrder.status, equals(models.OrderStatus.confirmed));
      expect(updatedOrder.updatedAt, isNotNull);
    });
  });
}