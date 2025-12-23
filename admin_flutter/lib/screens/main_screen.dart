import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'users_list_screen.dart';
import 'orders_list_screen.dart';
import 'brigades_list_screen.dart';
import 'login_screen.dart';
import 'brigadier_orders_screen.dart';
import 'brigadier_brigade_manage_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  bool _isAdmin = false;
  bool _isBrigadier = false;
  bool _isLoading = true;

  List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final isAdmin = await _authService.isAdmin();
    final isBrigadier = await _authService.isBrigadier();
    
    setState(() {
      _isAdmin = isAdmin;
      _isBrigadier = isBrigadier;
      
      if (isAdmin) {
        _screens = [
          const UsersListScreen(),
          const OrdersListScreen(),
          const BrigadesListScreen(),
        ];
      } else if (isBrigadier) {
        // Для бригадира показываем только заказы и управление бригадой
        _screens = [
          const BrigadierOrdersScreen(),
          const BrigadierBrigadeManageScreen(),
        ];
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
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.dashboard_customize_rounded,
                size: 22,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              _isAdmin ? 'Система управления' : 'Панель бригадира',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: _logout,
              tooltip: 'Выйти',
              style: IconButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.1),
                foregroundColor: Colors.red,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _screens.isEmpty
                ? const Center(child: Text('Нет доступных экранов'))
                : _screens[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: _isAdmin
              ? const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.people_outline),
                    activeIcon: Icon(Icons.people),
                    label: 'Пользователи',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.assignment_outlined),
                    activeIcon: Icon(Icons.assignment),
                    label: 'Заказы',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.group_work_outlined),
                    activeIcon: Icon(Icons.group_work),
                    label: 'Бригады',
                  ),
                ]
              : const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.assignment_outlined),
                    activeIcon: Icon(Icons.assignment),
                    label: 'Заказы',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.group_work_outlined),
                    activeIcon: Icon(Icons.group_work),
                    label: 'Бригада',
                  ),
                ],
        ),
      ),
    );
  }
}

