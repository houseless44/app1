import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/user_model.dart';
import '../screens/edit_user_screen.dart';
import '../services/user_service.dart';

class UserCard extends StatelessWidget {
  final AppUser user;
  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final userService = UserService();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Slidable(
        key: ValueKey(user.id),

        // 👉 Vuốt sang trái để hiển thị các hành động
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.5,
          children: [
            SlidableAction(
              onPressed: (_) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditUserScreen(user: user),
                  ),
                );
              },
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Sửa',
            ),
            SlidableAction(
              onPressed: (_) async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Xác nhận xoá'),
                    content: Text('Bạn có chắc muốn xoá "${user.username}" không?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Huỷ'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Xoá'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await userService.deleteUser(user.id!, imageUrl: user.imageUrl);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã xoá người dùng "${user.username}"')),
                  );
                }
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Xoá',
            ),
          ],
        ),

        // 👉 Giao diện chính của thẻ
        child: Card(
          child: ListTile(
            leading: user.imageUrl != null
                ? CircleAvatar(backgroundImage: NetworkImage(user.imageUrl!))
                : const CircleAvatar(child: Icon(Icons.person)),
            title: Text(user.username),
            subtitle: Text(user.email),

            // 🟢 Thêm onTap để chuyển đến màn hình chỉnh sửa
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditUserScreen(user: user),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
