import 'package:json_annotation/json_annotation.dart';
import 'product.dart';

part 'cart_item.g.dart';

@JsonSerializable()
class CartItem {
  final String id;
  final Product product;
  final int quantity;
  final DateTime addedAt;

  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.addedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => _$CartItemFromJson(json);
  Map<String, dynamic> toJson() => _$CartItemToJson(this);

  double get totalPrice => product.price * quantity;

  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  CartItem updateQuantity(int newQuantity) {
    return copyWith(quantity: newQuantity);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem &&
        other.id == id &&
        other.product == product &&
        other.quantity == quantity &&
        other.addedAt == addedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        product.hashCode ^
        quantity.hashCode ^
        addedAt.hashCode;
  }

  @override
  String toString() {
    return 'CartItem(id: $id, product: ${product.name}, quantity: $quantity, totalPrice: $totalPrice)';
  }
}