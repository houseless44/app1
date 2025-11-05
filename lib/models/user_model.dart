/// 🧩 Mô hình dữ liệu người dùng cho ứng dụng Flutter với Firestore
class AppUser {
  final String username;   // Tên người dùng
  final String email;      // Email
  final String password;   // Mật khẩu (nên được mã hoá)
  final String? imageUrl;  // URL ảnh Cloudinary (có thể null)

  AppUser({
    required this.username,
    required this.email,
    required this.password,
    this.imageUrl,
  });

  /// 🧩 Tạo đối tượng AppUser từ dữ liệu Firestore
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      imageUrl: map['imageUrl'],
    );
  }

  /// 🧩 Chuyển đối tượng thành Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'imageUrl': imageUrl,
    };
  }

  /// 🧩 Sao chép AppUser với các giá trị thay đổi
  AppUser copyWith({
    String? username,
    String? email,
    String? password,
    String? imageUrl,
  }) {
    return AppUser(
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
