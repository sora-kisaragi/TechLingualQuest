import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../../shared/widgets/language_selector.dart';

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
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(l10n.appTitle),
        actions: const [
          LanguageSelector(),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.school,
              size: 80,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 20),
            Text(
              l10n.welcomeMessage,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.gamifiedJourney,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
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
                        Text(l10n.xpLabel, style: const TextStyle(fontSize: 18)),
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
            _buildNavigationButtons(context, l10n),
            const SizedBox(height: 30),
            Text(
              l10n.featuresTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.feature1),
                  Text(l10n.feature2),
                  Text(l10n.feature3),
                  Text(l10n.feature4),
                  Text(l10n.feature5),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _earnXp,
        tooltip: l10n.earnXpTooltip,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context, AppLocalizations l10n) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ElevatedButton.icon(
          onPressed: () => context.go('/vocabulary'),
          icon: const Icon(Icons.book),
          label: Text(l10n.vocabulary),
        ),
        ElevatedButton.icon(
          onPressed: () => context.go('/quests'),
          icon: const Icon(Icons.flag),
          label: Text(l10n.quests),
        ),
        ElevatedButton.icon(
          onPressed: () => context.go('/auth'),
          icon: const Icon(Icons.person),
          label: Text(l10n.profile),
        ),
      ],
    );
  }
}
