import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/auth_service.dart';
import '../../../shared/services/dynamic_localization_service.dart';
import '../../../shared/widgets/dynamic_language_selector.dart';
import '../../../shared/utils/navigation_helper.dart';

/// メインのクエストインターフェースを表示するホームページウィジェット
///
/// これはアプリのメインダッシュボードページです
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _xpCounter = 0;

  void _earnXp() {
    setState(() {
      _xpCounter += 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    final translationsAsync = ref.watch(appTranslationsProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    return translationsAsync.when(
      data: (translations) => _buildHomeContent(context, translations, isAuthenticated),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Failed to load translations: $error')),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, AppTranslations translations, bool isAuthenticated) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: FutureBuilder<String>(
          future: translations.appTitle,
          builder: (context, snapshot) {
            return Text(snapshot.data ?? 'TechLingual Quest');
          },
        ),
        actions: [
          const DynamicLanguageSelector(),
          // Add logout button if authenticated
          if (isAuthenticated)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout', // TODO: Add to translations
              onPressed: () async {
                final authService = ref.read(authServiceProvider.notifier);
                await authService.logout();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Successfully logged out'), // TODO: Add to translations
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.school, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 20),
            FutureBuilder<String>(
              future: translations.welcomeMessage,
              builder: (context, snapshot) {
                return Text(
                  snapshot.data ?? 'Welcome to TechLingual Quest!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            FutureBuilder<String>(
              future: translations.gamifiedJourney,
              builder: (context, snapshot) {
                return Text(
                  snapshot.data ??
                      'Your gamified journey to master technical English',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                );
              },
            ),
            const SizedBox(height: 30),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FutureBuilder<String>(
                          future: translations.xpLabel,
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data ?? 'XP:',
                              style: const TextStyle(fontSize: 18),
                            );
                          },
                        ),
                        Text(
                          '$_xpCounter',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: (_xpCounter % 100) / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            _buildNavigationButtons(context, translations, isAuthenticated),
            const SizedBox(height: 30),
            FutureBuilder<String>(
              future: translations.featuresTitle,
              builder: (context, snapshot) {
                return Text(
                  snapshot.data ?? 'Features:',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: _buildFeaturesList(translations),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _earnXp,
        tooltip: 'Earn XP', // Will be replaced with dynamic translation
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFeaturesList(AppTranslations translations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<String>(
          future: translations.feature1,
          builder: (context, snapshot) => Text(snapshot.data ?? ''),
        ),
        FutureBuilder<String>(
          future: translations.feature2,
          builder: (context, snapshot) => Text(snapshot.data ?? ''),
        ),
        FutureBuilder<String>(
          future: translations.feature3,
          builder: (context, snapshot) => Text(snapshot.data ?? ''),
        ),
        FutureBuilder<String>(
          future: translations.feature4,
          builder: (context, snapshot) => Text(snapshot.data ?? ''),
        ),
        FutureBuilder<String>(
          future: translations.feature5,
          builder: (context, snapshot) => Text(snapshot.data ?? ''),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    AppTranslations translations,
    bool isAuthenticated,
  ) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        FutureBuilder<String>(
          future: translations.vocabulary,
          builder: (context, snapshot) {
            return ElevatedButton.icon(
              onPressed: () => NavigationHelper.goVocabulary(context),
              icon: const Icon(Icons.book),
              label: Text(snapshot.data ?? 'Vocabulary'),
            );
          },
        ),
        FutureBuilder<String>(
          future: translations.quests,
          builder: (context, snapshot) {
            return ElevatedButton.icon(
              onPressed: () => NavigationHelper.goQuests(context),
              icon: const Icon(Icons.flag),
              label: Text(snapshot.data ?? 'Quests'),
            );
          },
        ),
        // Show different profile button based on auth state
        if (isAuthenticated)
          FutureBuilder<String>(
            future: translations.profile,
            builder: (context, snapshot) {
              return ElevatedButton.icon(
                onPressed: () => NavigationHelper.goProfile(context),
                icon: const Icon(Icons.person),
                label: Text(snapshot.data ?? 'Profile'),
              );
            },
          )
        else
          FutureBuilder<String>(
            future: translations.profile,
            builder: (context, snapshot) {
              return OutlinedButton.icon(
                onPressed: () => NavigationHelper.goAuth(context),
                icon: const Icon(Icons.login),
                label: Text(snapshot.data ?? 'Login'),
              );
            },
          ),
      ],
    );
  }
}
