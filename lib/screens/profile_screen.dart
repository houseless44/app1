import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart'; // nhớ import màn hình đăng nhập của bạn

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 16),
          Text(
            user?.email ?? 'Không có email',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              // Điều hướng về màn hình đăng nhập
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
