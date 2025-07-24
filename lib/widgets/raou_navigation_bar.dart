import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_view_model.dart';
import '../viewmodels/cart_view_model.dart';

class RaouNavigationBar extends StatelessWidget {
  final void Function() onHomePressed;
  final void Function() onCoupangPressed;
  final void Function() onOrderPressed;
  final void Function() onCartPressed;
  final void Function() onProfilePressed;
  final int cartItemCount;

  const RaouNavigationBar({
    super.key,
    required this.onHomePressed,
    required this.onCoupangPressed,
    required this.onOrderPressed,
    required this.onCartPressed,
    required this.onProfilePressed,
    required this.cartItemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        final user = authViewModel.currentUser;

        return Container(
          height: 80, // 명시적인 높이 설정
          color: const Color(0xFF2C2C54).withOpacity(0.95), // 불투명도 증가
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _brandLabel(),
              const SizedBox(width: 16),
              _navItem(Icons.storefront_outlined, '쿠팡', onCoupangPressed),
              _navItem(Icons.shopping_bag_outlined, '주문', onOrderPressed),
              _cartIconWithBadge(onCartPressed, cartItemCount),
              GestureDetector(
                onTap: onProfilePressed,
                behavior: HitTestBehavior.opaque, // 터치 영역을 명확히 정의
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: user != null && user.profileImageUrl != null
                    ? CircleAvatar(
                        radius: 14,
                        backgroundImage: NetworkImage(user.profileImageUrl!),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.person_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            '로그인',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _brandLabel() {
    return const Padding(
      padding: EdgeInsets.only(right: 4),
      child: Text(
        'Raou',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, void Function() onPressed) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque, // 터치 영역을 명확히 정의
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cartIconWithBadge(void Function() onPressed, int itemCount) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque, // 터치 영역을 명확히 정의
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(height: 2),
                const Text(
                  '장바구니',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            if (itemCount > 0)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 14,
                    minHeight: 14,
                  ),
                  child: Text(
                    '$itemCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}