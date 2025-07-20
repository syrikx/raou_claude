import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../viewmodels/order_view_model.dart';
import '../../viewmodels/address_view_model.dart';
import '../address/address_list_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Custom header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.inversePrimary,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Text(
            'Profile',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Body
        Expanded(
          child: Consumer<AuthViewModel>(
            builder: (context, authViewModel, child) {
              if (!authViewModel.isAuthenticated) {
                return const SignInView();
              }

              return UserProfileView(user: authViewModel.currentUser!);
            },
          ),
        ),
      ],
    );
  }
}

class SignInView extends StatelessWidget {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_circle,
              size: 100,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            const Text(
              'Welcome to Raou',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sign in to access your orders, addresses, and preferences',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            Consumer<AuthViewModel>(
              builder: (context, authViewModel, child) {
                return Column(
                  children: [
                    // Google Sign-In 버튼
                    if (authViewModel.isGoogleSignInAvailable) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: authViewModel.isLoading
                              ? null
                              : () => _signInWithGoogle(context),
                          icon: authViewModel.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.login, color: Colors.red),
                          label: Text(
                            authViewModel.isLoading ? 'Signing in...' : 'Sign in with Google',
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            side: const BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    // Apple Sign-In 버튼 (iOS만)
                    if (authViewModel.isAppleSignInAvailable) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: authViewModel.isLoading
                              ? null
                              : () => _signInWithApple(context),
                          icon: const Icon(Icons.apple, color: Colors.white),
                          label: const Text('Sign in with Apple'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    // 테스트 로그인 버튼 (개발용)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: authViewModel.isLoading
                            ? null
                            : () => _signInAsMockUser(context),
                        icon: const Icon(Icons.person),
                        label: const Text('Test Login (Mock User)'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    
                    // Firebase 상태 표시
                    const SizedBox(height: 16),
                    Text(
                      authViewModel.isFirebaseAvailable 
                          ? 'Firebase Auth: Enabled' 
                          : 'Firebase Auth: Disabled (Mock Mode)',
                      style: TextStyle(
                        fontSize: 12,
                        color: authViewModel.isFirebaseAvailable 
                            ? Colors.green 
                            : Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
            if (context.watch<AuthViewModel>().hasError)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  context.watch<AuthViewModel>().error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ProfileHeader(user: user),
          const SizedBox(height: 32),
          const ProfileStats(),
          const SizedBox(height: 32),
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
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddressListPage()),
          ),
        ),
        ProfileMenuItem(
          icon: Icons.history,
          title: 'Order History',
          onTap: () => _showComingSoon(context),
        ),
        ProfileMenuItem(
          icon: Icons.settings,
          title: 'Settings',
          onTap: () => _showComingSoon(context),
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon!')),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthViewModel>().signOut(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
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