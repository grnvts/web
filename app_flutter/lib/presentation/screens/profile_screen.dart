import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/config/app_config.dart';
import '../../core/di/app_container.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userUseCases = AppContainer.userUseCases;
  final _authUseCases = AppContainer.authUseCases;
  final _imagePicker = ImagePicker();

  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _patronymicController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditing = false;

  Map<String, dynamic>? _user;
  Uint8List? _selectedImageBytes;
  String? _imageUrl;
  DateTime? _bornDate;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _patronymicController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final username = await _authUseCases.getUsername();
      if (username == null || username.isEmpty) {
        throw Exception('Failed to resolve current user');
      }

      final user = await _userUseCases.getUserByUsername(username);
      if (!mounted) return;

      setState(() {
        _user = user;
        _nameController.text = user['name']?.toString() ?? '';
        _surnameController.text = user['surname']?.toString() ?? '';
        _patronymicController.text = user['patronymic']?.toString() ?? '';
        _emailController.text = user['email']?.toString() ?? '';
        _phoneController.text = user['phone']?.toString() ?? '';
        _imageUrl = user['image']?.toString();
        _bornDate = _parseDate(user['bornDate']?.toString());
        _selectedImageBytes = null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickImage() async {
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() => _selectedImageBytes = bytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
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

  String _normalizePhone(String phone) {
    var value = phone.trim();
    if (value.isEmpty) return value;
    if (value.startsWith('+')) return value;
    if (value.startsWith('375')) return '+$value';
    if (value.startsWith('80')) return '+3$value';
    return '+375$value';
  }

  Future<void> _uploadImageIfNeeded(String username) async {
    if (_selectedImageBytes == null) return;
    final encoded = base64Encode(_selectedImageBytes!);
    final result = await _userUseCases.uploadImage(username, encoded);
    _imageUrl = result['image']?.toString();
    _selectedImageBytes = null;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      final username = await _authUseCases.getUsername();
      if (username == null || username.isEmpty) {
        throw Exception('Failed to resolve current user');
      }

      await _uploadImageIfNeeded(username);

      final phone = _normalizePhone(_phoneController.text);
      final payload = <String, dynamic>{
        'id': _user?['id'],
        'username': username,
        'name': _nullable(_nameController.text),
        'surname': _nullable(_surnameController.text),
        'patronymic': _nullable(_patronymicController.text),
        'email': _emailController.text.trim(),
        'phone': phone.isEmpty ? null : phone,
        'bornDate': _bornDate == null
            ? null
            : DateFormat('yyyy-MM-dd').format(_bornDate!),
      };

      await _userUseCases.updateUser(username, payload);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated')));
      setState(() => _isEditing = false);
      await _loadProfile();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _selectedImageBytes = null;
    });
    _loadProfile();
  }

  String? _nullable(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _initials() {
    final displayName = _displayName();
    return displayName.isEmpty
        ? 'U'
        : displayName.substring(0, 1).toUpperCase();
  }

  String _displayName() {
    final fullName =
        '${_surnameController.text.trim()} ${_nameController.text.trim()} ${_patronymicController.text.trim()}'
            .trim();
    return fullName.isEmpty ? (_user?['username']?.toString() ?? '') : fullName;
  }

  Widget _buildAvatar() {
    final serverImageUrl = _imageUrl != null && _imageUrl!.isNotEmpty
        ? '${AppConfig.imageBaseUrl}/$_imageUrl'
        : null;

    Widget child;
    if (_selectedImageBytes != null) {
      child = Image.memory(
        _selectedImageBytes!,
        fit: BoxFit.cover,
        width: 140,
        height: 140,
      );
    } else if (serverImageUrl != null) {
      child = Image.network(
        serverImageUrl,
        fit: BoxFit.cover,
        width: 140,
        height: 140,
        errorBuilder: (_, __, ___) => _buildAvatarFallback(),
      );
    } else {
      child = _buildAvatarFallback();
    }

    return GestureDetector(
      onTap: _isEditing ? _pickImage : null,
      child: Stack(
        children: <Widget>[
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(70),
              border: Border.all(
                color: const Color(0xFF0F766E).withValues(alpha: 0.3),
                width: 3,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFF0F766E).withValues(alpha: 0.16),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(70),
              child: child,
            ),
          ),
          if (_isEditing)
            const Positioned(
              right: 4,
              bottom: 4,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFF0F766E),
                child: Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            const Color(0xFF0F766E).withValues(alpha: 0.2),
            const Color(0xFF0F766E).withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          _initials(),
          style: const TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F766E),
          ),
        ),
      ),
    );
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
                    color: const Color(0xFF0F766E).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: const Color(0xFF0F766E)),
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final roles = (_user?['roles'] as List<dynamic>? ?? const <dynamic>[])
        .map((role) => role.toString())
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: <Widget>[
          if (!_isEditing)
            IconButton(
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Edit',
              icon: const Icon(Icons.edit_outlined),
            )
          else
            IconButton(
              onPressed: _cancelEdit,
              tooltip: 'Cancel',
              icon: const Icon(Icons.close_rounded),
            ),
        ],
      ),
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
                    children: <Widget>[
                      _buildAvatar(),
                      const SizedBox(height: 18),
                      Text(
                        _displayName(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '@${_user?['username'] ?? ''}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: roles
                            .map(
                              (role) => Chip(
                                label: Text(role.replaceFirst('ROLE_', '')),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: 'Contact info',
                icon: Icons.contact_mail_outlined,
                children: <Widget>[
                  TextFormField(
                    controller: _emailController,
                    enabled: _isEditing,
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
                    enabled: _isEditing,
                    decoration: const InputDecoration(labelText: 'Phone'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: 'Personal data',
                icon: Icons.badge_outlined,
                children: <Widget>[
                  TextFormField(
                    controller: _surnameController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(labelText: 'Surname'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _patronymicController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(labelText: 'Patronymic'),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _isEditing ? _selectDate : null,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Birth date',
                      ),
                      child: Text(
                        _bornDate == null
                            ? 'Not set'
                            : DateFormat('yyyy-MM-dd').format(_bornDate!),
                      ),
                    ),
                  ),
                ],
              ),
              if (_isEditing) ...<Widget>[
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _isSaving ? null : _saveProfile,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_isSaving ? 'Saving...' : 'Save profile'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
