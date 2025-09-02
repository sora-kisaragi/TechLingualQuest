import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/utils/logger.dart';

/// 一貫したエラーハンドリングとローディング状態のためのベース通知クラス
/// 
/// アプリ内のすべての状態通知に共通の機能を提供する
/// LLD設計書に基づく
abstract class BaseNotifier<T> extends StateNotifier<AsyncValue<T>> {
  BaseNotifier() : super(const AsyncValue.loading());
  
  /// 一貫したエラーハンドリングで非同期操作を実行
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
  
  /// ローディング状態を変更せずに操作を実行
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