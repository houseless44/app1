import 'dart:convert';
import 'package:crypto/crypto.dart';

/// 📦 Các hàm tiện ích bảo mật (hash, verify, mã hóa, ...)
class SecurityUtils {
  /// 🔐 Hash mật khẩu bằng SHA-256
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// ✅ Kiểm tra mật khẩu người dùng nhập có trùng hash không
  static bool verifyPassword(String plainPassword, String hashedPassword) {
    final enteredHash = hashPassword(plainPassword);
    return enteredHash == hashedPassword;
  }
}
