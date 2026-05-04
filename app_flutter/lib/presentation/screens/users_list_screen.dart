import 'package:flutter/material.dart';

import '../../core/di/app_container.dart';
import 'create_user_screen.dart';
import 'user_detail_screen.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  final _userUseCases = AppContainer.userUseCases;
  final _searchController = TextEditingController();

  List<dynamic> _users = <dynamic>[];
  List<dynamic> _filteredUsers = <dynamic>[];
  bool _isLoading = true;
  int _currentPage = 0;
  final int _pageSize = 10;
  bool _hasNextPage = false;
  bool _hasPreviousPage = false;
  String _selectedRole = '';
  String _sortKey = 'surname';
  bool _sortAscending = true;

  static const List<String> _roles = <String>[
    '',
    'ROLE_ADMIN',
    'ROLE_USER',
    'ROLE_BRIGADIER',
    'ROLE_MASTER',
  ];

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
    setState(() => _isLoading = true);
    try {
      final response = await _userUseCases.getUsers(_currentPage, _pageSize);
      if (!mounted) return;
      setState(() {
        _users = response['content'] as List<dynamic>? ?? <dynamic>[];
        _hasNextPage = !(response['last'] as bool? ?? true);
        _hasPreviousPage = !(response['first'] as bool? ?? true);
        _isLoading = false;
      });
      _filterUsers();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load users: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase().trim();
    final filtered = _users.where((user) {
      final roles = (user['roles'] as List<dynamic>? ?? const <dynamic>[])
          .map((role) => role.toString())
          .toList();
      final fullName =
          '${user['surname'] ?? ''} ${user['name'] ?? ''} ${user['patronymic'] ?? ''}'
              .toLowerCase();
      final matchesRole =
          _selectedRole.isEmpty || roles.contains(_selectedRole);
      final matchesSearch =
          query.isEmpty ||
          (user['username']?.toString().toLowerCase().contains(query) ??
              false) ||
          (user['email']?.toString().toLowerCase().contains(query) ?? false) ||
          fullName.contains(query);
      return matchesRole && matchesSearch;
    }).toList();

    filtered.sort((a, b) {
      final aValue = a[_sortKey]?.toString() ?? '';
      final bValue = b[_sortKey]?.toString() ?? '';
      final result = aValue.compareTo(bValue);
      return _sortAscending ? result : -result;
    });

    setState(() => _filteredUsers = filtered);
  }

  void _sortBy(String key) {
    setState(() {
      if (_sortKey == key) {
        _sortAscending = !_sortAscending;
      } else {
        _sortKey = key;
        _sortAscending = true;
      }
    });
    _filterUsers();
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'ROLE_ADMIN':
        return 'Admin';
      case 'ROLE_BRIGADIER':
        return 'Brigadier';
      case 'ROLE_MASTER':
        return 'Master';
      case 'ROLE_USER':
        return 'User';
      default:
        return 'All roles';
    }
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'ROLE_ADMIN':
        return Colors.red;
      case 'ROLE_BRIGADIER':
        return Colors.orange;
      case 'ROLE_MASTER':
        return Colors.blue;
      case 'ROLE_USER':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _fullName(dynamic user) {
    final fullName =
        '${user['surname'] ?? ''} ${user['name'] ?? ''} ${user['patronymic'] ?? ''}'
            .trim();
    return fullName.isEmpty
        ? (user['username']?.toString() ?? 'No name')
        : fullName;
  }

  String _initials(dynamic user) {
    final fullName = _fullName(user);
    return fullName.isEmpty ? 'U' : fullName.substring(0, 1).toUpperCase();
  }

  Future<void> _openCreateUser() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(builder: (_) => const CreateUserScreen()),
    );
    if (updated == true && mounted) {
      await _loadUsers();
    }
  }

  Future<void> _openUser(dynamic user) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => UserDetailScreen(username: user['username'].toString()),
      ),
    );
    if (updated == true && mounted) {
      await _loadUsers();
    }
  }

  Future<void> _deleteUser(int userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete user?'),
        content: const Text(
          'The user will be deactivated and removed from active list.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _userUseCases.deleteUser(userId);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User deleted')));
      await _loadUsers();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete user: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _restoreUser(int userId) async {
    try {
      await _userUseCases.restoreUser(userId);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User restored')));
      await _loadUsers();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to restore user: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _openCreateMasterDialog() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => const _CreateMasterDialog(),
    );
    if (created == true && mounted) {
      await _loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.12)),
              ),
            ),
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    hintText: 'Name, email or username',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Role filter',
                        ),
                        items: _roles
                            .map(
                              (role) => DropdownMenuItem<String>(
                                value: role,
                                child: Text(_roleLabel(role)),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedRole = value ?? '');
                          _filterUsers();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.outlined(
                      tooltip: 'Sort by surname',
                      onPressed: () => _sortBy('surname'),
                      icon: Icon(
                        _sortAscending
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _openCreateMasterDialog,
                      icon: const Icon(Icons.engineering_outlined),
                      label: const Text('Master'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _openCreateUser,
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      label: const Text('User'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                ? Center(
                    child: Text(
                      'No users found',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 16,
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadUsers,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
                        final roles =
                            (user['roles'] as List<dynamic>? ??
                                    const <dynamic>[])
                                .map((role) => role.toString())
                                .toList();
                        final isDeleted = (user['status'] ?? 1) == 0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.12),
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => _openUser(user),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundColor: const Color(
                                          0xFF6366F1,
                                        ).withValues(alpha: 0.12),
                                        foregroundColor: const Color(
                                          0xFF6366F1,
                                        ),
                                        child: Text(
                                          _initials(user),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 22,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              _fullName(user),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 17,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '@${user['username'] ?? ''}',
                                              style: TextStyle(
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                            if ((user['email']
                                                    ?.toString()
                                                    .isNotEmpty ??
                                                false))
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 2,
                                                ),
                                                child: Text(
                                                  user['email'].toString(),
                                                  style: TextStyle(
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      if (isDeleted)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: const Text(
                                            'Deleted',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: roles
                                        .map(
                                          (role) => Chip(
                                            backgroundColor: _roleColor(
                                              role,
                                            ).withValues(alpha: 0.12),
                                            side: BorderSide(
                                              color: _roleColor(
                                                role,
                                              ).withValues(alpha: 0.18),
                                            ),
                                            label: Text(_roleLabel(role)),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: <Widget>[
                                      if (!isDeleted)
                                        OutlinedButton.icon(
                                          onPressed: () => _deleteUser(
                                            (user['id'] as num).toInt(),
                                          ),
                                          icon: const Icon(
                                            Icons.delete_outline_rounded,
                                          ),
                                          label: const Text('Delete'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                        )
                                      else
                                        OutlinedButton.icon(
                                          onPressed: () => _restoreUser(
                                            (user['id'] as num).toInt(),
                                          ),
                                          icon: const Icon(
                                            Icons.restore_rounded,
                                          ),
                                          label: const Text('Restore'),
                                        ),
                                      const SizedBox(width: 8),
                                      OutlinedButton.icon(
                                        onPressed: () => _openUser(user),
                                        icon: const Icon(
                                          Icons.open_in_new_rounded,
                                        ),
                                        label: const Text('Open'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _hasPreviousPage
                          ? () {
                              setState(() => _currentPage -= 1);
                              _loadUsers();
                            }
                          : null,
                      icon: const Icon(Icons.chevron_left_rounded),
                      label: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Page ${_currentPage + 1}'),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _hasNextPage
                          ? () {
                              setState(() => _currentPage += 1);
                              _loadUsers();
                            }
                          : null,
                      icon: const Icon(Icons.chevron_right_rounded),
                      label: const Text('Next'),
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

class _CreateMasterDialog extends StatefulWidget {
  const _CreateMasterDialog();

  @override
  State<_CreateMasterDialog> createState() => _CreateMasterDialogState();
}

class _CreateMasterDialogState extends State<_CreateMasterDialog> {
  final _formKey = GlobalKey<FormState>();
  final _userUseCases = AppContainer.userUseCases;
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _patronymicController = TextEditingController();

  bool _isLoadingQualifications = true;
  bool _isSaving = false;
  List<dynamic> _qualifications = <dynamic>[];
  final Set<int> _selectedQualificationIds = <int>{};

  @override
  void initState() {
    super.initState();
    _loadQualifications();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _patronymicController.dispose();
    super.dispose();
  }

  Future<void> _loadQualifications() async {
    try {
      final qualifications = await _userUseCases.getQualifications();
      if (!mounted) return;
      setState(() {
        _qualifications = qualifications;
        _isLoadingQualifications = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingQualifications = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load qualifications: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedQualificationIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select at least one qualification'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _userUseCases.createMaster(<String, dynamic>{
        'name': _nameController.text.trim(),
        'surname': _surnameController.text.trim(),
        'patronymic': _patronymicController.text.trim(),
        'qualificationIds': _selectedQualificationIds.toList(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Master created')));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create master: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New master'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: _surnameController,
                  decoration: const InputDecoration(labelText: 'Surname'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter surname'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter name'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _patronymicController,
                  decoration: const InputDecoration(labelText: 'Patronymic'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter patronymic'
                      : null,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Qualifications',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (_isLoadingQualifications)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _qualifications.map((qualification) {
                      final id = (qualification['id'] as num?)?.toInt();
                      final label =
                          qualification['name']?.toString() ?? 'Qualification';
                      final selected =
                          id != null && _selectedQualificationIds.contains(id);
                      return FilterChip(
                        selected: selected,
                        label: Text(label),
                        onSelected: id == null
                            ? null
                            : (value) {
                                setState(() {
                                  if (value) {
                                    _selectedQualificationIds.add(id);
                                  } else {
                                    _selectedQualificationIds.remove(id);
                                  }
                                });
                              },
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child: Text(_isSaving ? 'Creating...' : 'Create'),
        ),
      ],
    );
  }
}
