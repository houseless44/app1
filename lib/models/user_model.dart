import 'package:cloud_firestore/cloud_firestore.dart';


class AppUser {
  final String? id;            // ID của document trong Firestore
  final String username;       // Tên người dùng
  final String email;          // Email
  final String password;       // Mật khẩu (chỉ nên lưu mã hoá trong thực tế)
  final String? imageUrl;      // URL ảnh Cloudinary
  final DateTime? createdAt;   // Thời gian tạo

  AppUser({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    this.imageUrl,
    this.createdAt,
  });

  /// 🧩 Tạo đối tượng AppUser từ dữ liệu Firestore
  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      id: id,
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      imageUrl: map['imageUrl'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : (map['createdAt'] as DateTime))
          : null,
    );
  }

  /// 🧩 Chuyển đối tượng thành Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'imageUrl': imageUrl,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }

  /// 🧩 Sao chép AppUser với các giá trị thay đổi
  AppUser copyWith({
    String? id,
    String? username,
    String? email,
    String? password,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
