import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/cloudinary_service.dart';

class EditUserScreen extends StatefulWidget {
  final String userId; // 🔑 ID của document trong Firestore
  final AppUser user;

  const EditUserScreen({
    super.key,
    required this.userId,
    required this.user,
  });

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  File? _newImageFile;
  bool _isUpdating = false;
  bool _changePassword = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  final userService = UserService();
  final cloudinaryService = CloudinaryService();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
    _emailController = TextEditingController(text: widget.user.email);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// 📸 Chọn ảnh mới từ thư viện
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _newImageFile = File(picked.path);
      });
    }
  }

  /// 💾 Cập nhật người dùng
  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUpdating = true);

    try {
      String? imageUrl = widget.user.imageUrl;

      // 🧩 Nếu người dùng chọn ảnh mới
      if (_newImageFile != null) {
        await userService.deleteUserImage(widget.user.imageUrl);
        imageUrl = await cloudinaryService.uploadImage(_newImageFile!);
      }

      // 🔐 Nếu người dùng đổi mật khẩu → dùng mật khẩu mới
      final updatedPassword = _changePassword
          ? _newPasswordController.text.trim()
          : widget.user.password;

      // 🧩 Tạo bản ghi người dùng mới
      final updatedUser = AppUser(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: updatedPassword,
        imageUrl: imageUrl,
      );

      // 🔥 Cập nhật lên Firestore
      await userService.updateUserById(widget.userId, updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Cập nhật người dùng thành công!')),
        );
        Navigator.pop(context, updatedUser);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Lỗi khi cập nhật: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = _newImageFile != null
        ? FileImage(_newImageFile!)
        : (widget.user.imageUrl != null && widget.user.imageUrl!.isNotEmpty
            ? NetworkImage(widget.user.imageUrl!)
            : const AssetImage('assets/avatar_placeholder.png'))
            as ImageProvider;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa người dùng'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: imageProvider,
                  child: _newImageFile == null &&
                          (widget.user.imageUrl == null ||
                              widget.user.imageUrl!.isEmpty)
                      ? const Icon(Icons.camera_alt, size: 30, color: Colors.black54)
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              // 👤 Username
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Tên người dùng',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Không được để trống' : null,
              ),
              const SizedBox(height: 12),

              // 📧 Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Không được để trống';
                  if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(value)) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 🔐 Tùy chọn đổi mật khẩu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Đổi mật khẩu', style: TextStyle(fontSize: 16)),
                  Switch(
                    value: _changePassword,
                    onChanged: (value) {
                      setState(() {
                        _changePassword = value;
                      });
                    },
                  ),
                ],
              ),

              if (_changePassword) ...[
                const SizedBox(height: 10),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscureNewPassword,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu mới',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureNewPassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      }),
                    ),
                  ),
                  validator: (value) {
                    if (!_changePassword) return null;
                    if (value == null || value.length < 6) {
                      return 'Mật khẩu phải có ít nhất 6 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Xác nhận mật khẩu',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      }),
                    ),
                  ),
                  validator: (value) {
                    if (!_changePassword) return null;
                    if (value != _newPasswordController.text) {
                      return 'Mật khẩu không khớp';
                    }
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 25),
              ElevatedButton.icon(
                onPressed: _isUpdating ? null : _updateUser,
                icon: _isUpdating
                    ? const SizedBox(
                        width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save),
                label: Text(_isUpdating ? 'Đang cập nhật...' : 'Cập nhật người dùng'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
