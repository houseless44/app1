import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloudinary_public/cloudinary_public.dart';

/// 🧠 Service quản lý upload & xoá ảnh Cloudinary.
/// Upload được thực hiện trực tiếp từ Flutter.
/// Xoá ảnh cần gọi qua API trung gian NodeJS để bảo mật.
class CloudinaryService {
  // 🌩️ Khai báo thông tin Cloudinary
  static const String cloudName = 'dpxuoswpf';
  static const String uploadPreset =
      'flutter_uploads'; // bạn phải tạo preset này (unsigned)
  static const String serverBaseUrl =
      'http://10.0.2.2:3000'; // 🌐 địa chỉ server NodeJS trung gian của bạn

  final cloudinary = CloudinaryPublic(cloudName, uploadPreset, cache: false);

  /// 📤 Upload ảnh từ file (Flutter → Cloudinary)
  Future<String> uploadImage(File imageFile) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      return response.secureUrl; // trả về URL ảnh sau khi upload thành công
    } catch (e) {
      throw Exception('Upload ảnh thất bại: $e');
    }
  }

  /// 🗑️ Xóa ảnh khỏi Cloudinary thông qua server NodeJS trung gian
  Future<void> deleteImage(String publicId) async {
    try {
      // ⚙️ Đổi URL cho đúng route backend
      final url = Uri.parse(
        '$serverBaseUrl/delete_cloudinary_image',
      );

      // ⚙️ Đổi key thành 'public_id' để backend hiểu
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'public_id': publicId}),
      );

      if (response.statusCode == 200) {
        print('✅ Ảnh đã được xóa thành công trên Cloudinary.');
      } else {
        throw Exception(
          'Lỗi khi xoá ảnh (mã ${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      throw Exception(':((((( Xóa ảnh thất bại: $e');
    }
  }

  /// 🔍 Hàm tiện ích: lấy `public_id` từ URL ảnh
  /// Cloudinary URL ví dụ:
  /// https://res.cloudinary.com/dpxuoswpf/image/upload/v1761744144/ten_anh.jpg
  /// → public_id = "ten_anh"
  String extractPublicId(String imageUrl) {
    final uri = Uri.parse(imageUrl);
    final segments = uri.pathSegments;
    if (segments.length > 2) {
      // /image/upload/v123456/ten_anh.jpg
      final fileName = segments.last;
      return fileName.split('.').first;
    }
    throw Exception('Không thể trích xuất public_id từ URL.');
  }
}
