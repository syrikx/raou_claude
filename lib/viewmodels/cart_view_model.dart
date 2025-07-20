import 'package:uuid/uuid.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import 'base_view_model.dart';

class CartViewModel extends BaseViewModel {
  final List<CartItem> _cartItems = [];
  static const Uuid _uuid = Uuid();

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);
  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount => _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  bool get isEmpty => _cartItems.isEmpty;
  bool get isNotEmpty => _cartItems.isNotEmpty;

  void addToCart(Product product, {int quantity = 1}) {
    final existingIndex = _cartItems.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex != -1) {
      final existingItem = _cartItems[existingIndex];
      _cartItems[existingIndex] = existingItem.updateQuantity(existingItem.quantity + quantity);
    } else {
      final cartItem = CartItem(
        id: _uuid.v4(),
        product: product,
        quantity: quantity,
        addedAt: DateTime.now(),
      );
      _cartItems.add(cartItem);
    }
    
    notifyListeners();
  }

  void removeFromCart(String cartItemId) {
    _cartItems.removeWhere((item) => item.id == cartItemId);
    notifyListeners();
  }

  void updateQuantity(String cartItemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(cartItemId);
      return;
    }

    final index = _cartItems.indexWhere((item) => item.id == cartItemId);
    if (index != -1) {
      _cartItems[index] = _cartItems[index].updateQuantity(newQuantity);
      notifyListeners();
    }
  }

  void incrementQuantity(String cartItemId) {
    final index = _cartItems.indexWhere((item) => item.id == cartItemId);
    if (index != -1) {
      final currentQuantity = _cartItems[index].quantity;
      updateQuantity(cartItemId, currentQuantity + 1);
    }
  }

  void decrementQuantity(String cartItemId) {
    final index = _cartItems.indexWhere((item) => item.id == cartItemId);
    if (index != -1) {
      final currentQuantity = _cartItems[index].quantity;
      updateQuantity(cartItemId, currentQuantity - 1);
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  CartItem? getCartItem(String cartItemId) {
    final index = _cartItems.indexWhere((item) => item.id == cartItemId);
    return index != -1 ? _cartItems[index] : null;
  }

  bool isProductInCart(String productId) {
    return _cartItems.any((item) => item.product.id == productId);
  }

  int getProductQuantityInCart(String productId) {
    final item = _cartItems.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(
        id: '',
        product: Product(
          id: '',
          name: '',
          description: '',
          price: 0,
          imageUrl: '',
          category: '',
          quantity: 0,
          url: '',
        ),
        quantity: 0,
        addedAt: DateTime.now(),
      ),
    );
    return item.quantity;
  }

  List<CartItem> getItemsByCategory(String category) {
    return _cartItems.where((item) => item.product.category == category).toList();
  }

  Map<String, List<CartItem>> getItemsGroupedByCategory() {
    final Map<String, List<CartItem>> grouped = {};
    for (final item in _cartItems) {
      final category = item.product.category;
      if (grouped.containsKey(category)) {
        grouped[category]!.add(item);
      } else {
        grouped[category] = [item];
      }
    }
    return grouped;
  }
}