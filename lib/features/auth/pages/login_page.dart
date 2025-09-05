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
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'メールアドレスは必須です';
    }
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return '有効なメールアドレスを入力してください';
    }
    return null;
  }

  /// パスワードのバリデーション
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'パスワードは必須です';
    }
    if (value.length < 6) {
      return 'パスワードは6文字以上で入力してください';
    }
    return null;
  }

  /// ログイン処理を実行
  Future<void> _login() async {
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
          _errorMessage = 'メールアドレスまたはパスワードが正しくありません。';
        });
      }
    } catch (e, stackTrace) {
      AppLogger.error('Login error', e, stackTrace);
      setState(() {
        _errorMessage = 'ログイン中にエラーが発生しました。';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final translationsAsync = ref.watch(appTranslationsProvider);
    final authState = ref.watch(authServiceProvider);

    return translationsAsync.when(
      data: (translations) => _buildLoginContent(context, authState),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Failed to load translations: $error')),
      ),
    );
  }

  Widget _buildLoginContent(BuildContext context, AuthState authState) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ログイン'),
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
                'おかえりなさい',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'アカウントにサインインして学習を続けましょう',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // メールアドレス入力フィールド
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'メールアドレス',
                  hintText: 'your@email.com',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // パスワード入力フィールド
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'パスワード',
                  hintText: 'パスワードを入力',
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
                validator: _validatePassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _login(),
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
                  const Text('ログイン状態を記憶'),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      // 将来的にパスワードリセット機能を実装
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('パスワードリセット機能は準備中です'),
                        ),
                      );
                    },
                    child: const Text('パスワードを忘れた？'),
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
                onPressed: authState.isLoading ? null : _login,
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
                    : const Text(
                        'ログイン',
                        style: TextStyle(fontSize: 16),
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
                      'または',
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
                    const SnackBar(
                      content: Text('Googleログイン機能は準備中です'),
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
                label: const Text('Googleでログイン'),
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
                  const Text('アカウントをお持ちでない方は'),
                  TextButton(
                    onPressed: () => context.go('/auth/register'),
                    child: const Text('新規登録'),
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
