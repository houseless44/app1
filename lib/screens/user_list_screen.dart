import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../widgets/user_card.dart';

class UserListBody extends StatefulWidget {
  const UserListBody({super.key});

  @override
  State<UserListBody> createState() => _UserListBodyState();
}

class _UserListBodyState extends State<UserListBody> {
  final UserService _userService = UserService();

  String _searchQuery = '';
  String _sortBy = 'az'; // az, za
  int _currentPage = 1;
  final int _pageSize = 15;

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

    // 🔽 Sắp xếp theo tên
    switch (_sortBy) {
      case 'az':
        filtered.sort((a, b) => a.username.compareTo(b.username));
        break;
      case 'za':
        filtered.sort((a, b) => b.username.compareTo(a.username));
        break;
    }

    return filtered;
  }

  void _changePage(int newPage, int totalPages) {
    if (newPage >= 1 && newPage <= totalPages) {
      setState(() => _currentPage = newPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔍 Thanh tìm kiếm + sắp xếp
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
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
                    setState(() {
                      _searchQuery = value;
                      _currentPage = 1; // reset về trang đầu khi tìm
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.sort, color: Colors.blueAccent),
                onPressed: _openSortOptions,
              ),
            ],
          ),
        ),

        // 📋 Danh sách người dùng + thống kê
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _userService.getUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Chưa có người dùng nào'));
              }

              final userMaps = snapshot.data!;
              final users = userMaps.map((e) => e['user'] as AppUser).toList();
              final filteredUsers = _applyFilters(users);

              final totalCount = users.length;
              final filteredCount = filteredUsers.length;

              // 📄 Phân trang
              final totalPages =
                  (filteredUsers.length / _pageSize).ceil().clamp(1, double.infinity).toInt();
              final startIndex = (_currentPage - 1) * _pageSize;
              final endIndex =
                  (_currentPage * _pageSize).clamp(0, filteredUsers.length);
              final currentPageUsers = filteredUsers.sublist(
                  startIndex, endIndex > filteredUsers.length ? filteredUsers.length : endIndex);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Thanh thống kê kết quả
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'Tổng số người dùng: $totalCount'
                          : 'Tìm thấy: $filteredCount / $totalCount người dùng',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const Divider(height: 1),

                  // 🔹 Danh sách hiển thị
                  Expanded(
                    child: currentPageUsers.isEmpty
                        ? const Center(
                            child: Text('Không tìm thấy người dùng nào.'))
                        : ListView.builder(
                            itemCount: currentPageUsers.length,
                            itemBuilder: (context, index) {
                              final user = currentPageUsers[index];
                              final userId = userMaps
                                  .firstWhere((e) => e['user'] == user)['id']
                                  as String;

                              return UserCard(userId: userId, user: user);
                            },
                          ),
                  ),

                  // 🔹 Thanh phân trang
                  if (totalPages > 1)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: _currentPage > 1
                                ? () => _changePage(_currentPage - 1, totalPages)
                                : null,
                          ),
                          Text(
                            'Trang $_currentPage / $totalPages',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: _currentPage < totalPages
                                ? () => _changePage(_currentPage + 1, totalPages)
                                : null,
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
