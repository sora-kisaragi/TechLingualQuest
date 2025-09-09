import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/auth_service.dart';
import '../../../shared/services/dynamic_localization_service.dart';
import '../../../shared/widgets/dynamic_language_selector.dart';

/// ユーザープログレスとアクティビティを表示するダッシュボードページ
///
/// 認証が必要なページで、ユーザーの学習進捗や統計情報を表示する
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationsAsync = ref.watch(appTranslationsProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: translationsAsync.when(
          data: (translations) => Text(
            translations['dashboard_title'] ?? 'Dashboard',
          ),
          loading: () => const Text('Dashboard'),
          error: (_, __) => const Text('Dashboard'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: translationsAsync.when(
        data: (translations) => _buildDashboardContent(context, ref, currentUser, translations),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context, 
    WidgetRef ref, 
    AuthUser? user,
    Map<String, String> translations,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User welcome section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translations['welcome_message'] ?? 'Welcome back!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.name ?? 'User',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Level: ${user?.level.name ?? 'Unknown'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Progress overview
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translations['progress_overview'] ?? 'Progress Overview',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildProgressCard(
                          context,
                          Icons.book,
                          translations['vocabulary_learned'] ?? 'Vocabulary',
                          '0', // Placeholder
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildProgressCard(
                          context,
                          Icons.flag,
                          translations['quests_completed'] ?? 'Quests',
                          '0', // Placeholder
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Recent activity
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translations['recent_activity'] ?? 'Recent Activity',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  const ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('No recent activity'),
                    subtitle: Text('Start learning to see your progress here'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}