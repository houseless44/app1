import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/cloudinary_service.dart';
import '../models/user_model.dart';
import '../utils/security_utils.dart'; // ✅ Import file bảo mật tách riêng

class UserService {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');
  final _cloudinaryService = CloudinaryService();

  // ====================================================
  // 👤 QUẢN LÝ NGƯỜI DÙNG
  // ====================================================

  /// 🧩 Thêm người dùng mới
  Future<void> addUser(AppUser user) async {
    try {
      // 🔐 Hash mật khẩu trước khi lưu
      final hashedPassword = SecurityUtils.hashPassword(user.password);

      final docRef = await _usersCollection.add({
        'username': user.username,
        'email': user.email,
        'password': hashedPassword,
        'imageUrl': user.imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Cập nhật lại id của chính document (để tiện lấy sau này)
      await _usersCollection.doc(docRef.id).update({'id': docRef.id});
    } catch (e) {
      throw Exception('Lỗi khi thêm người dùng: $e');
    }
  }

  /// 🧩 Lấy danh sách người dùng (realtime stream)
  Stream<List<AppUser>> getUsers() {
    return _usersCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return AppUser.fromMap(data, doc.id);
      }).toList();
    });
  }

  /// 🧩 Cập nhật người dùng
  Future<void> updateUser(AppUser user) async {
    try {
      if (user.id == null || user.id!.isEmpty) {
        throw Exception('user.id không hợp lệ');
      }

      // 🔐 Hash lại mật khẩu mỗi khi cập nhật
      final hashedPassword = SecurityUtils.hashPassword(user.password);

      await _usersCollection.doc(user.id).update({
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

  /// 🧩 Xoá toàn bộ người dùng (bao gồm cả ảnh nếu có)
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
      return AppUser.fromMap(data, doc.id);
    } catch (e) {
      throw Exception('Lỗi khi lấy người dùng: $e');
    }
  }

}
