import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../viewmodels/order_view_model.dart';
import '../../viewmodels/address_view_model.dart';
import '../../viewmodels/cart_view_model.dart';
import '../../shared/utils/ui_helper.dart';
import '../../shared/constants/app_constants.dart';
import '../../widgets/raou_navigation_bar.dart';
import '../address/address_list_page.dart';
import '../settings/settings_page.dart';
import '../cart/cart_page.dart';
import '../order/order_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            // Main Content Area
            Column(
              children: [
                // Header with settings button
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
                        'Profile',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () => UIHelper.navigateTo(const SettingsPage(), context: context),
                        tooltip: '설정',
                      ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 80), // 네비게이션 바 공간 확보
                    child: Consumer<AuthViewModel>(
                      builder: (context, authViewModel, child) {
                        if (!authViewModel.isAuthenticated) {
                          return const SignInView();
                        }

                        return UserProfileView(user: authViewModel.currentUser!);
                      },
                    ),
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
                    onCartPressed: () => UIHelper.navigateTo(const CartPage(), context: context),
                    onProfilePressed: () {}, // 현재 페이지이므로 아무것도 하지 않음
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
}

class SignInView extends StatelessWidget {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Material Design 3 스타일 아이콘
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingL),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                ),
                child: Icon(
                  Icons.person_outline,
                  size: 64,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: AppConstants.paddingL),
              
              // Material Design 3 Typography
              Text(
                'Raou에 오신 것을 환영합니다',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingM),
              
              Text(
                '주문 내역, 주소록, 설정을 관리하려면\n로그인해주세요',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppConstants.paddingXL),
              Consumer<AuthViewModel>(
                builder: (context, authViewModel, child) {
                  return Column(
                    children: [
                      // Google Sign-In 버튼 (Material Design 3)
                      if (authViewModel.isGoogleSignInAvailable) ...[
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.tonalIcon(
                            onPressed: authViewModel.isLoading
                                ? null
                                : () => _signInWithGoogle(context),
                            icon: authViewModel.isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.g_mobiledata, size: 24),
                            label: Text(
                              authViewModel.isLoading ? '로그인 중...' : 'Google로 계속하기',  
                              style: theme.textTheme.labelLarge,
                            ),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingM),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingS),
                      ],
                    
                      // Apple Sign-In 버튼 (iOS만)
                      if (authViewModel.isAppleSignInAvailable) ...[
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: authViewModel.isLoading
                                ? null
                                : () => _signInWithApple(context),
                            icon: const Icon(Icons.apple, color: Colors.white),
                            label: Text(
                              'Apple로 계속하기',
                              style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
                            ),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingM),
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingS),
                      ],
                    
                      // 테스트 로그인 버튼 (개발용)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: authViewModel.isLoading
                              ? null
                              : () => _signInAsMockUser(context),
                          icon: const Icon(Icons.person_outline),
                          label: Text(
                            '테스트 로그인',
                            style: theme.textTheme.labelLarge,
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingM),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusM),
                            ),
                            side: BorderSide(color: colorScheme.outline),
                          ),
                        ),
                      ),
                    
                      // Firebase 상태 표시
                      const SizedBox(height: AppConstants.paddingM),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingS,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: authViewModel.isFirebaseAvailable 
                              ? colorScheme.primaryContainer
                              : colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(AppConstants.radiusS),
                        ),
                        child: Text(
                          authViewModel.isFirebaseAvailable 
                              ? 'Firebase 인증 활성화됨' 
                              : 'Mock 모드로 실행 중',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: authViewModel.isFirebaseAvailable 
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onTertiaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            if (context.watch<AuthViewModel>().hasError)
              Padding(
                padding: const EdgeInsets.only(top: AppConstants.paddingM),
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.paddingS),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: colorScheme.onErrorContainer,
                        size: AppConstants.iconM,
                      ),
                      const SizedBox(width: AppConstants.paddingS),
                      Expanded(
                        child: Text(
                          context.watch<AuthViewModel>().error!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    final authViewModel = context.read<AuthViewModel>();
    final success = await authViewModel.signInWithGoogle(context);
    
    if (success) {
      // Load user data after sign in
      context.read<AddressViewModel>().loadAddresses();
      context.read<OrderViewModel>().loadOrders();
    }
  }

  Future<void> _signInWithApple(BuildContext context) async {
    final authViewModel = context.read<AuthViewModel>();
    final success = await authViewModel.signInWithApple(context);
    
    if (success) {
      // Load user data after sign in
      context.read<AddressViewModel>().loadAddresses();
      context.read<OrderViewModel>().loadOrders();
    }
  }

  Future<void> _signInAsMockUser(BuildContext context) async {
    final authViewModel = context.read<AuthViewModel>();
    await authViewModel.signInAsMockUser(context);
    
    // Load user data after sign in (mock data will be empty)
    context.read<AddressViewModel>().loadAddresses();
    context.read<OrderViewModel>().loadOrders();
  }
}

class UserProfileView extends StatelessWidget {
  final dynamic user;

  const UserProfileView({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      child: Column(
        children: [
          ProfileHeader(user: user),
          const SizedBox(height: AppConstants.paddingL),
          const ProfileStats(),
          const SizedBox(height: AppConstants.paddingL),
          const ProfileMenuSection(),
        ],
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final dynamic user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: user.profileImageUrl != null
                  ? NetworkImage(user.profileImageUrl!)
                  : null,
              child: user.profileImageUrl == null
                  ? Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 24),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (user.joinedAt != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Member since ${_formatDate(user.joinedAt!)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.year}';
  }
}

class ProfileStats extends StatelessWidget {
  const ProfileStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderViewModel>(
      builder: (context, orderViewModel, child) {
        final totalSpent = orderViewModel.getTotalSpent();
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Total Orders',
                      '${orderViewModel.getTotalOrderCount()}',
                      Icons.shopping_bag,
                    ),
                    _buildStatItem(
                      'Total Spent',
                      '₩${totalSpent.toStringAsFixed(0)}',
                      Icons.attach_money,
                    ),
                    _buildStatItem(
                      'Active Orders',
                      '${orderViewModel.getActiveOrders().length}',
                      Icons.local_shipping,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class ProfileMenuSection extends StatelessWidget {
  const ProfileMenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileMenuItem(
          icon: Icons.location_on,
          title: 'My Addresses',
          onTap: () => UIHelper.navigateTo(const AddressListPage(), context: context),
        ),
        ProfileMenuItem(
          icon: Icons.history,
          title: 'Order History',
          onTap: () => _showComingSoon(context),
        ),
        ProfileMenuItem(
          icon: Icons.settings,
          title: '설정',
          onTap: () => UIHelper.navigateTo(const SettingsPage(), context: context),
        ),
        ProfileMenuItem(
          icon: Icons.help,
          title: 'Help & Support',
          onTap: () => _showComingSoon(context),
        ),
        ProfileMenuItem(
          icon: Icons.logout,
          title: 'Sign Out',
          textColor: Colors.red,
          onTap: () => _showSignOutDialog(context),
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context) {
    UIHelper.showSnack('Coming soon!', context: context);
  }

  void _showSignOutDialog(BuildContext context) async {
    final confirmed = await UIHelper.showConfirmDialog(
      context: context,
      title: 'Sign Out',
      content: 'Are you sure you want to sign out?',
      confirmText: 'Sign Out',
      cancelText: 'Cancel',
    );
    
    if (confirmed) {
      context.read<AuthViewModel>().signOut(context);
    }
  }
}

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: textColor),
        title: Text(
          title,
          style: TextStyle(color: textColor),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

