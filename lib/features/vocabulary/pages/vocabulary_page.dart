import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/services/dynamic_localization_service.dart';

/// 語彙学習ページ
///
/// これは語彙管理機能のためのプレースホルダーページです
class VocabularyPage extends ConsumerWidget {
  const VocabularyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationsAsync = ref.watch(appTranslationsProvider);

    return translationsAsync.when(
      data: (translations) => _buildVocabularyContent(context, translations),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Failed to load translations: $error')),
      ),
    );
  }

  Widget _buildVocabularyContent(
    BuildContext context,
    AppTranslations translations,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: translations.vocabulary,
          builder: (context, snapshot) {
            return Text(snapshot.data ?? 'Vocabulary');
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.book, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 20),
            FutureBuilder<String>(
              future: translations.vocabularyLearning,
              builder: (context, snapshot) {
                return Text(
                  snapshot.data ?? 'Vocabulary Learning',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            FutureBuilder<String>(
              future: translations.vocabularyDescription,
              builder: (context, snapshot) {
                return Text(
                  snapshot.data ??
                      'Vocabulary cards and learning features will be implemented here',
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
