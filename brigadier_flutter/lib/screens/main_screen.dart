import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'orders_list_screen.dart';
import 'brigade_manage_screen.dart';
import 'my_orders_screen.dart';
import 'create_order_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  bool _isBrigadier = false;
  bool _isUser = false;
  bool _isLoading = true;

  List<Widget> _screens = [];
  List<BottomNavigationBarItem> _navItems = [];

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final isBrigadier = await _authService.isBrigadier();
    final isUser = await _authService.isUser();

    setState(() {
      _isBrigadier = isBrigadier;
      _isUser = isUser;

      if (isBrigadier) {
        _screens = [
          const OrdersListScreen(),
          const BrigadeManageScreen(),
        ];
        _navItems = const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Заказы',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_work),
            label: 'Бригада',
          ),
        ];
      } else if (isUser) {
        _screens = [
          const MyOrdersScreen(),
        ];
        // Для пользователя не нужен BottomNavigationBar, так как только один экран
        _navItems = [];
      }

      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выйти?'),
        content: const Text('Вы уверены, что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isBrigadier ? 'Панель бригадира' : 'Мои заказы'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          if (_isUser) ...[
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(),
                  ),
                );
              },
              tooltip: 'Профиль',
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateOrderScreen(),
                  ),
                );
                if (result == true && mounted) {
                  // Обновляем список заказов через пересоздание экрана
                  setState(() {
                    if (_screens.isNotEmpty) {
                      _screens[0] = const MyOrdersScreen();
                    }
                  });
                }
              },
              tooltip: 'Создать заказ',
            ),
          ],
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Выйти',
          ),
        ],
      ),
      body: _screens.isEmpty
          ? const Center(child: Text('Неизвестная роль'))
          : _screens[_selectedIndex],
      bottomNavigationBar: _navItems.length >= 2
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              selectedItemColor: Colors.orange,
              unselectedItemColor: Colors.grey,
              items: _navItems,
            )
          : null,
      floatingActionButton: _isUser && _screens.isNotEmpty
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateOrderScreen(),
                  ),
                );
                if (result == true && mounted) {
                  // Обновляем список заказов через пересоздание экрана
                  setState(() {
                    if (_screens.isNotEmpty) {
                      _screens[0] = const MyOrdersScreen();
                    }
                  });
                }
              },
              backgroundColor: Colors.orange,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

