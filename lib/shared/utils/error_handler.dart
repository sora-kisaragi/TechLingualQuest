import 'package:flutter/material.dart';
import 'logger.dart';

/// アプリケーション全体のエラーハンドリングユーティリティ
/// 
/// 一貫したエラーハンドリングとユーザーフレンドリーなエラーメッセージを提供する
class ErrorHandler {
  /// オプションのユーザー通知付きでエラーをハンドリングしてログ
  static void handleError(
    Object error,
    StackTrace stackTrace, {
    String? userMessage,
    BuildContext? context,
  }) {
    // エラーをログ
    AppLogger.error('Error occurred: $error', error, stackTrace);
    
    // コンテキストが提供されている場合はユーザーフレンドリーなメッセージを表示
    if (context != null && context.mounted) {
      final message = userMessage ?? _getErrorMessage(error);
      _showErrorSnackBar(context, message);
    }
  }
  
  /// 例外からユーザーフレンドリーなエラーメッセージを取得
  static String _getErrorMessage(Object error) {
    if (error.toString().contains('database')) {
      return 'データベースエラーが発生しました。後でもう一度お試しください。';
    } else if (error.toString().contains('network') || 
               error.toString().contains('connection')) {
      return 'ネットワークエラーが発生しました。接続を確認してください。';
    } else {
      return '予期しないエラーが発生しました。後でもう一度お試しください。';
    }
  }
  
  /// SnackBarでユーザーにエラーメッセージを表示
  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: '閉じる',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}

/// AsyncValueの一貫したエラーハンドリングのための拡張
extension AsyncValueErrorHandling<T> on AsyncValue<T> {
  /// 一貫したエラー表示でエラーをハンドリング
  Widget when({
    required Widget Function(T data) data,
    required Widget Function() loading,
    Widget Function(Object error, StackTrace stackTrace)? error,
  }) {
    return super.when(
      data: data,
      loading: loading,
      error: error ?? (err, stack) => _DefaultErrorWidget(error: err),
    );
  }
}

/// AsyncValueエラーをハンドリングするためのデフォルトエラーウィジェット
class _DefaultErrorWidget extends StatelessWidget {
  const _DefaultErrorWidget({required this.error});
  
  final Object error;
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            ErrorHandler._getErrorMessage(error),
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // 実際のアプリでは、これは再試行をトリガーするかもしれません
            },
            child: const Text('再試行'),
          ),
        ],
      ),
    );
  }
}