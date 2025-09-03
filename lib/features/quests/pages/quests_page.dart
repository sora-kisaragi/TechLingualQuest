import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/services/dynamic_localization_service.dart';
import '../../../shared/utils/navigation_helper.dart';

/// ゲーミフィケーション機能のためのクエストページ
///
/// これはクエスト管理機能のためのプレースホルダーページです
class QuestsPage extends ConsumerWidget {
  const QuestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationsAsync = ref.watch(appTranslationsProvider);

    return translationsAsync.when(
      data: (translations) => _buildQuestsContent(context, translations),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Failed to load translations: $error')),
      ),
    );
  }

  Widget _buildQuestsContent(
    BuildContext context,
    AppTranslations translations,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: translations.quests,
          builder: (context, snapshot) {
            return Text(snapshot.data ?? 'Quests');
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => NavigationHelper.goBack(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.flag, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 20),
            FutureBuilder<String>(
              future: translations.dailyQuests,
              builder: (context, snapshot) {
                return Text(
                  snapshot.data ?? 'Daily Quests',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            FutureBuilder<String>(
              future: translations.questsDescription,
              builder: (context, snapshot) {
                return Text(
                  snapshot.data ??
                      'Quest system and gamification features will be implemented here',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
