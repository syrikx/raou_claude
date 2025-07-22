import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/order_view_model.dart';

class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<OrderViewModel>(
          builder: (context, orderViewModel, child) {
            if (orderViewModel.orders.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_shopping_cart,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Quick Order',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '쿠팡에서 상품을 선택한 후\n주문 버튼을 눌러 빠른 주문을 하세요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orderViewModel.orders.length,
              itemBuilder: (context, index) {
                final order = orderViewModel.orders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order #${order.id}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Chip(
                              label: Text(order.status.name),
                              backgroundColor: _getStatusColor(order.status.name),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total: ₩${order.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (order.createdAt != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Ordered: ${order.createdAt!.toLocal().toString().split(' ')[0]}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade100;
      case 'confirmed':
        return Colors.blue.shade100;
      case 'shipped':
        return Colors.purple.shade100;
      case 'delivered':
        return Colors.green.shade100;
      case 'cancelled':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }
}