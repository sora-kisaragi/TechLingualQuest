import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/auth_service.dart';
import '../../../app/routes.dart';
import '../../../shared/services/dynamic_localization_service.dart';
import '../../../shared/utils/logger.dart';

/// ユーザーログインページ
///
/// メールアドレスとパスワードでログインする
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// メールアドレスのバリデーション
  String? _validateEmail(String? value, AppTranslations translations) {
    if (value == null || value.isEmpty) {
      return translations.getSync('emailRequired');
    }
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return translations.getSync('enterValidEmail');
    }
    return null;
  }

  /// パスワードのバリデーション
  String? _validatePassword(String? value, AppTranslations translations) {
    if (value == null || value.isEmpty) {
      return translations.getSync('passwordRequired');
    }
    if (value.length < 6) {
      return translations.getSync('passwordLoginMinLength');
    }
    return null;
  }

  /// ログイン処理を実行
  Future<void> _login(AppTranslations translations) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    AppLogger.info('Attempting user login');

    try {
      final authService = ref.read(authServiceProvider.notifier);
      final success = await authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success) {
        AppLogger.info('User login successful');
        if (mounted) {
          // ログイン成功後はホームページに遷移
          context.go(AppRoutes.home);
        }
      } else {
        setState(() {
          _errorMessage = translations.getSync('loginFailed');
        });
      }
    } catch (e, stackTrace) {
      AppLogger.error('Login error', e, stackTrace);
      setState(() {
        _errorMessage = translations.getSync('loginError');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final translationsAsync = ref.watch(appTranslationsProvider);
    final authState = ref.watch(authServiceProvider);

    return translationsAsync.when(
      data: (translations) =>
          _buildLoginContent(context, authState, translations),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Failed to load translations: $error')),
      ),
    );
  }

  Widget _buildLoginContent(
      BuildContext context, AuthState authState, AppTranslations translations) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translations.getSync('login')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ヘッダー
              const SizedBox(height: 40),
              Text(
                translations.getSync('welcomeBack'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                translations.getSync('signInToContinue'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // メールアドレス入力フィールド
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: translations.getSync('emailAddress'),
                  hintText: translations.getSync('emailPlaceholder'),
                  prefixIcon: const Icon(Icons.email),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => _validateEmail(value, translations),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // パスワード入力フィールド
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: translations.getSync('password'),
                  hintText: translations.getSync('enterPassword'),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
                obscureText: !_isPasswordVisible,
                validator: (value) => _validatePassword(value, translations),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _login(translations),
              ),
              const SizedBox(height: 16),

              // 記憶・パスワード忘れた
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                  ),
                  Text(translations.getSync('rememberLogin')),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      // パスワードリセットページに遷移
                      context.go(AppRoutes.passwordReset);
                    },
                    child: Text(translations.getSync('forgotPassword')),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // エラーメッセージ表示
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),

              // ログインボタン
              ElevatedButton(
                onPressed:
                    authState.isLoading ? null : () => _login(translations),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: authState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        translations.getSync('login'),
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
              const SizedBox(height: 32),

              // ソーシャルログイン（将来的な実装用プレースホルダー）
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      translations.getSync('or'),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),
              const SizedBox(height: 24),

              // Googleログインボタン（将来の実装用）
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(translations.getSync('googleLoginNotReady')),
                    ),
                  );
                },
                icon: Image.asset(
                  'assets/images/google_logo.png',
                  height: 20,
                  width: 20,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.login, size: 20),
                ),
                label: Text(translations.getSync('signInWithGoogle')),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // 新規登録リンク
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(translations.getSync('noAccount')),
                  TextButton(
                    onPressed: () => context.go('/auth/register'),
                    child: Text(translations.getSync('signUp')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
