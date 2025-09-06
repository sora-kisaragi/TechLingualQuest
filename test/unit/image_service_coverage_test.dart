import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tech_lingual_quest/app/auth_service.dart';
import 'package:tech_lingual_quest/shared/services/image_service.dart';
import 'package:tech_lingual_quest/shared/models/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockXFile extends Mock implements XFile {}

void main() {
  group('Profile Image Feature Coverage Tests', () {
    late ProviderContainer container;
    late AuthService authService;

    setUp(() {
      container = ProviderContainer();
      authService = container.read(authServiceProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('ImageService.getMimeType should execute and return correct types',
        () {
      // This test forces execution of the getMimeType method
      final result1 = ImageService.getMimeType('test.jpg');
      final result2 = ImageService.getMimeType('test.png');
      final result3 = ImageService.getMimeType('test.gif');
      final result4 = ImageService.getMimeType('test.webp');
      final result5 = ImageService.getMimeType('test.unknown');

      expect(result1, 'image/jpeg');
      expect(result2, 'image/png');
      expect(result3, 'image/gif');
      expect(result4, 'image/webp');
      expect(result5, 'image/jpeg');

      // Additional edge cases to increase coverage
      final result6 = ImageService.getMimeType('');
      final result7 = ImageService.getMimeType('file.JPEG');
      final result8 = ImageService.getMimeType('image.with.multiple.dots.png');

      expect(result6, 'image/jpeg');
      expect(result7, 'image/jpeg');
      expect(result8, 'image/png');
    });

    test('ImageService.getImageSourceOptions should execute and return options',
        () {
      // Force execution of getImageSourceOptions
      final options = ImageService.getImageSourceOptions();

      expect(options, hasLength(2));

      final cameraOption = options[0];
      final galleryOption = options[1];

      expect(cameraOption.source, ImageSource.camera);
      expect(cameraOption.titleKey, 'takePhoto');
      expect(cameraOption.iconData, isNotNull);

      expect(galleryOption.source, ImageSource.gallery);
      expect(galleryOption.titleKey, 'chooseFromGallery');
      expect(galleryOption.iconData, isNotNull);

      // Call multiple times to ensure consistency
      final options2 = ImageService.getImageSourceOptions();
      expect(options2.length, options.length);
    });

    test('ImageService.uploadProfileImage should execute with mock file',
        () async {
      // Force execution of uploadProfileImage
      final mockFile = MockXFile();
      when(() => mockFile.name).thenReturn('test-upload.jpg');
      when(() => mockFile.path).thenReturn('/mock/path/test-upload.jpg');
      when(() => mockFile.length()).thenAnswer((_) async => 2048);

      final result = await ImageService.uploadProfileImage(mockFile);

      expect(result, isNotNull);
      expect(result, startsWith('https://example.com/profile-images/user-'));
      expect(result, contains('test-upload.jpg'));

      // Verify the mock was called
      verify(() => mockFile.name).called(1);
      verify(() => mockFile.path).called(1);
      verify(() => mockFile.length()).called(1);
    });

    test('ImageService.uploadProfileImage should handle errors', () async {
      // Force execution of error handling path
      final mockFile = MockXFile();
      when(() => mockFile.name).thenThrow(Exception('File error'));

      final result = await ImageService.uploadProfileImage(mockFile);

      expect(result, isNull);
      verify(() => mockFile.name).called(1);
    });

    test('ImageService.convertImageToBase64 should execute with mock data',
        () async {
      // Force execution of convertImageToBase64
      final testData = [1, 2, 3, 4, 5];
      final mockFile = MockXFile();
      when(() => mockFile.name).thenReturn('test.jpg');
      when(() => mockFile.readAsBytes()).thenAnswer((_) async => testData);

      final result = await ImageService.convertImageToBase64(mockFile);

      expect(result, isNotNull);
      expect(result, startsWith('data:image/jpeg;base64,'));

      verify(() => mockFile.name).called(1);
      verify(() => mockFile.readAsBytes()).called(1);
    });

    test('ImageService.convertImageToBase64 should handle errors', () async {
      // Force execution of error handling path
      final mockFile = MockXFile();
      when(() => mockFile.name).thenReturn('test.jpg');
      when(() => mockFile.readAsBytes()).thenThrow(Exception('Read error'));

      final result = await ImageService.convertImageToBase64(mockFile);

      expect(result, isNull);
      verify(() => mockFile.name).called(1);
      verify(() => mockFile.readAsBytes()).called(1);
    });

    test('AuthService profile image update should execute', () async {
      // Force execution of AuthService profile image functionality
      await authService.login('test@example.com', 'password123');

      final result1 = await authService.updateProfile(
        profileImageUrl: 'https://example.com/image1.jpg',
      );
      expect(result1, true);

      var authState = container.read(authServiceProvider);
      expect(authState.user?.profileImageUrl, 'https://example.com/image1.jpg');

      // Test clearing image
      final result2 = await authService.updateProfile(clearProfileImage: true);
      expect(result2, true);

      authState = container.read(authServiceProvider);
      expect(authState.user?.profileImageUrl, isNull);

      // Test empty image URL
      final result3 = await authService.updateProfile(profileImageUrl: '');
      expect(result3, true);

      authState = container.read(authServiceProvider);
      expect(authState.user?.profileImageUrl, '');
    });

    test('AuthService profile image with other data should execute', () async {
      // Force execution of mixed profile updates
      await authService.login('test@example.com', 'password123');

      final result = await authService.updateProfile(
        name: 'Test User',
        bio: 'Test Bio',
        profileImageUrl: 'https://example.com/combined.jpg',
        interests: ['Flutter', 'Dart'],
      );

      expect(result, true);

      final authState = container.read(authServiceProvider);
      final user = authState.user!;
      expect(user.name, 'Test User');
      expect(user.bio, 'Test Bio');
      expect(user.profileImageUrl, 'https://example.com/combined.jpg');
      expect(user.interests, ['Flutter', 'Dart']);
    });

    test('Multiple ImageService operations should execute', () async {
      // Force execution of multiple operations to increase coverage
      for (int i = 0; i < 3; i++) {
        final mockFile = MockXFile();
        when(() => mockFile.name).thenReturn('batch$i.jpg');
        when(() => mockFile.path).thenReturn('/mock/batch$i.jpg');
        when(() => mockFile.length()).thenAnswer((_) async => 1024 * (i + 1));

        final uploadResult = await ImageService.uploadProfileImage(mockFile);
        expect(uploadResult, isNotNull);

        final mimeType = ImageService.getMimeType('batch$i.jpg');
        expect(mimeType, 'image/jpeg');
      }

      final options = ImageService.getImageSourceOptions();
      expect(options, hasLength(2));
    });

    test('ImageSourceOption constructor should execute', () {
      // Force execution of ImageSourceOption constructor
      const option1 = ImageSourceOption(
        source: ImageSource.camera,
        titleKey: 'test1',
        iconData: Icons.camera,
      );

      const option2 = ImageSourceOption(
        source: ImageSource.gallery,
        titleKey: 'test2',
        iconData: Icons.photo,
      );

      expect(option1.source, ImageSource.camera);
      expect(option1.titleKey, 'test1');
      expect(option1.iconData, Icons.camera);

      expect(option2.source, ImageSource.gallery);
      expect(option2.titleKey, 'test2');
      expect(option2.iconData, Icons.photo);
    });

    test('Comprehensive coverage for all ImageService methods', () async {
      // Execute all static methods to ensure coverage

      // Test all MIME types
      final mimeTypes = [
        'test.jpg',
        'test.jpeg',
        'test.png',
        'test.gif',
        'test.webp',
        'test.unknown',
        '',
        'test',
        'file.multiple.dots.jpg',
      ];

      for (final fileName in mimeTypes) {
        final mimeType = ImageService.getMimeType(fileName);
        expect(mimeType, startsWith('image/'));
      }

      // Test options multiple times
      for (int i = 0; i < 3; i++) {
        final options = ImageService.getImageSourceOptions();
        expect(options, hasLength(2));
      }

      // Test upload with different file scenarios
      final uploadTests = [
        {'name': 'small.jpg', 'size': 512},
        {'name': 'large.png', 'size': 5120},
        {'name': 'medium.gif', 'size': 2048},
      ];

      for (final test in uploadTests) {
        final mockFile = MockXFile();
        when(() => mockFile.name).thenReturn(test['name'] as String);
        when(() => mockFile.path).thenReturn('/mock/${test['name']}');
        when(() => mockFile.length())
            .thenAnswer((_) async => test['size'] as int);

        final result = await ImageService.uploadProfileImage(mockFile);
        expect(result, isNotNull);
      }

      // Test base64 conversion with different formats
      final base64Tests = [
        {
          'name': 'test.jpg',
          'data': [1, 2, 3]
        },
        {
          'name': 'test.png',
          'data': [4, 5, 6]
        },
        {
          'name': 'test.gif',
          'data': [7, 8, 9]
        },
        {
          'name': 'test.webp',
          'data': [10, 11, 12]
        },
      ];

      for (final test in base64Tests) {
        final mockFile = MockXFile();
        when(() => mockFile.name).thenReturn(test['name'] as String);
        when(() => mockFile.readAsBytes())
            .thenAnswer((_) async => test['data'] as List<int>);

        final result = await ImageService.convertImageToBase64(mockFile);
        expect(result, isNotNull);
        expect(result, startsWith('data:image/'));
      }
    });
  });
}
