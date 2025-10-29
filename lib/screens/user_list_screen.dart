import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../widgets/user_card.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final UserService _userService = UserService();

  String _searchQuery = '';
  String _sortBy = 'az'; // az, za, newest, oldest

  void _openSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Tên A–Z'),
              onTap: () {
                setState(() => _sortBy = 'az');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Tên Z–A'),
              onTap: () {
                setState(() => _sortBy = 'za');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Mới nhất'),
              onTap: () {
                setState(() => _sortBy = 'newest');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Cũ nhất'),
              onTap: () {
                setState(() => _sortBy = 'oldest');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  List<AppUser> _applyFilters(List<AppUser> users) {
    List<AppUser> filtered = List.from(users);

    // 🔍 Tìm kiếm theo tên hoặc email
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((user) {
        return user.username.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query);
      }).toList();
    }

    // 🔽 Sắp xếp
    switch (_sortBy) {
      case 'az':
        filtered.sort((a, b) => a.username.compareTo(b.username));
        break;
      case 'za':
        filtered.sort((a, b) => b.username.compareTo(a.username));
        break;
      case 'newest':
        filtered.sort((a, b) {
          final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bTime.compareTo(aTime);
        });
        break;
      case 'oldest':
        filtered.sort((a, b) {
          final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return aTime.compareTo(bTime);
        });
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách người dùng'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _openSortOptions,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên hoặc email...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<AppUser>>(
        stream: _userService.getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Chưa có người dùng nào'));
          }

          // 💡 Không gọi setState ở đây
          final filteredUsers = _applyFilters(snapshot.data!);

          if (filteredUsers.isEmpty) {
            return const Center(child: Text('Không tìm thấy người dùng nào.'));
          }

          return ListView.builder(
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              return UserCard(user: filteredUsers[index]);
            },
          );
        },
      ),
    );
  }
}
