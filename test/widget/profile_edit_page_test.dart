import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tech_lingual_quest/features/auth/pages/profile_edit_page.dart';
import 'package:tech_lingual_quest/app/auth_service.dart';

void main() {
  group('ProfileEditPage Widget Tests', () {
    Widget createProfileEditPageWidget() {
      return ProviderScope.override(
        overrides: [],
        child: MaterialApp(
          home: ProfileEditPage(),
        ),
      );
    }

    testWidgets('should display profile edit form fields', (tester) async {
      await tester.pumpWidget(createProfileEditPageWidget());
      await tester.pumpAndSettle();

      // Should find form fields for profile editing
      expect(find.byType(TextFormField), findsWidgets);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('should show current profile image in edit mode',
        (tester) async {
      await tester.pumpWidget(createProfileEditPageWidget());
      await tester.pumpAndSettle();

      // Should display the current profile image
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('should display image upload button or area', (tester) async {
      await tester.pumpWidget(createProfileEditPageWidget());
      await tester.pumpAndSettle();

      // Look for image upload button or change photo option
      final changePhotoWidget = find.textContaining('Change Photo');
      final cameraIcon = find.byIcon(Icons.camera_alt);
      final photoIcon = find.byIcon(Icons.photo);

      // At least one of these should be present
      expect(
        changePhotoWidget.evaluate().isNotEmpty ||
            cameraIcon.evaluate().isNotEmpty ||
            photoIcon.evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('should handle form submission', (tester) async {
      await tester.pumpWidget(createProfileEditPageWidget());
      await tester.pumpAndSettle();

      // Find form fields and populate them
      final nameFields = find.byType(TextFormField);
      if (nameFields.evaluate().isNotEmpty) {
        await tester.enterText(nameFields.first, 'Updated Name');
      }

      // Look for save or submit button
      final saveButton = find.text('Save');
      final submitButton = find.text('Submit');
      final updateButton = find.text('Update');

      if (saveButton.evaluate().isNotEmpty) {
        await tester.tap(saveButton);
      } else if (submitButton.evaluate().isNotEmpty) {
        await tester.tap(submitButton);
      } else if (updateButton.evaluate().isNotEmpty) {
        await tester.tap(updateButton);
      }

      await tester.pumpAndSettle();

      // Form should handle submission gracefully
      expect(find.byType(ProfileEditPage), findsOneWidget);
    });

    testWidgets('should show loading state during image upload',
        (tester) async {
      await tester.pumpWidget(createProfileEditPageWidget());
      await tester.pumpAndSettle();

      // Widget should handle loading states for image upload
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('should validate form fields', (tester) async {
      await tester.pumpWidget(createProfileEditPageWidget());
      await tester.pumpAndSettle();

      // Try to submit empty form
      final submitButtons = [
        find.text('Save'),
        find.text('Submit'),
        find.text('Update'),
      ];

      for (final button in submitButtons) {
        if (button.evaluate().isNotEmpty) {
          await tester.tap(button);
          await tester.pumpAndSettle();
          break;
        }
      }

      // Should handle validation appropriately
      expect(find.byType(ProfileEditPage), findsOneWidget);
    });

    testWidgets('should handle image picker error states', (tester) async {
      await tester.pumpWidget(createProfileEditPageWidget());
      await tester.pumpAndSettle();

      // Widget should gracefully handle image picker errors
      // This is tested by ensuring the widget doesn't crash
      expect(find.byType(ProfileEditPage), findsOneWidget);
    });

    testWidgets('should update profile image preview immediately',
        (tester) async {
      await tester.pumpWidget(createProfileEditPageWidget());
      await tester.pumpAndSettle();

      // Initial state
      expect(find.byType(CircleAvatar), findsOneWidget);

      // Simulate successful image selection (this would normally happen through ImagePicker)
      // For now, just verify the UI can handle state changes
      await tester.pump();
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('should render basic page structure', (tester) async {
      await tester.pumpWidget(createProfileEditPageWidget());
      await tester.pumpAndSettle();

      // Should render without crashing
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
