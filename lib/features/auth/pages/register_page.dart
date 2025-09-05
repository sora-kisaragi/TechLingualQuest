import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/auth_service.dart';
import '../../../app/routes.dart';
import '../../../shared/services/dynamic_localization_service.dart';
import '../../../shared/utils/logger.dart';

/// ユーザー登録ページ
///
/// メール、パスワード、名前を入力してアカウントを作成する
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreedToTerms = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
    if (value.length < 8) {
      return 'パスワードは8文字以上で入力してください';
    }
    // 英数字組み合わせチェック
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
    final hasDigit = RegExp(r'[0-9]').hasMatch(value);
    if (!hasLetter || !hasDigit) {
      return 'パスワードは英字と数字を組み合わせてください';
    }
    return null;
  }

  /// パスワード確認のバリデーション
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'パスワードの確認は必須です';
    }
    if (value != _passwordController.text) {
      return 'パスワードが一致しません';
    }
    return null;
  }

  /// 名前のバリデーション
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return '名前は必須です';
    }
    if (value.length > 50) {
      return '名前は50文字以内で入力してください';
    }
    return null;
  }

  /// 登録処理を実行
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreedToTerms) {
      setState(() {
        _errorMessage = '利用規約とプライバシーポリシーに同意してください';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    AppLogger.info('Attempting user registration');

    try {
      final authService = ref.read(authServiceProvider.notifier);
      final success = await authService.register(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );

      if (success) {
        AppLogger.info('User registration successful');
        if (mounted) {
          // 登録成功後はホームページに遷移
          context.go(AppRoutes.home);
        }
      } else {
        setState(() {
          _errorMessage = '登録に失敗しました。もう一度お試しください。';
        });
      }
    } catch (e, stackTrace) {
      AppLogger.error('Registration error', e, stackTrace);
      setState(() {
        _errorMessage = '登録中にエラーが発生しました。';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final translationsAsync = ref.watch(appTranslationsProvider);
    final authState = ref.watch(authServiceProvider);

    return translationsAsync.when(
      data: (translations) => _buildRegisterContent(context, authState),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Failed to load translations: $error')),
      ),
    );
  }

  Widget _buildRegisterContent(BuildContext context, AuthState authState) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('アカウント作成'),
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
              const SizedBox(height: 20),
              Text(
                'TechLingual Questへようこそ',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'アカウントを作成して学習を始めましょう',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // 名前入力フィールド
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '名前',
                  hintText: 'あなたの名前を入力してください',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: _validateName,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

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
                  hintText: '8文字以上の英数字',
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
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // パスワード確認フィールド
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'パスワード確認',
                  hintText: 'もう一度パスワードを入力',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
                obscureText: !_isConfirmPasswordVisible,
                validator: _validateConfirmPassword,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 24),

              // 利用規約同意チェックボックス
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreedToTerms = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _agreedToTerms = !_agreedToTerms;
                        });
                      },
                      child: const Text(
                        '利用規約とプライバシーポリシーに同意します',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // エラーメッセージ表示
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
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
              const SizedBox(height: 16),

              // 登録ボタン
              ElevatedButton(
                onPressed: authState.isLoading ? null : _register,
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
                        'アカウントを作成',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
              const SizedBox(height: 24),

              // ログインリンク
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('すでにアカウントをお持ちですか？'),
                  TextButton(
                    onPressed: () => context.go('/auth/login'),
                    child: const Text('ログイン'),
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
