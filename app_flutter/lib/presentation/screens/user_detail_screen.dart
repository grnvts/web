import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/di/app_container.dart';

class UserDetailScreen extends StatefulWidget {
  final String username;

  const UserDetailScreen({super.key, required this.username});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userUseCases = AppContainer.userUseCases;

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _patronymicController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic>? _user;
  DateTime? _bornDate;
  final Set<String> _selectedRoles = <String>{};

  static const List<String> _roles = <String>[
    'ROLE_USER',
    'ROLE_ADMIN',
    'ROLE_BRIGADIER',
    'ROLE_MASTER',
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _patronymicController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    setState(() => _isLoading = true);
    try {
      final user = await _userUseCases.getUserByUsername(widget.username);
      if (!mounted) return;

      setState(() {
        _user = user;
        _usernameController.text = user['username']?.toString() ?? '';
        _emailController.text = user['email']?.toString() ?? '';
        _nameController.text = user['name']?.toString() ?? '';
        _surnameController.text = user['surname']?.toString() ?? '';
        _patronymicController.text = user['patronymic']?.toString() ?? '';
        _phoneController.text = user['phone']?.toString() ?? '';
        _bornDate = _parseDate(user['bornDate']?.toString());
        _selectedRoles
          ..clear()
          ..addAll(
            (user['roles'] as List<dynamic>? ?? const <dynamic>[])
                .map((role) => role.toString())
                .where((role) => role.isNotEmpty),
          );
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load user: $e'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
    }
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _bornDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _bornDate = picked);
    }
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text.isNotEmpty &&
        _passwordController.text != _repeatPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedRoles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select at least one role'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final payload = <String, dynamic>{
        'id': _user?['id'],
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'name': _nameController.text.trim(),
        'surname': _surnameController.text.trim(),
        'patronymic': _patronymicController.text.trim(),
        'phone': _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        'bornDate': _bornDate == null
            ? null
            : DateFormat('yyyy-MM-dd').format(_bornDate!),
        'roles': _selectedRoles.toList(),
      };

      if (_passwordController.text.isNotEmpty) {
        payload['password'] = _passwordController.text;
        payload['repeatPassword'] = _repeatPasswordController.text;
      }

      await _userUseCases.updateUser(widget.username, payload);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User updated')));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update user: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
      default:
        return 'User';
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
      default:
        return Colors.grey;
    }
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: const Color(0xFF6366F1)),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('User profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final user = _user ?? <String, dynamic>{};
    final roles = (user['roles'] as List<dynamic>? ?? const <dynamic>[])
        .map((role) => role.toString())
        .toList();
    final qualifications =
        user['qualifications'] as List<dynamic>? ?? const <dynamic>[];

    return Scaffold(
      appBar: AppBar(title: Text('User @${user['username'] ?? ''}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${user['surname'] ?? ''} ${user['name'] ?? ''} ${user['patronymic'] ?? ''}'
                            .trim(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '@${user['username'] ?? ''}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: <Widget>[
                          ...roles.map(
                            (role) => Chip(
                              backgroundColor: _roleColor(
                                role,
                              ).withValues(alpha: 0.12),
                              side: BorderSide(
                                color: _roleColor(role).withValues(alpha: 0.18),
                              ),
                              label: Text(_roleLabel(role)),
                            ),
                          ),
                          Chip(
                            label: Text(
                              (user['status'] ?? 1) == 1 ? 'Active' : 'Deleted',
                            ),
                          ),
                        ],
                      ),
                      if (qualifications.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: qualifications
                              .map(
                                (qualification) => Chip(
                                  label: Text(
                                    qualification['name']?.toString() ??
                                        'Qualification',
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: 'Roles',
                icon: Icons.admin_panel_settings_outlined,
                children: <Widget>[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _roles
                        .map(
                          (role) => FilterChip(
                            selected: _selectedRoles.contains(role),
                            label: Text(_roleLabel(role)),
                            onSelected: (value) {
                              setState(() {
                                if (value) {
                                  _selectedRoles.add(role);
                                } else {
                                  _selectedRoles.remove(role);
                                }
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: 'Core data',
                icon: Icons.account_box_outlined,
                children: <Widget>[
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter username'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty)
                        return 'Enter email';
                      if (!value.contains('@')) return 'Invalid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: 'Personal info',
                icon: Icons.badge_outlined,
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
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Birth date',
                      ),
                      child: Text(
                        _bornDate == null
                            ? 'Select date'
                            : DateFormat('yyyy-MM-dd').format(_bornDate!),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: 'Security',
                icon: Icons.lock_outline,
                children: <Widget>[
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New password',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _repeatPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Repeat password',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isSaving ? null : _saveUser,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_isSaving ? 'Saving...' : 'Save changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
