import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

/// セキュアストレージサービス
/// 
/// 機密データ（トークン、認証情報）はFlutterSecureStorageに保存
/// 非機密データ（設定、キャッシュ）はSharedPreferencesに保存
class SecureStorageService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // セキュアストレージのキー定数
  static const String _keyAuthToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserCredentials = 'user_credentials';
  static const String _keySessionExpiry = 'session_expiry';

  // SharedPreferencesのキー定数
  static const String _keyLastLoginEmail = 'last_login_email';
  static const String _keyAuthStateCache = 'auth_state_cache';

  /// 認証トークンを保存
  /// Save authentication token securely
  static Future<void> saveAuthToken(String token) async {
    try {
      await _secureStorage.write(key: _keyAuthToken, value: token);
      AppLogger.info('Auth token saved securely');
    } catch (e) {
      AppLogger.error('Failed to save auth token', e);
      // テスト環境ではプラットフォーム例外をそのまま再スローして、テストで適切にハンドリングできるようにする
      // In test environments, rethrow platform exceptions so tests can handle them appropriately
      rethrow;
    }
  }

  /// 認証トークンを取得
  /// Get authentication token
  static Future<String?> getAuthToken() async {
    try {
      final token = await _secureStorage.read(key: _keyAuthToken);
      if (token != null) {
        AppLogger.info('Auth token retrieved');
      }
      return token;
    } catch (e) {
      AppLogger.error('Failed to retrieve auth token', e);
      return null;
    }
  }

  /// リフレッシュトークンを保存
  /// Save refresh token securely
  static Future<void> saveRefreshToken(String refreshToken) async {
    try {
      await _secureStorage.write(key: _keyRefreshToken, value: refreshToken);
      AppLogger.info('Refresh token saved securely');
    } catch (e) {
      AppLogger.error('Failed to save refresh token', e);
      // テスト環境ではプラットフォーム例外をそのまま再スローする
      rethrow;
    }
  }

  /// リフレッシュトークンを取得
  /// Get refresh token
  static Future<String?> getRefreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: _keyRefreshToken);
      if (refreshToken != null) {
        AppLogger.info('Refresh token retrieved');
      }
      return refreshToken;
    } catch (e) {
      AppLogger.error('Failed to retrieve refresh token', e);
      return null;
    }
  }

  /// ユーザー認証情報を保存
  /// Save user credentials (email/password hash for auto-login)
  static Future<void> saveUserCredentials(String email, String passwordHash) async {
    try {
      final credentials = {
        'email': email,
        'passwordHash': passwordHash,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      await _secureStorage.write(
        key: _keyUserCredentials,
        value: jsonEncode(credentials),
      );
      AppLogger.info('User credentials saved securely');
    } catch (e) {
      AppLogger.error('Failed to save user credentials', e);
      // テスト環境ではプラットフォーム例外をそのまま再スローする
      rethrow;
    }
  }

  /// ユーザー認証情報を取得
  /// Get user credentials
  static Future<Map<String, dynamic>?> getUserCredentials() async {
    try {
      final credentialsJson = await _secureStorage.read(key: _keyUserCredentials);
      if (credentialsJson != null) {
        final credentials = jsonDecode(credentialsJson) as Map<String, dynamic>;
        AppLogger.info('User credentials retrieved');
        return credentials;
      }
      return null;
    } catch (e) {
      AppLogger.error('Failed to retrieve user credentials', e);
      return null;
    }
  }

  /// セッション有効期限を保存
  /// Save session expiry timestamp
  static Future<void> saveSessionExpiry(DateTime expiryTime) async {
    try {
      await _secureStorage.write(
        key: _keySessionExpiry,
        value: expiryTime.millisecondsSinceEpoch.toString(),
      );
      AppLogger.info('Session expiry saved: ${expiryTime.toIso8601String()}');
    } catch (e) {
      AppLogger.error('Failed to save session expiry', e);
      // テスト環境ではプラットフォーム例外をそのまま再スローする
      rethrow;
    }
  }

  /// セッション有効期限を取得
  /// Get session expiry timestamp
  static Future<DateTime?> getSessionExpiry() async {
    try {
      final expiryString = await _secureStorage.read(key: _keySessionExpiry);
      if (expiryString != null) {
        final timestamp = int.tryParse(expiryString);
        if (timestamp != null) {
          final expiryTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
          AppLogger.info('Session expiry retrieved: ${expiryTime.toIso8601String()}');
          return expiryTime;
        }
      }
      return null;
    } catch (e) {
      AppLogger.error('Failed to retrieve session expiry', e);
      return null;
    }
  }

  /// セッションが有効かチェック
  /// Check if session is still valid
  static Future<bool> isSessionValid() async {
    try {
      final expiryTime = await getSessionExpiry();
      if (expiryTime == null) {
        return false;
      }
      final isValid = DateTime.now().isBefore(expiryTime);
      AppLogger.info('Session validity check: $isValid');
      return isValid;
    } catch (e) {
      AppLogger.error('Failed to check session validity', e);
      return false;
    }
  }

  /// 最後にログインしたメールアドレスを保存（SharedPreferences）
  /// Save last login email (non-sensitive data)
  static Future<void> saveLastLoginEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastLoginEmail, email);
      AppLogger.info('Last login email saved');
    } catch (e) {
      AppLogger.error('Failed to save last login email', e);
    }
  }

  /// 最後にログインしたメールアドレスを取得
  /// Get last login email
  static Future<String?> getLastLoginEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString(_keyLastLoginEmail);
      if (email != null) {
        AppLogger.info('Last login email retrieved');
      }
      return email;
    } catch (e) {
      AppLogger.error('Failed to retrieve last login email', e);
      return null;
    }
  }

  /// 認証状態のキャッシュを保存（SharedPreferences）
  /// Save authentication state cache
  static Future<void> saveAuthStateCache(Map<String, dynamic> authState) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAuthStateCache, jsonEncode(authState));
      AppLogger.info('Auth state cache saved');
    } catch (e) {
      AppLogger.error('Failed to save auth state cache', e);
    }
  }

  /// 認証状態のキャッシュを取得
  /// Get authentication state cache
  static Future<Map<String, dynamic>?> getAuthStateCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheJson = prefs.getString(_keyAuthStateCache);
      if (cacheJson != null) {
        final cache = jsonDecode(cacheJson) as Map<String, dynamic>;
        AppLogger.info('Auth state cache retrieved');
        return cache;
      }
      return null;
    } catch (e) {
      AppLogger.error('Failed to retrieve auth state cache', e);
      return null;
    }
  }

  /// すべての認証関連データを削除（ログアウト時）
  /// Clear all authentication data (logout)
  static Future<void> clearAllAuthData() async {
    try {
      // セキュアストレージをクリア
      await _secureStorage.delete(key: _keyAuthToken);
      await _secureStorage.delete(key: _keyRefreshToken);
      await _secureStorage.delete(key: _keyUserCredentials);
      await _secureStorage.delete(key: _keySessionExpiry);
      
      // SharedPreferencesの認証関連データもクリア
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyAuthStateCache);
      // 最後のログインメールは残す（UI利便性のため）
      
      AppLogger.info('All authentication data cleared');
    } catch (e) {
      AppLogger.error('Failed to clear authentication data', e);
      // テスト環境ではプラットフォーム例外をそのまま再スローする
      rethrow;
    }
  }

  /// すべてのストレージデータを削除（アプリリセット時）
  /// Clear all storage data (app reset)
  static Future<void> clearAllData() async {
    try {
      await _secureStorage.deleteAll();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      AppLogger.info('All storage data cleared');
    } catch (e) {
      AppLogger.error('Failed to clear all data', e);
      // テスト環境ではプラットフォーム例外をそのまま再スローする
      rethrow;
    }
  }
}