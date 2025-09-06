import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/logger.dart';

/// 画像選択とアップロード機能を提供するサービス
/// Image selection and upload service for profile images
class ImageService {
  static final ImagePicker _picker = ImagePicker();

  /// カメラまたはギャラリーから画像を選択
  /// Select image from camera or gallery
  static Future<XFile?> pickImage({
    required ImageSource source,
    int imageQuality = 85,
    double maxWidth = 1024,
    double maxHeight = 1024,
  }) async {
    try {
      AppLogger.info('Starting image selection from ${source.toString()}');

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      if (pickedFile != null) {
        AppLogger.info('Image selected successfully: ${pickedFile.path}');
        // 画像サイズログ / Log image size
        final int fileSize = await pickedFile.length();
        AppLogger.info(
            'Selected image size: ${(fileSize / 1024).toStringAsFixed(1)} KB');
      } else {
        AppLogger.info('Image selection cancelled by user');
      }

      return pickedFile;
    } catch (error) {
      AppLogger.error('Image selection failed: $error');
      return null;
    }
  }

  /// プロフィール画像をアップロード（モック実装）
  /// Upload profile image (mock implementation)
  static Future<String?> uploadProfileImage(XFile imageFile) async {
    try {
      AppLogger.info('Starting profile image upload: ${imageFile.path}');

      // モック処理: 2秒の遅延をシミュレート
      // Mock processing: simulate 2-second delay
      await Future.delayed(const Duration(seconds: 2));

      // 実際の実装では、ここでサーバーにアップロードを行う
      // In a real implementation, upload to server would happen here
      final String fileName = imageFile.name;
      final int fileSize = await imageFile.length();

      // モック URL を生成（実際の実装では、サーバーからのレスポンスを使用）
      // Generate mock URL (in real implementation, use server response)
      final String mockImageUrl =
          'https://example.com/profile-images/user-${DateTime.now().millisecondsSinceEpoch}-$fileName';

      AppLogger.info('Profile image upload completed: $mockImageUrl');
      AppLogger.info(
          'Uploaded file size: ${(fileSize / 1024).toStringAsFixed(1)} KB');

      return mockImageUrl;
    } catch (error) {
      AppLogger.error('Profile image upload failed: $error');
      return null;
    }
  }

  /// 画像ファイルを Base64 文字列に変換（Web用）
  /// Convert image file to Base64 string (for Web)
  static Future<String?> convertImageToBase64(XFile imageFile) async {
    try {
      final Uint8List bytes = await imageFile.readAsBytes();
      final String base64String = base64Encode(bytes);
      final String mimeType = getMimeType(imageFile.name);

      // Data URL 形式で返却
      // Return as data URL format
      final String dataUrl = 'data:$mimeType;base64,$base64String';

      AppLogger.info(
          'Image converted to Base64 (${(base64String.length / 1024).toStringAsFixed(1)} KB)');
      return dataUrl;
    } catch (error) {
      AppLogger.error('Base64 conversion failed: $error');
      return null;
    }
  }

  /// ファイル名から MIME タイプを取得
  /// Get MIME type from file name
  static String getMimeType(String fileName) {
    final String extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg'; // デフォルト / Default
    }
  }

  /// 画像選択ダイアログを表示するためのオプション
  /// Options for image selection dialog
  static List<ImageSourceOption> getImageSourceOptions() {
    return [
      const ImageSourceOption(
        source: ImageSource.camera,
        titleKey: 'takePhoto',
        iconData: Icons.camera_alt,
      ),
      const ImageSourceOption(
        source: ImageSource.gallery,
        titleKey: 'chooseFromGallery',
        iconData: Icons.photo_library,
      ),
    ];
  }
}

/// 画像選択オプションのデータクラス
/// Data class for image selection options
class ImageSourceOption {
  final ImageSource source;
  final String titleKey; // 翻訳キー / Translation key
  final IconData iconData;

  const ImageSourceOption({
    required this.source,
    required this.titleKey,
    required this.iconData,
  });
}
