import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/di/app_container.dart';
import 'order_detail_screen.dart';
import 'user_order_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final String roleKey;
  final String roleLabel;
  final String? username;
  final VoidCallback? onPrimaryAction;

  const HomeScreen({
    super.key,
    required this.roleKey,
    required this.roleLabel,
    required this.username,
    this.onPrimaryAction,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _orderUseCases = AppContainer.orderUseCases;
  final _userUseCases = AppContainer.userUseCases;
  final _brigadeUseCases = AppContainer.brigadeUseCases;
  final _notificationUseCases = AppContainer.notificationUseCases;

  bool _loading = true;
  String? _error;
  List<_DashboardMetric> _metrics = const <_DashboardMetric>[];
  List<dynamic> _recentOrders = const <dynamic>[];
  List<String> _nextSteps = const <String>[];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final unread = await _notificationUseCases
          .getUnreadCount()
          .catchError((_) => 0);

      if (widget.roleKey == 'admin') {
        final results = await Future.wait<dynamic>(<Future<dynamic>>[
          _orderUseCases.getAllOrders(),
          _brigadeUseCases.getAllBrigades(),
          _userUseCases.getUsers(0, 1),
        ]);
        final orders = results[0] as List<dynamic>;
        final brigades = results[1] as List<dynamic>;
        final usersPage = results[2] as Map<String, dynamic>;
        final usersTotal = (usersPage['totalElements'] as num?)?.toInt() ?? 0;

        _applyDashboard(
          metrics: <_DashboardMetric>[
            _DashboardMetric(
              title: 'Orders',
              value: orders.length.toString(),
              subtitle: 'total in the system',
              icon: Icons.assignment_rounded,
              color: const Color(0xFF0F766E),
            ),
            _DashboardMetric(
              title: 'Open work',
              value: _countStatuses(
                orders,
                const <String>{'CREATED', 'IN_PROGRESS'},
              ).toString(),
              subtitle: 'created or in progress',
              icon: Icons.pending_actions_rounded,
              color: const Color(0xFFEA580C),
            ),
            _DashboardMetric(
              title: 'Brigades',
              value: brigades.length.toString(),
              subtitle: 'active execution teams',
              icon: Icons.groups_rounded,
              color: const Color(0xFF1D4ED8),
            ),
            _DashboardMetric(
              title: 'Users',
              value: usersTotal.toString(),
              subtitle: 'registered accounts',
              icon: Icons.people_alt_rounded,
              color: const Color(0xFF0F172A),
            ),
          ],
          recentOrders: _sortRecentOrders(orders).take(5).toList(),
          nextSteps: <String>[
            'Open the orders list and assign brigadiers for new requests.',
            'Review overdue or in-progress work and update statuses.',
            'Check unread notifications: $unread pending.',
          ],
        );
        return;
      }

      if (widget.roleKey == 'brigadier') {
        final results = await Future.wait<dynamic>(<Future<dynamic>>[
          _orderUseCases.getActiveOrdersForBrigadier(),
          _brigadeUseCases.getMyBrigadeMasters(),
        ]);
        final orders = results[0] as List<dynamic>;
        final masters = results[1] as List<dynamic>;

        _applyDashboard(
          metrics: <_DashboardMetric>[
            _DashboardMetric(
              title: 'Active orders',
              value: orders.length.toString(),
              subtitle: 'currently assigned to you',
              icon: Icons.construction_rounded,
              color: const Color(0xFF0F766E),
            ),
            _DashboardMetric(
              title: 'Today',
              value: _countOrdersForToday(orders).toString(),
              subtitle: 'scheduled starts today',
              icon: Icons.today_rounded,
              color: const Color(0xFFEA580C),
            ),
            _DashboardMetric(
              title: 'My masters',
              value: masters.length.toString(),
              subtitle: 'available in brigade',
              icon: Icons.handyman_rounded,
              color: const Color(0xFF1D4ED8),
            ),
            _DashboardMetric(
              title: 'Unread',
              value: unread.toString(),
              subtitle: 'notifications and chat events',
              icon: Icons.notifications_active_rounded,
              color: const Color(0xFF0F172A),
            ),
          ],
          recentOrders: _sortRecentOrders(orders).take(5).toList(),
          nextSteps: <String>[
            'Open active orders and start or complete current work.',
            'Adjust brigade composition before assigning masters to an order.',
            'Respond to client messages and notifications without leaving the app.',
          ],
        );
        return;
      }

      final orders = await _orderUseCases.getMyOrders();
      _applyDashboard(
        metrics: <_DashboardMetric>[
          _DashboardMetric(
            title: 'My orders',
            value: orders.length.toString(),
            subtitle: 'all submitted requests',
            icon: Icons.home_repair_service_rounded,
            color: const Color(0xFF0F766E),
          ),
          _DashboardMetric(
            title: 'In progress',
            value: _countStatuses(
              orders,
              const <String>{'IN_PROGRESS'},
            ).toString(),
            subtitle: 'currently being executed',
            icon: Icons.sync_rounded,
            color: const Color(0xFFEA580C),
          ),
          _DashboardMetric(
            title: 'Completed',
            value: _countStatuses(
              orders,
              const <String>{'COMPLETED', 'APPROVED'},
            ).toString(),
            subtitle: 'ready for confirmation or review',
            icon: Icons.task_alt_rounded,
            color: const Color(0xFF1D4ED8),
          ),
          _DashboardMetric(
            title: 'Unread',
            value: unread.toString(),
            subtitle: 'notifications and messages',
            icon: Icons.notifications_active_rounded,
            color: const Color(0xFF0F172A),
          ),
        ],
        recentOrders: _sortRecentOrders(orders).take(5).toList(),
        nextSteps: <String>[
          'Create a new request if you need another repair.',
          'Track current statuses and open the order details for chat.',
          'Leave reviews after completed work to close the feedback loop.',
        ],
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  void _applyDashboard({
    required List<_DashboardMetric> metrics,
    required List<dynamic> recentOrders,
    required List<String> nextSteps,
  }) {
    if (!mounted) return;
    setState(() {
      _metrics = metrics;
      _recentOrders = recentOrders;
      _nextSteps = nextSteps;
      _loading = false;
      _error = null;
    });
  }

  List<dynamic> _sortRecentOrders(List<dynamic> orders) {
    final copy = List<dynamic>.from(orders);
    copy.sort((a, b) {
      final aDate = _parseOrderDate(a) ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = _parseOrderDate(b) ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    return copy;
  }

  DateTime? _parseOrderDate(dynamic order) {
    final candidates = <String?>[
      order['createdDate']?.toString(),
      order['startDate']?.toString(),
      order['endDate']?.toString(),
    ];
    for (final candidate in candidates) {
      if (candidate == null || candidate.isEmpty) continue;
      try {
        return DateTime.parse(candidate);
      } catch (_) {
        // ignore
      }
    }
    return null;
  }

  int _countStatuses(List<dynamic> orders, Set<String> statuses) {
    return orders.where((dynamic order) {
      final status = order['status']?.toString();
      return status != null && statuses.contains(status);
    }).length;
  }

  int _countOrdersForToday(List<dynamic> orders) {
    final now = DateTime.now();
    return orders.where((dynamic order) {
      final parsed = _parseOrderDate(order);
      return parsed != null &&
          parsed.year == now.year &&
          parsed.month == now.month &&
          parsed.day == now.day;
    }).length;
  }

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) return 'Date not set';
    try {
      final date = DateTime.parse(value);
      return value.length <= 10
          ? DateFormat('dd.MM.yyyy').format(date)
          : DateFormat('dd.MM.yyyy HH:mm').format(date);
    } catch (_) {
      return value;
    }
  }

  String _serviceType(dynamic order) {
    final value = order['serviceType']?.toString();
    if (value == null || value.isEmpty) return 'Not set';
    switch (value.toLowerCase()) {
      case 'electrician':
        return 'Electrician';
      case 'plumbing':
        return 'Plumbing';
      case 'painting':
        return 'Finishing';
      default:
        return value;
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'CREATED':
        return 'Created';
      case 'IN_PROGRESS':
        return 'In progress';
      case 'COMPLETED':
        return 'Completed';
      case 'APPROVED':
        return 'Approved';
      case 'REJECTED':
        return 'Rejected';
      default:
        return status ?? 'Unknown';
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'CREATED':
        return Colors.blue;
      case 'IN_PROGRESS':
        return Colors.orange;
      case 'COMPLETED':
        return Colors.green;
      case 'APPROVED':
        return Colors.teal;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _address(dynamic address) {
    if (address is! Map) return 'Address not set';
    final parts = <String>[
      if ((address['city'] ?? '').toString().isNotEmpty)
        address['city'].toString(),
      if ((address['street'] ?? '').toString().isNotEmpty &&
          (address['buildingNo'] ?? '').toString().isNotEmpty)
        '${address['street']}, bld. ${address['buildingNo']}'
      else if ((address['street'] ?? '').toString().isNotEmpty)
        address['street'].toString(),
      if ((address['apartmentNo'] ?? '').toString().isNotEmpty)
        'apt. ${address['apartmentNo']}',
    ];
    return parts.isEmpty ? 'Address not set' : parts.join(', ');
  }

  String _clientName(dynamic order) {
    final fullName =
        '${order['clientSurname'] ?? ''} ${order['clientName'] ?? ''} ${order['clientPatronymic'] ?? ''}'
            .trim();
    return fullName.isNotEmpty
        ? fullName
        : (order['clientUsername']?.toString() ?? 'Unknown client');
  }

  String _headlineTitle() {
    switch (widget.roleKey) {
      case 'admin':
        return 'Operations dashboard';
      case 'brigadier':
        return 'Execution dashboard';
      default:
        return 'Client dashboard';
    }
  }

  String _headlineSubtitle() {
    final usernamePart =
        widget.username == null ? widget.roleLabel : '${widget.roleLabel} - @${widget.username}';
    switch (widget.roleKey) {
      case 'admin':
        return '$usernamePart. Control users, brigades and order execution from one place.';
      case 'brigadier':
        return '$usernamePart. Focus on active jobs, team composition and client communication.';
      default:
        return '$usernamePart. Track your requests, communicate with the team and leave feedback.';
    }
  }

  Future<void> _openOrder(dynamic order) async {
    final orderId = (order['id'] as num?)?.toInt();
    if (orderId == null) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => widget.roleKey == 'user'
            ? UserOrderDetailScreen(orderId: orderId)
            : OrderDetailScreen(orderId: orderId),
      ),
    );

    if (!mounted) return;
    await _loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _HeroBlock(
            title: _headlineTitle(),
            subtitle: _headlineSubtitle(),
            primaryLabel: widget.roleKey == 'user'
                ? 'Create request'
                : 'Open work area',
            onPrimaryAction: widget.onPrimaryAction,
          ),
          const SizedBox(height: 20),
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Failed to load dashboard',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_error!),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _loadDashboard,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            _SectionTitle(
              title: 'Current state',
              subtitle: 'Live data collected from the working modules of the system.',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _metrics
                  .map((metric) => _MetricCard(metric: metric))
                  .toList(growable: false),
            ),
            const SizedBox(height: 20),
            _SectionTitle(
              title: 'Next actions',
              subtitle: 'What you can do now without switching to unrelated screens.',
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: _nextSteps
                      .map((step) => _StepTile(text: step))
                      .toList(growable: false),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _SectionTitle(
              title: 'Recent orders',
              subtitle: 'Latest operational objects available for your role.',
            ),
            const SizedBox(height: 12),
            if (_recentOrders.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    widget.roleKey == 'user'
                        ? 'No orders yet. Create the first request from this dashboard.'
                        : 'No orders available for this role right now.',
                  ),
                ),
              )
            else
              ..._recentOrders.map(
                (order) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _RecentOrderCard(
                    orderId: order['id']?.toString() ?? '-',
                    statusLabel: _statusLabel(order['status']?.toString()),
                    statusColor: _statusColor(order['status']?.toString()),
                    serviceType: _serviceType(order),
                    address: _address(order['address']),
                    dateText: _formatDate(
                      order['startDate']?.toString() ??
                          order['createdDate']?.toString(),
                    ),
                    ownerText: widget.roleKey == 'user'
                        ? 'Your request'
                        : _clientName(order),
                    onTap: () => _openOrder(order),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _HeroBlock extends StatelessWidget {
  final String title;
  final String subtitle;
  final String primaryLabel;
  final VoidCallback? onPrimaryAction;

  const _HeroBlock({
    required this.title,
    required this.subtitle,
    required this.primaryLabel,
    required this.onPrimaryAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onPrimaryAction,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0F766E),
            ),
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(primaryLabel),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final _DashboardMetric metric;

  const _MetricCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: metric.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(metric.icon, color: metric.color),
              ),
              const SizedBox(height: 14),
              Text(
                metric.value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                metric.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                metric.subtitle,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final String text;

  const _StepTile({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Color(0xFF0F766E),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentOrderCard extends StatelessWidget {
  final String orderId;
  final String statusLabel;
  final Color statusColor;
  final String serviceType;
  final String address;
  final String dateText;
  final String ownerText;
  final VoidCallback onTap;

  const _RecentOrderCard({
    required this.orderId,
    required this.statusLabel,
    required this.statusColor,
    required this.serviceType,
    required this.address,
    required this.dateText,
    required this.ownerText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Order #$orderId',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                serviceType,
                style: const TextStyle(
                  color: Color(0xFF0F766E),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(ownerText),
              const SizedBox(height: 4),
              Text(
                address,
                style: const TextStyle(color: Color(0xFF475569)),
              ),
              const SizedBox(height: 4),
              Text(
                dateText,
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardMetric {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _DashboardMetric({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
