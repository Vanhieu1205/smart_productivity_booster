import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../domain/entities/user_entity.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'package:smart_productivity_booster/l10n/app_localizations.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _imagePicker = ImagePicker();
  String? _selectedAvatarPath;
  bool _isLoadingAvatar = false;
  /// true khi vừa gửi Lưu — chờ AuthBloc cập nhật xong mới pop (đồng bộ Cài đặt).
  bool _awaitingProfileSave = false;

  @override
  void initState() {
    super.initState();
    // Khởi tạo Text Controller với tên user hiện tại
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _usernameController.text = authState.user.username;
      _selectedAvatarPath = authState.user.avatarPath;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() => _isLoadingAvatar = true);
    
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );
      
      if (image != null) {
        // Copy image to app documents directory
        final appDir = await getApplicationDocumentsDirectory();
        final avatarsDir = Directory('${appDir.path}/avatars');
        if (!await avatarsDir.exists()) {
          await avatarsDir.create(recursive: true);
        }
        
        final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
        final savedPath = '${avatarsDir.path}/$fileName';
        
        // Copy file to app directory
        await File(image.path).copy(savedPath);
        
        setState(() {
          _selectedAvatarPath = savedPath;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi chọn ảnh: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoadingAvatar = false);
    }
  }

  Future<void> _pickFromCamera() async {
    setState(() => _isLoadingAvatar = true);
    
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );
      
      if (image != null) {
        // Copy image to app documents directory
        final appDir = await getApplicationDocumentsDirectory();
        final avatarsDir = Directory('${appDir.path}/avatars');
        if (!await avatarsDir.exists()) {
          await avatarsDir.create(recursive: true);
        }
        
        final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
        final savedPath = '${avatarsDir.path}/$fileName';
        
        // Copy file to app directory
        await File(image.path).copy(savedPath);
        
        setState(() {
          _selectedAvatarPath = savedPath;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi chụp ảnh: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoadingAvatar = false);
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ Thư viện'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh mới'),
              onTap: () {
                Navigator.pop(context);
                _pickFromCamera();
              },
            ),
            if (_selectedAvatarPath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Xóa ảnh đại diện', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedAvatarPath = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarContent(BuildContext context, UserEntity user) {
    final pathStr = _selectedAvatarPath ?? user.avatarPath;
    if (pathStr != null && pathStr.isNotEmpty) {
      final file = File(pathStr);
      if (file.existsSync()) {
        return ClipOval(
          child: Image.file(
            file,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Text(
              user.avatarInitials,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        );
      }
    }
    return Text(
      user.avatarInitials,
      style: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _awaitingProfileSave = true);
    context.read<AuthBloc>().add(
      UpdateUserRequested(
        newUsername: _usernameController.text.trim(),
        newAvatarPath: _selectedAvatarPath,
      ),
    );
    // Tránh kẹt nút tải nếu Bloc không phát state mới (hiếm)
    Future.delayed(const Duration(seconds: 12), () {
      if (mounted && _awaitingProfileSave) {
        setState(() => _awaitingProfileSave = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) =>
          _awaitingProfileSave &&
          curr is AuthAuthenticated &&
          prev is AuthAuthenticated &&
          prev.user != curr.user,
      listener: (context, state) {
        if (!_awaitingProfileSave || state is! AuthAuthenticated) return;
        setState(() => _awaitingProfileSave = false);
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.profileUpdated),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      },
      child: Scaffold(
      appBar: AppBar(
        title: Text(l10n.myProfile),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(child: Text('Lỗi không tìm thấy dữ liệu cấu hình!'));
          }
          final user = state.user;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  
                  // Avatar Section
                  Center(
                    child: GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            child: _buildAvatarContent(context, user),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: _isLoadingAvatar
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Nhấn để thay đổi ảnh đại diện',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Username Field
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: l10n.registerUsername,
                      prefixIcon: const Icon(Icons.person_outline),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.nameCannotBeEmpty;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Email Field (Readonly)
                  TextFormField(
                    initialValue: user.email,
                    readOnly: true,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: l10n.registerEmail,
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 48),

                  ElevatedButton(
                    onPressed: _awaitingProfileSave ? null : _onSave,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _awaitingProfileSave
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.save, style: const TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
    );
  }
}
