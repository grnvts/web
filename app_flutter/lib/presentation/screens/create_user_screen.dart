import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/di/app_container.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
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

  bool _isSaving = false;
  DateTime? _bornDate;
  String _selectedRole = 'ROLE_USER';

  static const List<String> _roles = <String>[
    'ROLE_USER',
    'ROLE_ADMIN',
    'ROLE_BRIGADIER',
    'ROLE_MASTER',
  ];

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _repeatPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final payload = <String, dynamic>{
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
        'password': _passwordController.text,
        'repeatPassword': _repeatPasswordController.text,
        'roles': <String>[_selectedRole],
      };

      await _userUseCases.createUser(payload);

      if (!mounted) return;
      _showInfo('User created');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to create user: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
    return Scaffold(
      appBar: AppBar(title: const Text('New user')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildSection(
                title: 'Core data',
                icon: Icons.badge_outlined,
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
                  DropdownButtonFormField<String>(
                    initialValue: _selectedRole,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: _roles
                        .map(
                          (role) => DropdownMenuItem<String>(
                            value: role,
                            child: Text(_roleLabel(role)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedRole = value);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: 'Personal info',
                icon: Icons.account_box_outlined,
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
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      hintText: '+375291112233',
                    ),
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
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Enter password';
                      if (value.length < 5) return 'At least 5 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _repeatPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Repeat password',
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Repeat password'
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isSaving ? null : _createUser,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_isSaving ? 'Creating...' : 'Create user'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
