import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tech_lingual_quest/app/auth_service.dart';
import 'package:tech_lingual_quest/shared/services/image_service.dart';

// Mock classes for integration testing
class MockXFile extends Mock implements XFile {}

void main() {
  group('Profile Image Upload Integration Tests', () {
    late ProviderContainer container;
    late AuthService authService;

    setUp(() {
      container = ProviderContainer();
      authService = container.read(authServiceProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('Full image upload workflow should complete successfully', () async {
      // Step 1: Login user
      final loginResult =
          await authService.login('test@example.com', 'password123');
      expect(loginResult, true);

      // Step 2: Create mock image file
      final mockFile = MockXFile();
      when(() => mockFile.name).thenReturn('profile-photo.jpg');
      when(() => mockFile.path).thenReturn('/mock/path/profile-photo.jpg');
      when(() => mockFile.length()).thenAnswer((_) async => 2048);

      // Step 3: Upload image
      final uploadResult = await ImageService.uploadProfileImage(mockFile);
      expect(uploadResult, isNotNull);
      expect(uploadResult, startsWith('https://example.com/profile-images/'));

      // Step 4: Update profile with new image URL
      final updateResult = await authService.updateProfile(
        profileImageUrl: uploadResult,
      );
      expect(updateResult, true);

      // Step 5: Verify profile was updated
      final authState = container.read(authServiceProvider);
      expect(authState.user!.profileImageUrl, uploadResult);
    });

    test('Image upload error should not break profile update', () async {
      await authService.login('test@example.com', 'password123');

      // Create mock file that will fail
      final mockFile = MockXFile();
      when(() => mockFile.name).thenThrow(Exception('File error'));

      // Upload should return null on error
      final uploadResult = await ImageService.uploadProfileImage(mockFile);
      expect(uploadResult, isNull);

      // Profile update should still work with other fields
      final updateResult = await authService.updateProfile(
        name: 'Updated Name',
        bio: 'Updated Bio',
      );
      expect(updateResult, true);

      final authState = container.read(authServiceProvider);
      expect(authState.user!.name, 'Updated Name');
      expect(authState.user!.bio, 'Updated Bio');
    });

    test('Base64 conversion workflow should work for web uploads', () async {
      await authService.login('test@example.com', 'password123');

      // Create mock file with test data
      final testImageData =
          Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10]); // PNG header
      final mockFile = MockXFile();
      when(() => mockFile.name).thenReturn('web-image.png');
      when(() => mockFile.readAsBytes()).thenAnswer((_) async => testImageData);

      // Convert to base64
      final base64Result = await ImageService.convertImageToBase64(mockFile);
      expect(base64Result, isNotNull);
      expect(base64Result, startsWith('data:image/png;base64,'));

      // Use base64 URL for profile update
      final updateResult = await authService.updateProfile(
        profileImageUrl: base64Result,
      );
      expect(updateResult, true);

      final authState = container.read(authServiceProvider);
      expect(authState.user!.profileImageUrl, base64Result);
    });

    test('Multiple image operations should maintain state correctly', () async {
      await authService.login('test@example.com', 'password123');

      final imageUrls = <String>[];

      // Perform multiple image upload simulations
      for (int i = 0; i < 3; i++) {
        final mockFile = MockXFile();
        when(() => mockFile.name).thenReturn('image$i.jpg');
        when(() => mockFile.path).thenReturn('/mock/path/image$i.jpg');
        when(() => mockFile.length()).thenAnswer((_) async => 1024 * (i + 1));

        final uploadResult = await ImageService.uploadProfileImage(mockFile);
        expect(uploadResult, isNotNull);
        imageUrls.add(uploadResult!);

        final updateResult = await authService.updateProfile(
          profileImageUrl: uploadResult,
        );
        expect(updateResult, true);

        final authState = container.read(authServiceProvider);
        expect(authState.user!.profileImageUrl, uploadResult);
      }

      // Verify all URLs are different
      expect(imageUrls.toSet().length, equals(3));
    });

    test('Image service options should be consistent', () {
      final options = ImageService.getImageSourceOptions();

      expect(options, hasLength(2));

      // Test camera option
      final cameraOption =
          options.firstWhere((o) => o.source == ImageSource.camera);
      expect(cameraOption.titleKey, 'takePhoto');
      expect(cameraOption.iconData, isNotNull);

      // Test gallery option
      final galleryOption =
          options.firstWhere((o) => o.source == ImageSource.gallery);
      expect(galleryOption.titleKey, 'chooseFromGallery');
      expect(galleryOption.iconData, isNotNull);
    });

    test('MIME type detection should handle all supported formats', () {
      final testCases = {
        'photo.jpg': 'image/jpeg',
        'image.jpeg': 'image/jpeg',
        'graphic.png': 'image/png',
        'animation.gif': 'image/gif',
        'modern.webp': 'image/webp',
        'unknown.xyz': 'image/jpeg', // default
        'no-extension': 'image/jpeg', // default
      };

      testCases.forEach((fileName, expectedMimeType) {
        final result = ImageService.getMimeType(fileName);
        expect(result, expectedMimeType, reason: 'Failed for file: $fileName');
      });
    });

    test('Profile image clearing should work correctly', () async {
      await authService.login('test@example.com', 'password123');

      // Set initial image
      final mockFile = MockXFile();
      when(() => mockFile.name).thenReturn('initial.jpg');
      when(() => mockFile.path).thenReturn('/mock/path/initial.jpg');
      when(() => mockFile.length()).thenAnswer((_) async => 1024);

      final uploadResult = await ImageService.uploadProfileImage(mockFile);
      await authService.updateProfile(profileImageUrl: uploadResult);

      var authState = container.read(authServiceProvider);
      expect(authState.user!.profileImageUrl, isNotNull);

      // Clear image
      final clearResult =
          await authService.updateProfile(clearProfileImage: true);
      expect(clearResult, true);

      authState = container.read(authServiceProvider);
      expect(authState.user!.profileImageUrl, isNull);
    });

    test('Large file handling should work correctly', () async {
      await authService.login('test@example.com', 'password123');

      // Simulate large file
      final mockFile = MockXFile();
      when(() => mockFile.name).thenReturn('large-image.jpg');
      when(() => mockFile.path).thenReturn('/mock/path/large-image.jpg');
      when(() => mockFile.length())
          .thenAnswer((_) async => 5 * 1024 * 1024); // 5MB

      final uploadResult = await ImageService.uploadProfileImage(mockFile);
      expect(uploadResult, isNotNull);

      final updateResult = await authService.updateProfile(
        profileImageUrl: uploadResult,
      );
      expect(updateResult, true);
    });

    test('Concurrent image operations should be handled safely', () async {
      await authService.login('test@example.com', 'password123');

      final futures = <Future<String?>>[];

      // Start multiple concurrent uploads
      for (int i = 0; i < 5; i++) {
        final mockFile = MockXFile();
        when(() => mockFile.name).thenReturn('concurrent$i.jpg');
        when(() => mockFile.path).thenReturn('/mock/path/concurrent$i.jpg');
        when(() => mockFile.length()).thenAnswer((_) async => 1024);

        futures.add(ImageService.uploadProfileImage(mockFile));
      }

      final results = await Future.wait(futures);

      // All uploads should succeed
      for (final result in results) {
        expect(result, isNotNull);
      }

      // Use the last result for profile update
      final updateResult = await authService.updateProfile(
        profileImageUrl: results.last,
      );
      expect(updateResult, true);
    });
  });
}
