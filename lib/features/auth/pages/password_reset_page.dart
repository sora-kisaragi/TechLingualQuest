import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/auth_service.dart';
import '../../../app/routes.dart';
import '../../../shared/services/dynamic_localization_service.dart';
import '../../../shared/utils/logger.dart';

/// パスワードリセットページ
///
/// メールアドレスを入力してパスワードリセットリンクを送信する
class PasswordResetPage extends ConsumerStatefulWidget {
  const PasswordResetPage({super.key});

  @override
  ConsumerState<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends ConsumerState<PasswordResetPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _emailSent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
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

  /// パスワードリセット処理を実行
  Future<void> _sendResetEmail(AppTranslations translations) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    AppLogger.info('Attempting password reset for email: ${_emailController.text.trim()}');

    try {
      final authService = ref.read(authServiceProvider.notifier);
      final success = await authService.requestPasswordReset(
        _emailController.text.trim(),
      );

      if (success) {
        setState(() {
          _emailSent = true;
        });
        AppLogger.info('Password reset email sent successfully');
      } else {
        setState(() {
          _errorMessage = translations.getSync('passwordResetError');
        });
      }
    } catch (e, stackTrace) {
      AppLogger.error('Password reset error', e, stackTrace);
      setState(() {
        _errorMessage = translations.getSync('passwordResetError');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final translationsAsync = ref.watch(appTranslationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: translationsAsync.when(
          data: (translations) => Text(translations.getSync('resetPassword')),
          loading: () => const Text('Reset Password'),
          error: (error, stack) => const Text('Reset Password'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.login),
        ),
      ),
      body: translationsAsync.when(
        data: (translations) => _buildBody(context, translations),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading translations: $error'),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppTranslations translations) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              
              // アイコンとタイトル
              const Icon(
                Icons.lock_reset,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              
              if (!_emailSent) ...[
                // パスワードリセット説明
                Text(
                  translations.getSync('forgotPasswordTitle'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                Text(
                  translations.getSync('passwordResetDescription'),
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
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _sendResetEmail(translations),
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

                // 送信ボタン
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _sendResetEmail(translations),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          translations.getSync('sendResetLink'),
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ] else ...[
                // メール送信完了画面
                Text(
                  translations.getSync('resetEmailSentTitle'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                Text(
                  translations.getSync('resetEmailSentDescription'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // 注意事項
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    border: Border.all(color: Colors.blue.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          translations.getSync('checkSpamFolder'),
                          style: TextStyle(color: Colors.blue.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
              
              const Spacer(),
              
              // ログインに戻る
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(translations.getSync('rememberPassword')),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: Text(translations.getSync('backToSignIn')),
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