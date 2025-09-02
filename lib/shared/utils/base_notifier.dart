import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/utils/logger.dart';

/// Base notifier class for consistent error handling and loading states
/// 
/// Provides common functionality for all state notifiers in the app
/// Based on the LLD design document
abstract class BaseNotifier<T> extends StateNotifier<AsyncValue<T>> {
  BaseNotifier() : super(const AsyncValue.loading());
  
  /// Execute an async operation with consistent error handling
  Future<void> execute(Future<T> Function() operation) async {
    state = const AsyncValue.loading();
    try {
      final result = await operation();
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      AppLogger.error('Error in ${runtimeType}', error, stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  /// Execute an operation without changing loading state
  Future<void> executeWithoutLoading(Future<T> Function() operation) async {
    try {
      final result = await operation();
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      AppLogger.error('Error in ${runtimeType}', error, stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }
}