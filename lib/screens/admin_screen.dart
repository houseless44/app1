import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_list_screen.dart';
import 'add_user_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý người dùng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          )
        ],
      ),
      body: const UserListScreen(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddUserScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
