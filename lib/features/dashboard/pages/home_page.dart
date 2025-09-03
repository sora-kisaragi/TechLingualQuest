import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// メインのクエストインターフェースを表示するホームページウィジェット
///
/// これはアプリのメインダッシュボードページです
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _xpCounter = 0;

  void _earnXp() {
    setState(() {
      _xpCounter += 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('TechLingual Quest'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.school, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 20),
            const Text(
              'Welcome to TechLingual Quest!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your gamified journey to master technical English',
              style: TextStyle(fontSize: 16),
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
                        const Text('XP:', style: TextStyle(fontSize: 18)),
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
            _buildNavigationButtons(context),
            const SizedBox(height: 30),
            const Text(
              'Features:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Daily quests and challenges'),
                  Text('• Vocabulary building with spaced repetition'),
                  Text('• Technical article summaries'),
                  Text('• Progress tracking and achievements'),
                  Text('• AI-powered conversation practice'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _earnXp,
        tooltip: 'Earn XP',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ElevatedButton.icon(
          onPressed: () => context.go('/vocabulary'),
          icon: const Icon(Icons.book),
          label: const Text('Vocabulary'),
        ),
        ElevatedButton.icon(
          onPressed: () => context.go('/quests'),
          icon: const Icon(Icons.flag),
          label: const Text('Quests'),
        ),
        ElevatedButton.icon(
          onPressed: () => context.go('/auth'),
          icon: const Icon(Icons.person),
          label: const Text('Profile'),
        ),
      ],
    );
  }
}
