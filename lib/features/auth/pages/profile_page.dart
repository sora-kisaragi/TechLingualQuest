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
              child: currentUser.profileImageUrl != null
                  ? ClipOval(
                      child: Image.network(
                        currentUser.profileImageUrl!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.deepPurple,
                        ),
                      ),
                    )
                  : const Icon(
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
                      translations.getSync('accountInformation'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // User ID
                    _buildInfoRow(
                      translations.getSync('userId'),
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
                      currentUser.name ?? translations.getSync('notSet'),
                      Icons.person,
                    ),
                    const SizedBox(height: 12),

                    // Level
                    _buildInfoRow(
                      translations.getSync('currentLevel'),
                      _getLevelText(currentUser.level, translations),
                      Icons.school,
                    ),
                    const SizedBox(height: 12),

                    // Interests
                    if (currentUser.interests != null &&
                        currentUser.interests!.isNotEmpty) ...[
                      _buildInterestsRow(
                        translations.getSync('techInterests'),
                        currentUser.interests!,
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Bio
                    if (currentUser.bio != null &&
                        currentUser.bio!.isNotEmpty) ...[
                      _buildInfoRow(
                        translations.getSync('bio'),
                        currentUser.bio!,
                        Icons.description,
                        maxLines: 3,
                      ),
                    ],
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
                    context.go('/auth/profile/edit');
                  },
                  icon: const Icon(Icons.edit),
                  label: Text(translations.getSync('editProfile')),
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
                        content: Text(
                            'Settings feature coming soon'), // TODO: Add to translations
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
                  onPressed: () =>
                      _showLogoutDialog(context, ref, translations),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Logout',
                      style: TextStyle(
                          color: Colors.red)), // TODO: Add to translations
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

  Widget _buildInfoRow(String label, String value, IconData icon,
      {int maxLines = 1}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
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
                maxLines: maxLines,
                overflow: maxLines > 1 ? TextOverflow.ellipsis : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInterestsRow(String label, List<String> interests) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.interests, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
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
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: interests
                    .map((interest) => Chip(
                          label: Text(
                            interest,
                            style: const TextStyle(fontSize: 12),
                          ),
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getLevelText(UserLevel? level, AppTranslations translations) {
    if (level == null) return translations.getSync('notSet');

    switch (level) {
      case UserLevel.beginner:
        return translations.getSync('beginnerLevel');
      case UserLevel.intermediate:
        return translations.getSync('intermediateLevel');
      case UserLevel.advanced:
        return translations.getSync('advancedLevel');
    }
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
          content: const Text(
              'Are you sure you want to logout?'), // TODO: Add to translations
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
