import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/services/dynamic_localization_service.dart';

/// ユーザーログインと登録のための認証ページ
///
/// これは将来の認証実装のためのプレースホルダーページです
class AuthPage extends ConsumerWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationsAsync = ref.watch(appTranslationsProvider);

    return translationsAsync.when(
      data: (translations) => _buildAuthContent(context, translations),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Failed to load translations: $error')),
      ),
    );
  }

  Widget _buildAuthContent(BuildContext context, AppTranslations translations) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: translations.profile,
          builder: (context, snapshot) {
            return Text(snapshot.data ?? 'Profile');
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
            const Icon(Icons.person, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 20),
            FutureBuilder<String>(
              future: translations.authentication,
              builder: (context, snapshot) {
                return Text(
                  snapshot.data ?? 'Authentication',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            FutureBuilder<String>(
              future: translations.authDescription,
              builder: (context, snapshot) {
                return Text(
                  snapshot.data ??
                      'User authentication will be implemented here',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
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
