import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/cloudinary_service.dart';
import '../models/user_model.dart';
import '../utils/security_utils.dart'; // ✅ Hash mật khẩu

class UserService {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');
  final _cloudinaryService = CloudinaryService();

  // ====================================================
  // 👤 QUẢN LÝ NGƯỜI DÙNG
  // ====================================================

  /// 🧩 Thêm người dùng mới (❌ không lưu createdAt)
  Future<void> addUser(AppUser user) async {
    try {
      final hashedPassword = SecurityUtils.hashPassword(user.password);
      await _usersCollection.add({
        'username': user.username,
        'email': user.email,
        'password': hashedPassword,
        'imageUrl': user.imageUrl,
        // ❌ Đã bỏ 'createdAt'
      });
    } catch (e) {
      throw Exception('Lỗi khi thêm người dùng: $e');
    }
  }

  /// 🧩 Lấy danh sách người dùng (realtime stream, kèm id riêng)
  Stream<List<Map<String, dynamic>>> getUsers() {
    return _usersCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // 🔹 Trả về map gồm cả user (AppUser) và id (Firestore document ID)
        return {
          'id': doc.id,
          'user': AppUser.fromMap(data),
        };
      }).toList();
    });
  }

  /// 🧩 Cập nhật người dùng theo ID
  Future<void> updateUserById(String userId, AppUser user) async {
    try {
      final hashedPassword = SecurityUtils.hashPassword(user.password);
      await _usersCollection.doc(userId).update({
        'username': user.username,
        'email': user.email,
        'password': hashedPassword,
        'imageUrl': user.imageUrl,
      });
    } catch (e) {
      throw Exception('Lỗi khi cập nhật người dùng: $e');
    }
  }

  // ====================================================
  // 🧹 XOÁ NGƯỜI DÙNG & ẢNH
  // ====================================================

  /// 🧩 Xoá ảnh người dùng (nếu có)
  Future<void> deleteUserImage(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) return;

    try {
      final publicId = _cloudinaryService.extractPublicId(imageUrl);
      await _cloudinaryService.deleteImage(publicId);
    } catch (e) {
      throw Exception('Lỗi khi xoá ảnh người dùng: $e');
    }
  }

  /// 🧩 Xoá người dùng (bao gồm cả ảnh)
  Future<void> deleteUser(String userId, {String? imageUrl}) async {
    try {
      await deleteUserImage(imageUrl);
      await _usersCollection.doc(userId).delete();
    } catch (e) {
      throw Exception('Lỗi khi xoá người dùng: $e');
    }
  }

  // ====================================================
  // 🔎 LẤY THÔNG TIN NGƯỜI DÙNG
  // ====================================================

  /// 🧩 Lấy thông tin người dùng theo ID
  Future<AppUser?> getUserById(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      return AppUser.fromMap(data);
    } catch (e) {
      throw Exception('Lỗi khi lấy người dùng: $e');
    }
  }
}
