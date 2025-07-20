// import 'package:cloud_firestore/cloud_firestore.dart'; // Temporarily disabled
// import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // Temporarily disabled
import 'package:uuid/uuid.dart';
import '../models/order.dart' as models;
import '../models/cart_item.dart';
import '../models/address.dart';
import '../models/user.dart';
import 'base_view_model.dart';

class OrderViewModel extends BaseViewModel {
  // Temporarily disabled Firebase dependencies
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  
  final Uuid _uuid = const Uuid();
  
  List<models.Order> _orders = [];
  models.Order? _currentOrder;
  
  List<models.Order> get orders => _orders;
  models.Order? get currentOrder => _currentOrder;
  
  OrderViewModel() {
    // Temporarily disabled Firebase order loading
    // loadOrders();
  }
  
  Future<void> loadOrders() async {
    // Temporarily disabled Firebase order loading
    /*
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    
    await handleAsyncOperation(() async {
      final querySnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();
      
      _orders = querySnapshot.docs.map((doc) {
        return models.Order.fromFirestore(doc.data(), doc.id);
      }).toList();
      
      notifyListeners();
    });
    */
  }
  
  Future<bool> createOrder({
    required User user,
    required List<CartItem> items,
    required Address deliveryAddress,
    double deliveryFee = 3000.0,
  }) async {
    // Temporarily disabled Firebase order creation
    /*
    return await handleAsyncOperation(() async {
      final orderId = _uuid.v4();
      final totalAmount = items.fold(0.0, (sum, item) => sum + item.totalPrice);
      
      final order = models.Order(
        id: orderId,
        user: user,
        items: items,
        deliveryAddress: deliveryAddress,
        totalAmount: totalAmount,
        deliveryFee: deliveryFee,
        status: models.OrderStatus.pending,
        createdAt: DateTime.now(),
      );
      
      await _firestore.collection('orders').doc(orderId).set(order.toFirestore());
      
      _orders.insert(0, order);
      _currentOrder = order;
      notifyListeners();
      
      return true;
    }) ?? false;
    */
    
    // Placeholder implementation without Firebase
    setError('Order creation is temporarily disabled.');
    return false;
  }
  
  Future<void> updateOrderStatus(String orderId, models.OrderStatus status) async {
    // Temporarily disabled Firebase order updates
    /*
    await handleAsyncOperation(() async {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status.name,
        'updatedAt': DateTime.now(),
      });
      
      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        _orders[orderIndex] = _orders[orderIndex].updateStatus(status);
        
        if (_currentOrder?.id == orderId) {
          _currentOrder = _orders[orderIndex];
        }
        
        notifyListeners();
      }
    });
    */
  }
  
  Future<void> cancelOrder(String orderId) async {
    await updateOrderStatus(orderId, models.OrderStatus.cancelled);
  }
  
  List<models.Order> getOrdersByStatus(models.OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }
  
  List<models.Order> getActiveOrders() {
    return _orders.where((order) => 
      order.status == models.OrderStatus.pending ||
      order.status == models.OrderStatus.confirmed ||
      order.status == models.OrderStatus.processing ||
      order.status == models.OrderStatus.shipped
    ).toList();
  }
  
  double getTotalSpent() {
    return _orders
        .where((order) => order.status == models.OrderStatus.delivered)
        .fold(0.0, (sum, order) => sum + order.finalAmount);
  }
  
  int getTotalOrderCount() {
    return _orders.length;
  }
  
  void clearCurrentOrder() {
    _currentOrder = null;
    notifyListeners();
  }
}