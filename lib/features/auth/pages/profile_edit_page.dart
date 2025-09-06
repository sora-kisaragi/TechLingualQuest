import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/auth_service.dart';
import '../../../shared/services/dynamic_localization_service.dart';
import '../../../shared/services/image_service.dart';
import '../../../shared/utils/logger.dart';

/// プロフィール編集ページ
///
/// ユーザーのプロフィール情報（名前、レベル、興味分野、自己紹介）を編集する
class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _interestController = TextEditingController();

  UserLevel? _selectedLevel;
  List<String> _interests = [];
  bool _isLoading = false;
  bool _isImageUploading = false;
  String? _selectedImageUrl;

  @override
  void initState() {
    super.initState();
    _initializeFormData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _interestController.dispose();
    super.dispose();
  }

  /// フォームデータを現在のユーザー情報で初期化
  void _initializeFormData() {
    final currentUser = ref.read(authServiceProvider).user;
    if (currentUser != null) {
      _nameController.text = currentUser.name ?? '';
      _bioController.text = currentUser.bio ?? '';
      _selectedLevel = currentUser.level;
      _interests = List.from(currentUser.interests ?? []);
      _selectedImageUrl = currentUser.profileImageUrl;
    }
  }

  /// プロフィール画像変更ダイアログを表示
  /// Show profile image change dialog
  void _showImageSelectionDialog(AppTranslations translations) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                translations.getSync('selectImage'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),
              ...ImageService.getImageSourceOptions().map((option) {
                return ListTile(
                  leading: Icon(option.iconData),
                  title: Text(translations.getSync(option.titleKey)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _selectAndUploadImage(option.source, translations);
                  },
                );
              }),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(translations.getSync('cancel')),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 画像を選択してアップロード
  /// Select and upload image
  Future<void> _selectAndUploadImage(
    ImageSource source,
    AppTranslations translations,
  ) async {
    try {
      // 画像選択
      // Select image
      final XFile? pickedFile = await ImageService.pickImage(source: source);

      if (pickedFile == null) {
        // ユーザーがキャンセルした場合
        // User cancelled
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(translations.getSync('imageSelectionCancelled')),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // アップロード開始
      // Start upload
      setState(() {
        _isImageUploading = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translations.getSync('uploading')),
            backgroundColor: Colors.blue,
          ),
        );
      }

      // 画像アップロード
      // Upload image
      final String? uploadedImageUrl =
          await ImageService.uploadProfileImage(pickedFile);

      if (uploadedImageUrl != null) {
        setState(() {
          _selectedImageUrl = uploadedImageUrl;
          _isImageUploading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(translations.getSync('imageUploadSuccess')),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _isImageUploading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(translations.getSync('imageUploadError')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (error) {
      AppLogger.error('Image selection/upload error: $error');

      setState(() {
        _isImageUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translations.getSync('imageUploadError')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final translationsAsync = ref.watch(appTranslationsProvider);
    final authState = ref.watch(authServiceProvider);

    return translationsAsync.when(
      data: (translations) =>
          _buildEditContent(context, translations, authState),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Failed to load translations: $error')),
      ),
    );
  }

  Widget _buildEditContent(
    BuildContext context,
    AppTranslations translations,
    AuthState authState,
  ) {
    // If not authenticated, redirect to auth page
    if (!authState.isAuthenticated || authState.user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/auth');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(translations.getSync('editProfile')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Save button in app bar
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : () => _saveProfile(translations),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile image section
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.deepPurple.shade100,
                      child: _isImageUploading
                          ? const CircularProgressIndicator()
                          : _selectedImageUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    _selectedImageUrl!,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                      Icons.person,
                                      size: 80,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 80,
                                  color: Colors.deepPurple,
                                ),
                    ),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: _isImageUploading
                          ? null
                          : () {
                              _showImageSelectionDialog(translations);
                            },
                      icon: const Icon(Icons.camera_alt),
                      label: Text(translations.getSync('changePhoto')),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Display Name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: translations.getSync('displayName'),
                  prefixIcon: const Icon(Icons.person),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return translations.getSync('nameRequired');
                  }
                  if (value.trim().length > 50) {
                    return translations.getSync('nameTooLong');
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              // Email field (read-only)
              TextFormField(
                initialValue: authState.user!.email,
                decoration: InputDecoration(
                  labelText: translations.getSync('emailAddress'),
                  prefixIcon: const Icon(Icons.email),
                  border: const OutlineInputBorder(),
                ),
                readOnly: true,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),

              // Current Level section
              Text(
                translations.getSync('currentLevel'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 10),
              Column(
                children: UserLevel.values.map((level) {
                  String levelText = '';
                  switch (level) {
                    case UserLevel.beginner:
                      levelText = translations.getSync('beginnerLevel');
                      break;
                    case UserLevel.intermediate:
                      levelText = translations.getSync('intermediateLevel');
                      break;
                    case UserLevel.advanced:
                      levelText = translations.getSync('advancedLevel');
                      break;
                  }

                  return ListTile(
                    title: Text(levelText),
                    leading: Radio<UserLevel>(
                      value: level,
                      groupValue: _selectedLevel,
                      onChanged: (UserLevel? value) {
                        setState(() {
                          _selectedLevel = value;
                        });
                      },
                    ),
                    onTap: () {
                      setState(() {
                        _selectedLevel = level;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Tech Interests section
              Text(
                translations.getSync('techInterests'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 10),

              // Interest input field
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _interestController,
                      decoration: InputDecoration(
                        hintText: translations.getSync('interestPlaceholder'),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _addInterest(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addInterest,
                    child: Text(translations.getSync('addInterest')),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Interest tags
              if (_interests.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _interests.map((interest) {
                    return Chip(
                      label: Text(interest),
                      deleteIcon: const Icon(Icons.close),
                      onDeleted: () => _removeInterest(interest),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 20),

              // Bio field
              TextFormField(
                controller: _bioController,
                decoration: InputDecoration(
                  labelText: translations.getSync('bio'),
                  hintText: translations.getSync('bioPlaceholder'),
                  prefixIcon: const Icon(Icons.description),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
                maxLength: 200,
                textInputAction: TextInputAction.newline,
              ),
              const SizedBox(height: 30),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => context.pop(),
                      child: Text(translations.getSync('cancel')),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          _isLoading ? null : () => _saveProfile(translations),
                      child: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(translations.getSync('saveChanges')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 興味分野を追加
  void _addInterest() {
    final interest = _interestController.text.trim();
    if (interest.isNotEmpty && !_interests.contains(interest)) {
      setState(() {
        _interests.add(interest);
        _interestController.clear();
      });
    }
  }

  /// 興味分野を削除
  void _removeInterest(String interest) {
    setState(() {
      _interests.remove(interest);
    });
  }

  /// プロフィールを保存
  Future<void> _saveProfile(AppTranslations translations) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      AppLogger.info('Updating user profile');

      final authService = ref.read(authServiceProvider.notifier);
      final success = await authService.updateProfile(
        name: _nameController.text.trim(),
        profileImageUrl: _selectedImageUrl,
        level: _selectedLevel,
        interests: _interests.isEmpty ? null : _interests,
        bio: _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(translations.getSync('profileUpdated')),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(translations.getSync('profileUpdateError')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (error) {
      AppLogger.error('Profile update error: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translations.getSync('profileUpdateError')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
