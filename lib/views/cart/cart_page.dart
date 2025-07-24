import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/cart_view_model.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../models/cart_item.dart';
import '../../shared/utils/ui_helper.dart';
import '../../shared/constants/app_constants.dart';
import '../../widgets/raou_navigation_bar.dart';
import '../order/order_confirm_page.dart';
import '../order/order_page.dart';
import '../auth/profile_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            // Main Content Area
            Column(
              children: [
                // Header with clear button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingM,
                    vertical: AppConstants.paddingS,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '장바구니',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Consumer<CartViewModel>(
                        builder: (context, cartViewModel, child) {
                          if (cartViewModel.isNotEmpty) {
                            return TextButton.icon(
                              onPressed: () => _showClearCartDialog(context),
                              icon: const Icon(Icons.clear_all, size: AppConstants.iconS),
                              label: const Text('전체 삭제'),
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(context).colorScheme.error,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: Consumer<CartViewModel>(
                    builder: (context, cartViewModel, child) {
                      if (cartViewModel.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppConstants.paddingL),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                                ),
                                child: Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: AppConstants.paddingL),
                              Text(
                                '장바구니가 비어있습니다',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: AppConstants.paddingS),
                              Text(
                                '상품을 추가해보세요',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                AppConstants.paddingM,
                                0,
                                AppConstants.paddingM,
                                80, // 네비게이션 바 공간 확보
                              ),
                              itemCount: cartViewModel.cartItems.length,
                              itemBuilder: (context, index) {
                                final cartItem = cartViewModel.cartItems[index];
                                return CartItemCard(cartItem: cartItem);
                              },
                            ),
                          ),
                          if (cartViewModel.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(bottom: 80), // 네비게이션 바 공간
                              child: CartSummary(cartViewModel: cartViewModel),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
            
            // Bottom Navigation Bar
            Align(
              alignment: Alignment.bottomCenter,
              child: Consumer<CartViewModel>(
                builder: (context, cartViewModel, child) {
                  return RaouNavigationBar(
                    onHomePressed: () => Navigator.pop(context),
                    onCoupangPressed: () => Navigator.pop(context),
                    onOrderPressed: () => UIHelper.navigateTo(const OrderPage(), context: context),
                    onCartPressed: () {}, // 현재 페이지이므로 아무것도 하지 않음
                    onProfilePressed: () => UIHelper.navigateTo(const ProfilePage(), context: context),
                    cartItemCount: cartViewModel.itemCount,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) async {
    final confirmed = await UIHelper.showConfirmDialog(
      context: context,
      title: '장바구니 비우기',
      content: '장바구니에 있는 모든 상품을 삭제하시겠습니까?',
      confirmText: '삭제',
      cancelText: '취소',
    );

    if (confirmed) {
      context.read<CartViewModel>().clearCart();
      UIHelper.showSnack('장바구니가 비워졌습니다.', context: context);
    }
  }
}

class CartItemCard extends StatelessWidget {
  final CartItem cartItem;

  const CartItemCard({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                cartItem.product.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₩${cartItem.product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      QuantityControls(cartItem: cartItem),
                      Text(
                        '₩${cartItem.totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _showDeleteDialog(context),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) async {
    final confirmed = await UIHelper.showConfirmDialog(
      context: context,
      title: '상품 삭제',
      content: '${cartItem.product.name}을(를) 장바구니에서 삭제하시겠습니까?',
      confirmText: '삭제',
      cancelText: '취소',
    );

    if (confirmed) {
      context.read<CartViewModel>().removeFromCart(cartItem.id);
      UIHelper.showSnack('상품이 삭제되었습니다.', context: context);
    }
  }
}

class QuantityControls extends StatelessWidget {
  final CartItem cartItem;

  const QuantityControls({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            context.read<CartViewModel>().decrementQuantity(cartItem.id);
          },
          icon: const Icon(Icons.remove_circle_outline),
          iconSize: 20,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${cartItem.quantity}',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        IconButton(
          onPressed: () {
            context.read<CartViewModel>().incrementQuantity(cartItem.id);
          },
          icon: const Icon(Icons.add_circle_outline),
          iconSize: 20,
        ),
      ],
    );
  }
}

class CartSummary extends StatelessWidget {
  final CartViewModel cartViewModel;

  const CartSummary({super.key, required this.cartViewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total (${cartViewModel.itemCount} items)',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                '₩${cartViewModel.totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: cartViewModel.isNotEmpty ? () => _proceedToCheckout(context) : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Proceed to Checkout',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _proceedToCheckout(BuildContext context) {
    final authViewModel = context.read<AuthViewModel>();
    if (!authViewModel.isAuthenticated) {
      UIHelper.showWarningSnack(
        '주문하려면 먼저 로그인해주세요.',
        context: context,
      );
      return;
    }

    UIHelper.navigateTo(
      OrderConfirmPage(cartItems: cartViewModel.cartItems),
      context: context,
    );
  }
}