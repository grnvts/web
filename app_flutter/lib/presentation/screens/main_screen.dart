import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/di/app_container.dart';
import 'brigade_manage_screen.dart';
import 'brigadier_orders_screen.dart';
import 'brigades_list_screen.dart';
import 'create_order_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'my_orders_screen.dart';
import 'orders_list_screen.dart';
import 'profile_screen.dart';
import 'users_list_screen.dart';
import 'notifications_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _authUseCases = AppContainer.authUseCases;
  final _notificationUseCases = AppContainer.notificationUseCases;
  StreamSubscription<Map<String, dynamic>>? _notificationSubscription;
  bool _loading = true;
  bool _isAdmin = false;
  bool _isBrigadier = false;
  bool _isUser = false;
  String? _username;
  int _index = 0;
  List<_NavEntry> _entries = const [];
  String _roleLabel = 'Guest';
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final isAdmin = await _authUseCases.isAdmin();
    final isBrigadier = await _authUseCases.isBrigadier();
    final isUser = await _authUseCases.isUser();
    final username = await _authUseCases.getUsername();
    final roleLabel = await _authUseCases.primaryRoleLabel();
    final unread = await _notificationUseCases
        .getUnreadCount()
        .catchError((_) => 0);

    if (!mounted) return;
    _isAdmin = isAdmin;
    _isBrigadier = isBrigadier;
    _isUser = isUser;
    _username = username;
    _roleLabel = roleLabel;
    _unreadNotifications = unread;

    await _notificationUseCases.connect().catchError((_) {});
    _notificationSubscription = _notificationUseCases.notificationStream.listen(
      _handleRealtimeNotification,
    );

    setState(() {
      _entries = _buildEntries();
      _loading = false;
    });
  }

  List<_NavEntry> _buildEntries() {
    final home = HomeScreen(
      roleKey: _isAdmin
          ? 'admin'
          : _isBrigadier
          ? 'brigadier'
          : 'user',
      roleLabel: _roleLabel,
      username: _username,
      onPrimaryAction: _isUser
          ? _openCreateOrder
          : () {
              setState(() => _index = 1);
            },
    );

    if (_isAdmin) {
      return [
        _NavEntry('Home', Icons.dashboard_rounded, home),
        const _NavEntry('Users', Icons.people_alt_rounded, UsersListScreen()),
        const _NavEntry('Orders', Icons.assignment_rounded, OrdersListScreen()),
        const _NavEntry('Brigades', Icons.groups_rounded, BrigadesListScreen()),
      ];
    }
    if (_isBrigadier) {
      return [
        _NavEntry('Home', Icons.dashboard_rounded, home),
        const _NavEntry(
          'Orders',
          Icons.construction_rounded,
          BrigadierOrdersScreen(),
        ),
        const _NavEntry(
          'Brigade',
          Icons.group_work_rounded,
          BrigadeManageScreen(),
        ),
        const _NavEntry(
          'Profile',
          Icons.account_circle_rounded,
          ProfileScreen(),
        ),
      ];
    }
    return [
      _NavEntry('Home', Icons.home_repair_service_rounded, home),
      const _NavEntry('My orders', Icons.assignment_rounded, MyOrdersScreen()),
      const _NavEntry('Profile', Icons.account_circle_rounded, ProfileScreen()),
    ];
  }

  Future<void> _logout() async {
    await _authUseCases.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _openNotifications() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
    if (!mounted) return;
    final unread = await AppContainer.notificationUseCases
        .getUnreadCount()
        .catchError((_) => 0);
    if (!mounted) return;
    setState(() => _unreadNotifications = unread);
  }

  void _handleRealtimeNotification(Map<String, dynamic> notification) {
    if (!mounted) return;
    if (notification['read'] == true) return;
    setState(() => _unreadNotifications += 1);
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _notificationUseCases.disconnect();
    super.dispose();
  }

  Future<void> _openCreateOrder() async {
    if (!_isUser) return;
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CreateOrderScreen()));
    if (!mounted) return;
    setState(() {
      _entries = _buildEntries();
      _index = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_entries[_index].label),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: _openNotifications,
            icon: Badge.count(
              isLabelVisible: _unreadNotifications > 0,
              count: _unreadNotifications,
              child: const Icon(Icons.notifications_none_rounded),
            ),
          ),
          if (_isUser)
            IconButton(
              tooltip: 'New order',
              onPressed: _openCreateOrder,
              icon: const Icon(Icons.add_circle_outline_rounded),
            ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: _entries[_index].screen,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: _entries
            .map(
              (entry) => NavigationDestination(
                icon: Icon(entry.icon),
                label: entry.label,
              ),
            )
            .toList(growable: false),
      ),
      floatingActionButton: _isUser && _index == 1
          ? FloatingActionButton.extended(
              onPressed: _openCreateOrder,
              icon: const Icon(Icons.add),
              label: const Text('New order'),
            )
          : null,
    );
  }
}

class _NavEntry {
  final String label;
  final IconData icon;
  final Widget screen;

  const _NavEntry(this.label, this.icon, this.screen);
}
