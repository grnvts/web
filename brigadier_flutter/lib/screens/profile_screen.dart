import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();
  final _authService = AuthService();
  final _imagePicker = ImagePicker();
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditing = false;
  Map<String, dynamic>? _user;
  File? _selectedImage;
  String? _imageUrl;

  // Контроллеры
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _patronymicController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _bornDate;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');
      
      if (username == null) {
        throw Exception('Пользователь не найден');
      }

      final user = await _userService.getUserByUsername(username);
      
      setState(() {
        _user = user;
        _nameController.text = user['name'] ?? '';
        _surnameController.text = user['surname'] ?? '';
        _patronymicController.text = user['patronymic'] ?? '';
        _emailController.text = user['email'] ?? '';
        _phoneController.text = user['phone'] ?? '';
        _imageUrl = user['image'];
        
        if (user['bornDate'] != null) {
          try {
            _bornDate = DateTime.parse(user['bornDate']);
          } catch (e) {
            _bornDate = null;
          }
        }
        
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки профиля: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка выбора изображения: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String> _imageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');
      
      if (username == null) {
        throw Exception('Пользователь не найден');
      }

      final base64Image = await _imageToBase64(_selectedImage!);
      final result = await _userService.uploadImage(username, base64Image);
      
      setState(() {
        _imageUrl = result['image'];
        _selectedImage = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Аватар успешно обновлен'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки аватара: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(1900, 1, 1);
    final lastDate = DateTime(now.year - 18, 12, 31);

    final picked = await showDatePicker(
      context: context,
      initialDate: _bornDate ?? lastDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('ru', 'RU'),
    );

    if (picked != null) {
      setState(() {
        _bornDate = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');
      
      if (username == null) {
        throw Exception('Пользователь не найден');
      }

      // Сначала загружаем изображение, если выбрано
      if (_selectedImage != null) {
        await _uploadImage();
      }

      // Форматируем телефон, если он указан
      String? phone = _phoneController.text.trim();
      if (phone.isNotEmpty && !phone.startsWith('+')) {
        // Если телефон не начинается с +, добавляем +375 (Беларусь)
        if (phone.startsWith('375')) {
          phone = '+$phone';
        } else if (phone.startsWith('80')) {
          phone = '+3$phone';
        } else {
          phone = '+375$phone';
        }
      }
      
      final updateData = {
        'username': username, // Обязательное поле
        'name': _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
        'surname': _surnameController.text.trim().isEmpty ? null : _surnameController.text.trim(),
        'patronymic': _patronymicController.text.trim().isEmpty ? null : _patronymicController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': phone.isEmpty ? null : phone,
        'bornDate': _bornDate?.toIso8601String(),
      };

      await _userService.updateUser(username, updateData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Профиль успешно обновлен'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _isEditing = false;
        });
        _loadProfile();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка сохранения: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _selectedImage = null;
    });
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

  String _getInitials() {
    final surname = _surnameController.text.trim();
    final name = _nameController.text.trim();
    if (surname.isNotEmpty && name.isNotEmpty) {
      return '${surname[0]}${name[0]}'.toUpperCase();
    } else if (surname.isNotEmpty) {
      return surname[0].toUpperCase();
    } else if (name.isNotEmpty) {
      return name[0].toUpperCase();
    }
    return _user?['username']?[0].toUpperCase() ?? 'U';
  }

  String _getDisplayName() {
    final surname = _surnameController.text.trim();
    final name = _nameController.text.trim();
    final patronymic = _patronymicController.text.trim();
    
    if (surname.isNotEmpty || name.isNotEmpty) {
      return '${surname} ${name} ${patronymic}'.trim();
    }
    return _user?['username'] ?? '';
  }

  Widget _buildAvatar() {
    final imageToShow = _selectedImage;
    final serverImageUrl = _imageUrl != null && _imageUrl!.isNotEmpty
        ? 'http://10.178.229.40:8501/images/$_imageUrl'
        : null;
    
    return GestureDetector(
      onTap: _isEditing ? _pickImage : null,
      child: Stack(
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange.withOpacity(0.3),
                  Colors.orange.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(70),
              border: Border.all(
                color: Colors.orange.withOpacity(0.4),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(70),
              child: imageToShow != null
                  ? Image.file(
                      imageToShow,
                      fit: BoxFit.cover,
                      width: 140,
                      height: 140,
                    )
                  : serverImageUrl != null
                      ? Image.network(
                          serverImageUrl,
                          fit: BoxFit.cover,
                          width: 140,
                          height: 140,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.orange.withOpacity(0.2),
                                    Colors.orange.withOpacity(0.1),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _getInitials(),
                                  style: const TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.orange.withOpacity(0.2),
                                Colors.orange.withOpacity(0.1),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _getInitials(),
                              style: const TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ),
            ),
          ),
          if (_isEditing)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade400, Colors.orange.shade600],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Профиль'),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              tooltip: 'Редактировать',
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _cancelEdit,
              tooltip: 'Отмена',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Аватар и основная информация
              Card(
                elevation: 8,
                shadowColor: Colors.orange.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.orange.withOpacity(0.1),
                        Colors.white,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildAvatar(),
                      const SizedBox(height: 20),
                      Text(
                        _getDisplayName(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '@${_user?['username'] ?? ''}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Личные данные
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.person, color: Colors.orange, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Личные данные',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_isEditing) ...[
                TextFormField(
                  controller: _surnameController,
                  decoration: InputDecoration(
                    labelText: 'Фамилия',
                    prefixIcon: const Icon(Icons.person, color: Colors.orange),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.orange, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Имя',
                    prefixIcon: const Icon(Icons.person_outline, color: Colors.orange),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.orange, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _patronymicController,
                  decoration: InputDecoration(
                    labelText: 'Отчество',
                    prefixIcon: const Icon(Icons.person_outline, color: Colors.orange),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.orange, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.orange),
                        const SizedBox(width: 12),
                        Text(
                          _bornDate == null
                              ? 'Дата рождения'
                              : DateFormat('dd.MM.yyyy', 'ru').format(_bornDate!),
                          style: TextStyle(
                            fontSize: 16,
                            color: _bornDate == null ? Colors.grey[600] : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                _buildInfoRow('Фамилия', _surnameController.text.isEmpty ? 'Не указана' : _surnameController.text),
                _buildInfoRow('Имя', _nameController.text.isEmpty ? 'Не указано' : _nameController.text),
                _buildInfoRow('Отчество', _patronymicController.text.isEmpty ? 'Не указано' : _patronymicController.text),
                _buildInfoRow('Дата рождения', _bornDate == null ? 'Не указана' : DateFormat('dd.MM.yyyy', 'ru').format(_bornDate!)),
              ],
              const SizedBox(height: 24),
              
              // Контактная информация
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.contact_mail, color: Colors.orange, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Контактная информация',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_isEditing) ...[
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email, color: Colors.orange),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.orange, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Введите email';
                    }
                    if (!value.contains('@')) {
                      return 'Введите корректный email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Телефон (необязательно)',
                    prefixIcon: const Icon(Icons.phone, color: Colors.orange),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.orange, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ] else ...[
                _buildInfoRow('Email', _emailController.text),
                _buildInfoRow('Телефон', _phoneController.text.isEmpty ? 'Не указан' : _phoneController.text),
              ],
              const SizedBox(height: 32),
              
              // Кнопка сохранения (только в режиме редактирования)
              if (_isEditing)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade400, Colors.orange.shade600],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Сохранить изменения',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
