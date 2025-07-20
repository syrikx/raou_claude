import 'package:json_annotation/json_annotation.dart';
import 'cart_item.dart';
import 'address.dart';
import 'user.dart';

part 'order.g.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled
}

@JsonSerializable()
class Order {
  final String id;
  final User user;
  final List<CartItem> items;
  final Address deliveryAddress;
  final double totalAmount;
  final double deliveryFee;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? notes;

  const Order({
    required this.id,
    required this.user,
    required this.items,
    required this.deliveryAddress,
    required this.totalAmount,
    this.deliveryFee = 0.0,
    this.status = OrderStatus.pending,
    required this.createdAt,
    this.updatedAt,
    this.notes,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);

  // Temporarily disabled Firestore methods
  /*
  factory Order.fromFirestore(Map<String, dynamic> data, String id) {
    return Order(
      id: id,
      user: User.fromFirestore(data['user'], data['user']['id']),
      items: (data['items'] as List?)
          ?.map((item) => CartItem.fromJson(item))
          .toList() ?? [],
      deliveryAddress: Address.fromFirestore(data['deliveryAddress'], data['deliveryAddress']['id']),
      totalAmount: data['totalAmount']?.toDouble() ?? 0.0,
      deliveryFee: data['deliveryFee']?.toDouble() ?? 0.0,
      status: OrderStatus.values.firstWhere(
        (status) => status.toString().split('.').last == data['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate(),
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user': user.toFirestore(),
      'items': items.map((item) => item.toJson()).toList(),
      'deliveryAddress': deliveryAddress.toFirestore(),
      'totalAmount': totalAmount,
      'deliveryFee': deliveryFee,
      'status': status.toString().split('.').last,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'notes': notes,
    };
  }
  */

  double get finalAmount => totalAmount + deliveryFee;
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  Order copyWith({
    String? id,
    User? user,
    List<CartItem>? items,
    Address? deliveryAddress,
    double? totalAmount,
    double? deliveryFee,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
  }) {
    return Order(
      id: id ?? this.id,
      user: user ?? this.user,
      items: items ?? this.items,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      totalAmount: totalAmount ?? this.totalAmount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
    );
  }

  Order updateStatus(OrderStatus newStatus) {
    return copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order &&
        other.id == id &&
        other.user == user &&
        other.items == items &&
        other.deliveryAddress == deliveryAddress &&
        other.totalAmount == totalAmount &&
        other.deliveryFee == deliveryFee &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        user.hashCode ^
        items.hashCode ^
        deliveryAddress.hashCode ^
        totalAmount.hashCode ^
        deliveryFee.hashCode ^
        status.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        notes.hashCode;
  }

  @override
  String toString() {
    return 'Order(id: $id, status: $status, totalAmount: $totalAmount, itemCount: $itemCount)';
  }
}