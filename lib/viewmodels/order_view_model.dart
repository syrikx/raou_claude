// import 'package:cloud_firestore/cloud_firestore.dart'; // Temporarily disabled
// import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // Temporarily disabled
import 'package:uuid/uuid.dart';
import '../models/order.dart' as models;
import '../models/cart_item.dart';
import '../models/address.dart';
import '../models/user.dart';
import '../models/product.dart';
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
  
  // 쿠팡에서 intercept된 주문 처리
  Future<bool> createInterceptedOrder(Map<String, dynamic> productInfo) async {
    try {
      setLoading(true);
      
      print('📦 Intercept된 주문 생성 중...');
      print('상품 정보: $productInfo');
      
      // 임시 사용자 정보 (실제로는 AuthViewModel에서 가져옴)
      final tempUser = User(
        id: 'temp_user_id',
        email: 'temp@example.com',
        name: '테스트 사용자',
        profileImageUrl: null,
        joinedAt: DateTime.now(),
      );
      
      // 임시 배송 주소 (실제로는 AddressViewModel에서 가져옴)
      final tempAddress = Address(
        id: 'temp_address_id',
        name: '테스트 사용자',
        street: '테스트 주소',
        city: '서울시',
        state: '강남구',
        zipCode: '06000',
        isDefault: true,
      );
      
      // ProductInfo를 CartItem으로 변환
      final cartItem = _convertProductInfoToCartItem(productInfo);
      
      // Intercept된 주문 생성
      final orderId = _uuid.v4();
      final interceptedOrder = models.Order(
        id: orderId,
        user: tempUser,
        items: [cartItem],
        deliveryAddress: tempAddress,
        totalAmount: cartItem.totalPrice,
        deliveryFee: 0.0, // 쿠팡 무료배송 가정
        status: models.OrderStatus.intercepted, // 새로운 상태 추가 필요
        createdAt: DateTime.now(),
        interceptedFrom: 'coupang', // 어디서 intercept했는지 추가 정보
        originalUrl: productInfo['url']?.toString(),
      );
      
      // 로컬 주문 목록에 추가 (Firebase 비활성화 상태이므로)
      _orders.insert(0, interceptedOrder);
      _currentOrder = interceptedOrder;
      
      print('✅ Intercept된 주문 생성 완료: ${orderId}');
      
      notifyListeners();
      return true;
      
    } catch (e) {
      print('❌ Intercept된 주문 생성 실패: $e');
      setError('주문 생성 중 오류가 발생했습니다: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }
  
  // ProductInfo를 CartItem으로 변환하는 헬퍼 메서드
  CartItem _convertProductInfoToCartItem(Map<String, dynamic> productInfo) {
    // rawData에서 상품 정보 파싱 (실제로는 더 정교한 파싱 필요)
    final rawData = productInfo['rawData']?.toString() ?? '';
    
    // 먼저 Product 객체 생성
    final product = Product(
      id: _uuid.v4(),
      name: _extractValueFromRawData(rawData, 'name') ?? '쿠팡 상품',
      description: '쿠팡에서 intercept된 상품',
      price: _parsePrice(_extractValueFromRawData(rawData, 'price') ?? '0'),
      imageUrl: _extractValueFromRawData(rawData, 'imageUrl') ?? '',
      category: 'intercepted',
      quantity: 1,
      url: _extractValueFromRawData(rawData, 'url') ?? '',
    );
    
    return CartItem(
      id: _uuid.v4(),
      product: product,
      quantity: 1,
      addedAt: DateTime.now(),
    );
  }
  
  // rawData에서 특정 값을 추출하는 헬퍼 메서드
  String? _extractValueFromRawData(String rawData, String key) {
    try {
      // 간단한 문자열 파싱 (실제로는 JSON 파싱이나 정규식 사용)
      final pattern = RegExp('$key[:\s]*([^,}]+)');
      final match = pattern.firstMatch(rawData);
      return match?.group(1)?.trim().replaceAll('"', '');
    } catch (e) {
      print('⚠️ rawData 파싱 오류: $e');
      return null;
    }
  }
  
  // 가격 문자열을 double로 변환
  double _parsePrice(String priceStr) {
    try {
      // 가격에서 숫자만 추출 (예: "19,900원" -> 19900.0)
      final numericStr = priceStr.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(numericStr) ?? 0.0;
    } catch (e) {
      print('⚠️ 가격 파싱 오류: $e');
      return 0.0;
    }
  }
  
  // Intercept된 주문들만 필터링
  List<models.Order> getInterceptedOrders() {
    return _orders.where((order) => 
      order.interceptedFrom != null && order.interceptedFrom!.isNotEmpty
    ).toList();
  }
  
  // Intercept된 주문 통계
  int getInterceptedOrderCount() {
    return getInterceptedOrders().length;
  }
  
  double getTotalInterceptedAmount() {
    return getInterceptedOrders()
        .fold(0.0, (sum, order) => sum + order.finalAmount);
  }
}