import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/auth_service.dart';
import '../../../shared/services/dynamic_localization_service.dart';
import '../../../shared/utils/logger.dart';

/// ユーザープロファイルページ
///
/// ログインしたユーザーの基本情報表示とアカウント管理機能を提供
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationsAsync = ref.watch(appTranslationsProvider);
    final authState = ref.watch(authServiceProvider);
    final currentUser = authState.user;

    return translationsAsync.when(
      data: (translations) => _buildProfileContent(
        context,
        ref,
        translations,
        authState,
        currentUser,
      ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Failed to load translations: $error')),
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    WidgetRef ref,
    AppTranslations translations,
    AuthState authState,
    AuthUser? currentUser,
  ) {
    // If not authenticated, redirect to auth page
    if (!authState.isAuthenticated || currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/auth');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(translations.getSync('profile')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Logout button in app bar
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout', // TODO: Add to translations
            onPressed: () => _showLogoutDialog(context, ref, translations),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile header
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.deepPurple.shade100,
              child: const Icon(
                Icons.person,
                size: 80,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),
            
            // User name
            Text(
              currentUser.name ?? currentUser.email.split('@').first,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // User email
            Text(
              currentUser.email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 40),

            // Profile information card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Information', // TODO: Add to translations
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // User ID
                    _buildInfoRow(
                      'User ID', // TODO: Add to translations
                      currentUser.id,
                      Icons.badge,
                    ),
                    const SizedBox(height: 12),
                    
                    // Email
                    _buildInfoRow(
                      translations.getSync('emailAddress'),
                      currentUser.email,
                      Icons.email,
                    ),
                    const SizedBox(height: 12),
                    
                    // Name
                    _buildInfoRow(
                      translations.getSync('name'),
                      currentUser.name ?? 'Not set', // TODO: Add to translations
                      Icons.person,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Action buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Edit profile button (placeholder)
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile editing feature coming soon'), // TODO: Add to translations
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'), // TODO: Add to translations
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Settings button (placeholder)
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Settings feature coming soon'), // TODO: Add to translations
                      ),
                    );
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text('Settings'), // TODO: Add to translations
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Logout button
                TextButton.icon(
                  onPressed: () => _showLogoutDialog(context, ref, translations),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Logout', style: TextStyle(color: Colors.red)), // TODO: Add to translations
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showLogoutDialog(
    BuildContext context,
    WidgetRef ref,
    AppTranslations translations,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'), // TODO: Add to translations
          content: const Text('Are you sure you want to logout?'), // TODO: Add to translations
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'), // TODO: Add to translations
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _logout(context, ref);
              },
              child: const Text('Logout'), // TODO: Add to translations
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    AppLogger.info('User logout initiated from profile page');
    
    final authService = ref.read(authServiceProvider.notifier);
    await authService.logout();
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully logged out'), // TODO: Add to translations
          duration: Duration(seconds: 2),
        ),
      );
      
      // Navigate back to home page
      context.go('/');
    }
  }
}