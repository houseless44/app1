import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'admin_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = AuthService();

  bool _isLoading = false;

  /// 🔹 Hàm chuyển mã lỗi Firebase sang tiếng Việt dễ hiểu
  String _getFriendlyError(String errorMessage) {
    if (errorMessage.contains('user-not-found')) {
      return 'Tài khoản không tồn tại. Vui lòng kiểm tra lại email.';
    } else if (errorMessage.contains('wrong-password')) {
      return 'Sai mật khẩu. Vui lòng thử lại.';
    } else if (errorMessage.contains('invalid-email')) {
      return 'Địa chỉ email không hợp lệ.';
    } else if (errorMessage.contains('user-disabled')) {
      return 'Tài khoản này đã bị vô hiệu hóa.';
    } else if (errorMessage.contains('too-many-requests')) {
      return 'Bạn đã thử quá nhiều lần. Vui lòng thử lại sau.';
    } else {
      return 'Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin.';
    }
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Vui lòng nhập đầy đủ email và mật khẩu", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _auth.signIn(email, password);

      if (user != null && mounted) {
        _showSnackBar("Đăng nhập thành công!", Colors.green);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminScreen()),
        );
      } else {
        _showSnackBar("Đăng nhập thất bại. Vui lòng thử lại.", Colors.redAccent);
      }
    } catch (e) {
      final friendlyMessage = _getFriendlyError(e.toString());
      _showSnackBar(friendlyMessage, Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 16)),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đăng nhập Admin"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Chào mừng trở lại 👋",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: "Mật khẩu",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Đăng nhập",
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
