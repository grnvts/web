import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/di/app_container.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authUseCases = AppContainer.authUseCases;

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _patronymicController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureRepeatPassword = true;
  DateTime? _bornDate;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _patronymicController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final initialDate =
        _bornDate ?? DateTime(now.year - 25, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime(now.year - 18, 12, 31),
      locale: const Locale('ru', 'RU'),
    );

    if (picked != null) {
      setState(() => _bornDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_bornDate == null) {
      _showMessage('Select birth date', isError: true);
      return;
    }
    if (_passwordController.text != _repeatPasswordController.text) {
      _showMessage('Passwords do not match', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authUseCases.signup({
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'name': _nullable(_nameController.text),
        'surname': _nullable(_surnameController.text),
        'patronymic': _nullable(_patronymicController.text),
        'phone': _normalizePhone(_phoneController.text),
        'bornDate': DateFormat('yyyy-MM-dd').format(_bornDate!),
      });

      if (!mounted) return;
      _showMessage('Registration completed. You can sign in now.');
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString().replaceAll('Exception: ', ''), isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Colors.red.shade700
            : const Color(0xFF0F766E),
      ),
    );
  }

  String? _nullable(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  String? _normalizePhone(String value) {
    final digits = value.replaceAll(RegExp(r'[^\d+]'), '');
    return digits.isEmpty ? null : digits;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFF1C1917),
              Color(0xFF9A3412),
              Color(0xFFF97316),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Card(
                  elevation: 18,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Wrap(
                            spacing: 24,
                            runSpacing: 20,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFF97316,
                                  ).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: const Icon(
                                  Icons.person_add_alt_1_rounded,
                                  size: 44,
                                  color: Color(0xFFEA580C),
                                ),
                              ),
                              SizedBox(
                                width: 520,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Create account',
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF0F172A),
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'After registration the user can create service requests, track progress and work with personal data in a single application.',
                                      style: TextStyle(
                                        fontSize: 15,
                                        height: 1.5,
                                        color: Color(0xFF475569),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          const _SectionTitle(
                            icon: Icons.badge_outlined,
                            title: 'Credentials',
                            subtitle: 'Required fields for a new account.',
                          ),
                          const SizedBox(height: 16),
                          _TwoColumnWrap(
                            children: [
                              TextFormField(
                                controller: _usernameController,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Username',
                                  prefixIcon: Icon(
                                    Icons.person_outline_rounded,
                                  ),
                                ),
                                validator: (value) {
                                  final normalized = value?.trim() ?? '';
                                  if (normalized.isEmpty)
                                    return 'Enter username';
                                  if (normalized.length < 3)
                                    return 'At least 3 characters';
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(
                                    Icons.alternate_email_rounded,
                                  ),
                                ),
                                validator: (value) {
                                  final normalized = value?.trim() ?? '';
                                  if (normalized.isEmpty) return 'Enter email';
                                  if (!normalized.contains('@'))
                                    return 'Invalid email';
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Enter password';
                                  if (value.length < 6)
                                    return 'At least 6 characters';
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: _repeatPasswordController,
                                obscureText: _obscureRepeatPassword,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  labelText: 'Repeat password',
                                  prefixIcon: const Icon(
                                    Icons.lock_reset_rounded,
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(
                                      () => _obscureRepeatPassword =
                                          !_obscureRepeatPassword,
                                    ),
                                    icon: Icon(
                                      _obscureRepeatPassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Repeat password';
                                  return null;
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          const _SectionTitle(
                            icon: Icons.assignment_ind_outlined,
                            title: 'Profile',
                            subtitle: 'Personal and contact information.',
                          ),
                          const SizedBox(height: 16),
                          _TwoColumnWrap(
                            children: [
                              TextFormField(
                                controller: _surnameController,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Surname',
                                  prefixIcon: Icon(Icons.badge_outlined),
                                ),
                              ),
                              TextFormField(
                                controller: _nameController,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Name',
                                  prefixIcon: Icon(Icons.person_2_outlined),
                                ),
                              ),
                              TextFormField(
                                controller: _patronymicController,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Patronymic',
                                  prefixIcon: Icon(
                                    Icons.person_outline_rounded,
                                  ),
                                ),
                              ),
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Phone',
                                  prefixIcon: Icon(Icons.phone_outlined),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: _selectDate,
                            borderRadius: BorderRadius.circular(14),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Birth date',
                                prefixIcon: Icon(Icons.calendar_month_rounded),
                              ),
                              child: Text(
                                _bornDate == null
                                    ? 'Select date'
                                    : DateFormat(
                                        'dd.MM.yyyy',
                                      ).format(_bornDate!),
                                style: TextStyle(
                                  color: _bornDate == null
                                      ? const Color(0xFF64748B)
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          FilledButton.icon(
                            onPressed: _isLoading ? null : _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFEA580C),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                            ),
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.check_circle_outline_rounded,
                                  ),
                            label: Text(
                              _isLoading ? 'Creating account...' : 'Sign up',
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (_) => const LoginScreen(),
                                      ),
                                    );
                                  },
                            icon: const Icon(Icons.arrow_back_rounded),
                            label: const Text('Back to sign in'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFEA580C).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFFEA580C)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TwoColumnWrap extends StatelessWidget {
  final List<Widget> children;

  const _TwoColumnWrap({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 640;
        final itemWidth = wide
            ? (constraints.maxWidth - 16) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: children
              .map((child) => SizedBox(width: itemWidth, child: child))
              .toList(growable: false),
        );
      },
    );
  }
}
