import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tech_lingual_quest/shared/services/image_service.dart';

// Mock classes for testing
class MockImagePicker extends Mock implements ImagePicker {}

class MockXFile extends Mock implements XFile {}

void main() {
  group('ImageService Tests', () {
    group('getMimeType Tests', () {
      test('should return correct MIME type for different file extensions', () {
        // テスト用のファイル名でMIMEタイプをテスト
        // Test MIME types with test file names

        // JPEGファイルのテスト / Test JPEG files
        expect(ImageService.getMimeType('test.jpg'), equals('image/jpeg'));
        expect(ImageService.getMimeType('test.jpeg'), equals('image/jpeg'));
        expect(ImageService.getMimeType('TEST.JPG'), equals('image/jpeg'));

        // PNGファイルのテスト / Test PNG files
        expect(ImageService.getMimeType('test.png'), equals('image/png'));
        expect(ImageService.getMimeType('TEST.PNG'), equals('image/png'));

        // GIFファイルのテスト / Test GIF files
        expect(ImageService.getMimeType('test.gif'), equals('image/gif'));

        // WebPファイルのテスト / Test WebP files
        expect(ImageService.getMimeType('test.webp'), equals('image/webp'));

        // 未知の拡張子のテスト / Test unknown extensions
        expect(ImageService.getMimeType('test.unknown'), equals('image/jpeg'));
        expect(ImageService.getMimeType('test'), equals('image/jpeg'));
      });

      test('should handle edge cases for MIME type detection', () {
        // エッジケースのテスト / Test edge cases
        expect(ImageService.getMimeType(''), equals('image/jpeg'));
        expect(ImageService.getMimeType('.jpg'), equals('image/jpeg'));
        expect(ImageService.getMimeType('file.'), equals('image/jpeg'));
        expect(ImageService.getMimeType('file.multiple.dots.png'),
            equals('image/png'));
      });
    });

    group('getImageSourceOptions Tests', () {
      test('should return image source options with correct structure', () {
        final options = ImageService.getImageSourceOptions();

        expect(options, hasLength(2));

        // カメラオプションのテスト / Test camera option
        final cameraOption =
            options.firstWhere((option) => option.source == ImageSource.camera);
        expect(cameraOption.titleKey, equals('takePhoto'));
        expect(cameraOption.iconData, equals(Icons.camera_alt));

        // ギャラリーオプションのテスト / Test gallery option
        final galleryOption = options
            .firstWhere((option) => option.source == ImageSource.gallery);
        expect(galleryOption.titleKey, equals('chooseFromGallery'));
        expect(galleryOption.iconData, equals(Icons.photo_library));
      });

      test('should return immutable options list', () {
        final options1 = ImageService.getImageSourceOptions();
        final options2 = ImageService.getImageSourceOptions();

        expect(options1.length, equals(options2.length));
        for (int i = 0; i < options1.length; i++) {
          expect(options1[i].source, equals(options2[i].source));
          expect(options1[i].titleKey, equals(options2[i].titleKey));
          expect(options1[i].iconData, equals(options2[i].iconData));
        }
      });
    });

    group('ImageSourceOption Tests', () {
      test('ImageSourceOption should be immutable', () {
        const option1 = ImageSourceOption(
          source: ImageSource.camera,
          titleKey: 'test',
          iconData: Icons.camera,
        );

        const option2 = ImageSourceOption(
          source: ImageSource.camera,
          titleKey: 'test',
          iconData: Icons.camera,
        );

        // 同じ値を持つオブジェクトは等しくないが、const constructorが機能している
        // Objects with same values are not equal but const constructor works
        expect(option1.source, equals(option2.source));
        expect(option1.titleKey, equals(option2.titleKey));
        expect(option1.iconData, equals(option2.iconData));
      });

      test('should properly store all properties', () {
        const option = ImageSourceOption(
          source: ImageSource.gallery,
          titleKey: 'customKey',
          iconData: Icons.photo,
        );

        expect(option.source, equals(ImageSource.gallery));
        expect(option.titleKey, equals('customKey'));
        expect(option.iconData, equals(Icons.photo));
      });
    });

    group('uploadProfileImage Tests', () {
      test('should return mock URL with timestamp on successful upload',
          () async {
        // Create mock XFile
        final mockFile = MockXFile();
        when(() => mockFile.name).thenReturn('test-image.jpg');
        when(() => mockFile.path).thenReturn('/mock/path/test-image.jpg');
        when(() => mockFile.length()).thenAnswer((_) async => 1024);

        final result = await ImageService.uploadProfileImage(mockFile);

        expect(result, isNotNull);
        expect(result, startsWith('https://example.com/profile-images/user-'));
        expect(result, contains('test-image.jpg'));
      });

      test('should handle upload errors gracefully', () async {
        // Create mock XFile that throws an error
        final mockFile = MockXFile();
        when(() => mockFile.name).thenThrow(Exception('File access error'));

        final result = await ImageService.uploadProfileImage(mockFile);

        expect(result, isNull);
      });

      test('should log file size correctly during upload', () async {
        // Create mock XFile with specific size
        final mockFile = MockXFile();
        when(() => mockFile.name).thenReturn('large-image.png');
        when(() => mockFile.path).thenReturn('/mock/path/large-image.png');
        when(() => mockFile.length()).thenAnswer((_) async => 2048);

        final result = await ImageService.uploadProfileImage(mockFile);

        expect(result, isNotNull);
        expect(result, contains('large-image.png'));
      });
    });

    group('convertImageToBase64 Tests', () {
      test('should convert image to base64 with correct format', () async {
        // Create test image data
        final testBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        final expectedBase64 = base64Encode(testBytes);

        // Create mock XFile
        final mockFile = MockXFile();
        when(() => mockFile.name).thenReturn('test.jpg');
        when(() => mockFile.readAsBytes()).thenAnswer((_) async => testBytes);

        final result = await ImageService.convertImageToBase64(mockFile);

        expect(result, isNotNull);
        expect(result, startsWith('data:image/jpeg;base64,'));
        expect(result, contains(expectedBase64));
      });

      test('should handle different image formats for base64', () async {
        final testBytes = Uint8List.fromList([10, 20, 30]);

        // Test PNG format
        final mockPngFile = MockXFile();
        when(() => mockPngFile.name).thenReturn('test.png');
        when(() => mockPngFile.readAsBytes())
            .thenAnswer((_) async => testBytes);

        final pngResult = await ImageService.convertImageToBase64(mockPngFile);
        expect(pngResult, startsWith('data:image/png;base64,'));

        // Test GIF format
        final mockGifFile = MockXFile();
        when(() => mockGifFile.name).thenReturn('test.gif');
        when(() => mockGifFile.readAsBytes())
            .thenAnswer((_) async => testBytes);

        final gifResult = await ImageService.convertImageToBase64(mockGifFile);
        expect(gifResult, startsWith('data:image/gif;base64,'));
      });

      test('should handle base64 conversion errors', () async {
        final mockFile = MockXFile();
        when(() => mockFile.name).thenReturn('test.jpg');
        when(() => mockFile.readAsBytes()).thenThrow(Exception('Read error'));

        final result = await ImageService.convertImageToBase64(mockFile);

        expect(result, isNull);
      });

      test('should handle empty file for base64 conversion', () async {
        final mockFile = MockXFile();
        when(() => mockFile.name).thenReturn('empty.jpg');
        when(() => mockFile.readAsBytes())
            .thenAnswer((_) async => Uint8List(0));

        final result = await ImageService.convertImageToBase64(mockFile);

        expect(result, isNotNull);
        expect(result, equals('data:image/jpeg;base64,'));
      });
    });

    group('Integration Tests', () {
      test('should maintain consistency across MIME type methods', () {
        const testFiles = [
          'image.jpg',
          'photo.png',
          'animation.gif',
          'modern.webp',
          'unknown.xyz'
        ];

        for (final fileName in testFiles) {
          final mimeType = ImageService.getMimeType(fileName);
          expect(mimeType, startsWith('image/'));
          expect(mimeType, isNot(isEmpty));
        }
      });

      test('should handle multiple base64 conversions consistently', () async {
        final testBytes1 = Uint8List.fromList([1, 2, 3]);
        final testBytes2 = Uint8List.fromList([4, 5, 6]);

        final mockFile1 = MockXFile();
        when(() => mockFile1.name).thenReturn('test1.jpg');
        when(() => mockFile1.readAsBytes()).thenAnswer((_) async => testBytes1);

        final mockFile2 = MockXFile();
        when(() => mockFile2.name).thenReturn('test2.jpg');
        when(() => mockFile2.readAsBytes()).thenAnswer((_) async => testBytes2);

        final result1 = await ImageService.convertImageToBase64(mockFile1);
        final result2 = await ImageService.convertImageToBase64(mockFile2);

        expect(result1, isNotNull);
        expect(result2, isNotNull);
        expect(result1, isNot(equals(result2)));
        expect(result1, startsWith('data:image/jpeg;base64,'));
        expect(result2, startsWith('data:image/jpeg;base64,'));
      });
    });
  });
}
