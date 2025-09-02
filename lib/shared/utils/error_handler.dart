import 'package:flutter/material.dart';
import 'logger.dart';

/// Application-wide error handling utilities
/// 
/// Provides consistent error handling and user-friendly error messages
class ErrorHandler {
  /// Handle and log errors with optional user notification
  static void handleError(
    Object error,
    StackTrace stackTrace, {
    String? userMessage,
    BuildContext? context,
  }) {
    // Log the error
    AppLogger.error('Error occurred: $error', error, stackTrace);
    
    // Show user-friendly message if context is provided
    if (context != null && context.mounted) {
      final message = userMessage ?? _getErrorMessage(error);
      _showErrorSnackBar(context, message);
    }
  }
  
  /// Get user-friendly error message from exception
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
  
  /// Show error message to user via SnackBar
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

/// Extension for AsyncValue to handle errors consistently
extension AsyncValueErrorHandling<T> on AsyncValue<T> {
  /// Handle errors with consistent error display
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

/// Default error widget for handling AsyncValue errors
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
              // In a real app, this might trigger a retry
            },
            child: const Text('再試行'),
          ),
        ],
      ),
    );
  }
}