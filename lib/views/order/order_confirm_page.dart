import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../viewmodels/cart_view_model.dart';
import '../../viewmodels/address_view_model.dart';
import '../../viewmodels/order_view_model.dart';
import '../../models/product.dart';
import '../../models/cart_item.dart';
import '../../models/address.dart';
import '../address/address_list_page.dart';

class OrderConfirmPage extends StatefulWidget {
  final Product? product;
  final List<CartItem>? cartItems;

  const OrderConfirmPage({
    super.key,
    this.product,
    this.cartItems,
  });

  @override
  State<OrderConfirmPage> createState() => _OrderConfirmPageState();
}

class _OrderConfirmPageState extends State<OrderConfirmPage> {
  final TextEditingController _notesController = TextEditingController();
  int _productQuantity = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressViewModel>().loadAddresses();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  List<CartItem> get _orderItems {
    if (widget.cartItems != null) {
      return widget.cartItems!;
    } else if (widget.product != null) {
      return [
        CartItem(
          id: 'temp_${widget.product!.id}',
          product: widget.product!,
          quantity: _productQuantity,
          addedAt: DateTime.now(),
        ),
      ];
    }
    return [];
  }

  double get _totalAmount {
    return _orderItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Order'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer3<AuthViewModel, AddressViewModel, OrderViewModel>(
        builder: (context, authViewModel, addressViewModel, orderViewModel, child) {
          if (!authViewModel.isAuthenticated) {
            return const Center(
              child: Text('Please sign in to place an order'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DeliveryAddressSection(addressViewModel: addressViewModel),
                const SizedBox(height: 24),
                OrderItemsSection(
                  items: _orderItems,
                  onQuantityChanged: widget.product != null
                      ? (quantity) {
                          setState(() {
                            _productQuantity = quantity;
                          });
                        }
                      : null,
                ),
                const SizedBox(height: 24),
                OrderNotesSection(controller: _notesController),
                const SizedBox(height: 24),
                OrderSummarySection(
                  totalAmount: _totalAmount,
                  deliveryFee: 0.0,
                ),
                const SizedBox(height: 32),
                PlaceOrderButton(
                  isLoading: orderViewModel.isLoading,
                  onPressed: () => _placeOrder(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _placeOrder(BuildContext context) async {
    final authViewModel = context.read<AuthViewModel>();
    final addressViewModel = context.read<AddressViewModel>();
    final orderViewModel = context.read<OrderViewModel>();
    final cartViewModel = context.read<CartViewModel>();

    if (addressViewModel.selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery address')),
      );
      return;
    }

    final order = await orderViewModel.createOrder(
      user: authViewModel.currentUser!,
      items: _orderItems,
      deliveryAddress: addressViewModel.selectedAddress!,
      deliveryFee: 0.0,
    );

    if (order != null && mounted) {
      // Clear cart if ordering from cart
      if (widget.cartItems != null) {
        cartViewModel.clearCart();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order placed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }
}

class DeliveryAddressSection extends StatelessWidget {
  final AddressViewModel addressViewModel;

  const DeliveryAddressSection({super.key, required this.addressViewModel});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Delivery Address',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddressListPage()),
                  ),
                  child: const Text('Change'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (addressViewModel.selectedAddress != null)
              AddressDisplayCard(address: addressViewModel.selectedAddress!)
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.location_off, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'No address selected',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AddressDisplayCard extends StatelessWidget {
  final Address address;

  const AddressDisplayCard({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            address.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            address.fullAddress,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderItemsSection extends StatelessWidget {
  final List<CartItem> items;
  final Function(int)? onQuantityChanged;

  const OrderItemsSection({
    super.key,
    required this.items,
    this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Items (${items.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...items.map((item) => OrderItemCard(
                  item: item,
                  onQuantityChanged: onQuantityChanged,
                )),
          ],
        ),
      ),
    );
  }
}

class OrderItemCard extends StatelessWidget {
  final CartItem item;
  final Function(int)? onQuantityChanged;

  const OrderItemCard({
    super.key,
    required this.item,
    this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.product.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '₩${item.product.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          if (onQuantityChanged != null)
            QuantitySelector(
              quantity: item.quantity,
              onChanged: onQuantityChanged!,
            )
          else
            Text(
              'Qty: ${item.quantity}',
              style: const TextStyle(fontSize: 16),
            ),
        ],
      ),
    );
  }
}

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final Function(int) onChanged;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: quantity > 1 ? () => onChanged(quantity - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
          iconSize: 20,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '$quantity',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        IconButton(
          onPressed: () => onChanged(quantity + 1),
          icon: const Icon(Icons.add_circle_outline),
          iconSize: 20,
        ),
      ],
    );
  }
}

class OrderNotesSection extends StatelessWidget {
  final TextEditingController controller;

  const OrderNotesSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Notes (Optional)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Any special instructions for your order...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderSummarySection extends StatelessWidget {
  final double totalAmount;
  final double deliveryFee;

  const OrderSummarySection({
    super.key,
    required this.totalAmount,
    required this.deliveryFee,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal:'),
                Text('₩${totalAmount.toStringAsFixed(0)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Delivery Fee:'),
                Text('₩${deliveryFee.toStringAsFixed(0)}'),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '₩${(totalAmount + deliveryFee).toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PlaceOrderButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const PlaceOrderButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Place Order',
                style: TextStyle(fontSize: 16),
              ),
      ),
    );
  }
}