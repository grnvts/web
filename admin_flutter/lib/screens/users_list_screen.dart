import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'user_detail_screen.dart';
import 'create_user_screen.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  final _userService = UserService();
  final _searchController = TextEditingController();
  
  List<dynamic> _users = [];
  List<dynamic> _filteredUsers = [];
  bool _isLoading = true;
  int _currentPage = 0;
  int _pageSize = 10;
  bool _hasNextPage = false;
  bool _hasPreviousPage = false;
  String _selectedRole = '';
  String _sortKey = 'surname';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _userService.getUsers(_currentPage, _pageSize);
      setState(() {
        _users = response['content'] ?? [];
        _hasNextPage = !(response['last'] ?? true);
        _hasPreviousPage = !(response['first'] ?? true);
        _filterUsers();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _users.where((user) {
        final matchesRole = _selectedRole.isEmpty ||
            (user['roles'] as List<dynamic>?)?.contains(_selectedRole) == true;
        final matchesSearch = query.isEmpty ||
            (user['username']?.toString().toLowerCase().contains(query) ??
                false) ||
            (user['name']?.toString().toLowerCase().contains(query) ?? false) ||
            (user['surname']?.toString().toLowerCase().contains(query) ??
                false) ||
            (user['email']?.toString().toLowerCase().contains(query) ?? false);
        return matchesRole && matchesSearch;
      }).toList();

      // Сортировка
      _filteredUsers.sort((a, b) {
        final aValue = a[_sortKey]?.toString() ?? '';
        final bValue = b[_sortKey]?.toString() ?? '';
        final comparison = aValue.compareTo(bValue);
        return _sortAscending ? comparison : -comparison;
      });
    });
  }

  void _sortBy(String key) {
    setState(() {
      if (_sortKey == key) {
        _sortAscending = !_sortAscending;
      } else {
        _sortKey = key;
        _sortAscending = true;
      }
      _filterUsers();
    });
  }

  IconData _getSortIcon(String key) {
    if (_sortKey != key) return Icons.unfold_more;
    return _sortAscending ? Icons.arrow_upward : Icons.arrow_downward;
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'ROLE_ADMIN':
        return Colors.red;
      case 'ROLE_BRIGADIER':
        return Colors.orange;
      case 'ROLE_MASTER':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getInitials(dynamic user) {
    final name = user['name']?.toString() ?? '';
    final username = user['username']?.toString() ?? '';
    
    if (name.isNotEmpty) {
      return name[0].toUpperCase();
    } else if (username.isNotEmpty) {
      return username[0].toUpperCase();
    }
    return 'U';
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Не указана';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildUserInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _deleteUser(int userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить пользователя?'),
        content: const Text('Вы уверены, что хотите удалить этого пользователя?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _userService.deleteUser(userId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Пользователь удален')),
          );
          _loadUsers();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _restoreUser(int userId) async {
    try {
      await _userService.restoreUser(userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пользователь восстановлен')),
        );
        _loadUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.people_rounded, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 14),
            const Text(
              'Управление пользователями',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Фильтры и поиск
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Поиск',
                    hintText: 'Поиск по имени, email или логину...',
                    prefixIcon: Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF6366F1),
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedRole.isEmpty ? null : _selectedRole,
                        decoration: InputDecoration(
                          labelText: 'Роль',
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.filter_list_rounded,
                              color: Color(0xFF6366F1),
                              size: 20,
                            ),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: '', child: Text('Все роли')),
                          DropdownMenuItem(
                            value: 'ROLE_ADMIN',
                            child: Text('Администратор'),
                          ),
                          DropdownMenuItem(
                            value: 'ROLE_USER',
                            child: Text('Пользователь'),
                          ),
                          DropdownMenuItem(
                            value: 'ROLE_BRIGADIER',
                            child: Text('Бригадир'),
                          ),
                          DropdownMenuItem(
                            value: 'ROLE_MASTER',
                            child: Text('Мастер'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value ?? '';
                            _filterUsers();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreateUserScreen(),
                            ),
                          ).then((_) => _loadUsers());
                        },
                        icon: const Icon(Icons.person_add_rounded, size: 20),
                        label: const Text(
                          'Создать',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Таблица пользователей
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Пользователи не найдены',
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadUsers,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            final roles = user['roles'] as List<dynamic>? ?? [];
                            final status = user['status'] ?? 1;
                            final isDeleted = status == 0;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.1),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => UserDetailScreen(
                                          username: user['username'],
                                        ),
                                      ),
                                    ).then((_) => _loadUsers());
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 64,
                                              height: 64,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    const Color(0xFF6366F1).withOpacity(0.2),
                                                    const Color(0xFF8B5CF6).withOpacity(0.2),
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: const Color(0xFF6366F1).withOpacity(0.3),
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  _getInitials(user),
                                                  style: const TextStyle(
                                                    color: Color(0xFF6366F1),
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 24,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${user['surname'] ?? ''} ${user['name'] ?? ''} ${user['patronymic'] ?? ''}'.trim(),
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 18,
                                                      color: Color(0xFF1E293B),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '@${user['username'] ?? ''}',
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (isDeleted)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: Colors.red.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: Colors.red.withOpacity(0.3),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Удален',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.05),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            children: [
                                              _buildUserInfoRow(
                                                Icons.email_outlined,
                                                'Email',
                                                user['email'] ?? 'Не указан',
                                              ),
                                              const SizedBox(height: 10),
                                              if (user['phone'] != null && user['phone'].toString().isNotEmpty)
                                                _buildUserInfoRow(
                                                  Icons.phone_outlined,
                                                  'Телефон',
                                                  user['phone'] ?? 'Не указан',
                                                ),
                                              if (user['phone'] != null && user['phone'].toString().isNotEmpty)
                                                const SizedBox(height: 10),
                                              if (user['bornDate'] != null)
                                                _buildUserInfoRow(
                                                  Icons.calendar_today_outlined,
                                                  'Дата рождения',
                                                  _formatDate(user['bornDate']),
                                                ),
                                              if (user['bornDate'] != null)
                                                const SizedBox(height: 10),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children: roles.map((role) {
                                            return Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getRoleColor(role.toString()).withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: _getRoleColor(role.toString()).withOpacity(0.3),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                role.toString().replaceAll('ROLE_', ''),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: _getRoleColor(role.toString()),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF6366F1).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.edit_rounded,
                                                  color: Color(0xFF6366F1),
                                                  size: 20,
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => UserDetailScreen(
                                                        username: user['username'],
                                                      ),
                                                    ),
                                                  ).then((_) => _loadUsers());
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: (isDeleted ? Colors.green : Colors.red).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: IconButton(
                                                icon: Icon(
                                                  isDeleted ? Icons.restore_rounded : Icons.delete_rounded,
                                                  color: isDeleted ? Colors.green : Colors.red,
                                                  size: 20,
                                                ),
                                                onPressed: () => isDeleted
                                                    ? _restoreUser(user['id'])
                                                    : _deleteUser(user['id']),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
          // Пагинация
          if (!_isLoading && _filteredUsers.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: _hasPreviousPage ? const Color(0xFF6366F1).withOpacity(0.1) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextButton.icon(
                      onPressed: _hasPreviousPage
                          ? () {
                              setState(() {
                                _currentPage--;
                              });
                              _loadUsers();
                            }
                          : null,
                      icon: const Icon(Icons.chevron_left_rounded, size: 20),
                      label: const Text(
                        'Предыдущая',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: _hasPreviousPage ? const Color(0xFF6366F1) : Colors.grey,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Страница ${_currentPage + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: _hasNextPage ? const Color(0xFF6366F1).withOpacity(0.1) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextButton.icon(
                      onPressed: _hasNextPage
                          ? () {
                              setState(() {
                                _currentPage++;
                              });
                              _loadUsers();
                            }
                          : null,
                      icon: const Icon(Icons.chevron_right_rounded, size: 20),
                      label: const Text(
                        'Следующая',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: _hasNextPage ? const Color(0xFF6366F1) : Colors.grey,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

