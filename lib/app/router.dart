import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/dashboard/pages/home_page.dart';
import '../features/auth/pages/auth_page.dart';
import '../features/vocabulary/pages/vocabulary_page.dart';
import '../features/quests/pages/quests_page.dart';
import '../shared/utils/logger.dart';

/// Application router configuration using go_router
/// 
/// Defines routes and navigation structure for the app
class AppRouter {
  static final GoRouter _router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: 'home',
        builder: (BuildContext context, GoRouterState state) {
          return const HomePage();
        },
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (BuildContext context, GoRouterState state) {
          return const AuthPage();
        },
      ),
      GoRoute(
        path: '/vocabulary',
        name: 'vocabulary',
        builder: (BuildContext context, GoRouterState state) {
          return const VocabularyPage();
        },
      ),
      GoRoute(
        path: '/quests',
        name: 'quests',
        builder: (BuildContext context, GoRouterState state) {
          return const QuestsPage();
        },
      ),
    ],
    errorBuilder: (context, state) => _ErrorPage(error: state.error.toString()),
    redirect: (context, state) {
      AppLogger.debug('Navigating to: ${state.location}');
      return null; // No redirect logic for now
    },
  );
  
  /// Get the router instance
  static GoRouter get router => _router;
}

/// Error page for handling navigation errors
class _ErrorPage extends StatelessWidget {
  const _ErrorPage({required this.error});
  
  final String error;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Page not found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}