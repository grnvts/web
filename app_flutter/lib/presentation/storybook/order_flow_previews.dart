import 'package:flutter/material.dart';

import '../utils/order_view_utils.dart';

class AdminOrdersPreviewScreen extends StatelessWidget {
  const AdminOrdersPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const orders = <Map<String, dynamic>>[
      {
        'id': 1042,
        'status': 'IN_PROGRESS',
        'client': 'Ivanov Petr',
        'brigadier': 'Petrov Ivan',
        'address': 'Minsk, Pobediteley Ave., bld. 87, apt. 54',
        'date': '2026-05-04T09:30:00',
        'serviceType': 'electrician',
      },
      {
        'id': 1038,
        'status': 'CREATED',
        'client': 'Sidorova Anna',
        'brigadier': 'Not assigned',
        'address': 'Minsk, Nemiga St., bld. 12',
        'date': '2026-05-05T12:00:00',
        'serviceType': 'plumbing',
      },
      {
        'id': 1029,
        'status': 'COMPLETED',
        'client': 'Kozlov Denis',
        'brigadier': 'Nikolaev Oleg',
        'address': 'Minsk, Kalinovskogo St., bld. 41, apt. 8',
        'date': '2026-05-03T16:45:00',
        'serviceType': 'painting',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.12)),
              ),
            ),
            child: Column(
              children: [
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Search',
                    hintText: 'Order id, client, brigadier, address',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: '',
                        decoration: const InputDecoration(
                          labelText: 'Status filter',
                        ),
                        items: const [
                          DropdownMenuItem(value: '', child: Text('All')),
                          DropdownMenuItem(
                            value: 'CREATED',
                            child: Text('Created'),
                          ),
                          DropdownMenuItem(
                            value: 'IN_PROGRESS',
                            child: Text('In progress'),
                          ),
                          DropdownMenuItem(
                            value: 'COMPLETED',
                            child: Text('Completed'),
                          ),
                        ],
                        onChanged: null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.outlined(
                      onPressed: () {},
                      icon: const Icon(Icons.arrow_downward_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final status = order['status']?.toString();
                final statusColor = orderStatusColor(status);
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: statusColor.withValues(alpha: 0.12),
                              foregroundColor: statusColor,
                              child: Text(
                                '#${order['id']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Order #${order['id']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 17,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    order['address'].toString(),
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Chip(
                              backgroundColor: statusColor.withValues(alpha: 0.12),
                              side: BorderSide(
                                color: statusColor.withValues(alpha: 0.18),
                              ),
                              label: Text(
                                orderStatusLabel(status),
                                style: TextStyle(color: statusColor),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _PreviewMetaChip(
                              icon: Icons.person_outline_rounded,
                              label: order['client'].toString(),
                            ),
                            _PreviewMetaChip(
                              icon: Icons.engineering_outlined,
                              label: order['brigadier'].toString(),
                            ),
                            _PreviewMetaChip(
                              icon: Icons.build_outlined,
                              label: orderServiceTypeLabel(
                                order['serviceType']?.toString(),
                              ),
                            ),
                            _PreviewMetaChip(
                              icon: Icons.calendar_today_outlined,
                              label: formatOrderDate(order['date']?.toString()),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AdminOrderDetailPreviewScreen extends StatelessWidget {
  const AdminOrderDetailPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const status = 'IN_PROGRESS';
    final color = orderStatusColor(status);

    return Scaffold(
      appBar: AppBar(title: const Text('Order #1042')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.assignment_turned_in_outlined,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order status',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Created: ${formatOrderDate('2026-05-02T10:20:00')}',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          orderStatusLabel(status),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: const [
                      Chip(
                        avatar: Icon(Icons.build_outlined, size: 18),
                        label: Text('Electrician'),
                      ),
                      Chip(
                        avatar: Icon(Icons.calendar_today_outlined, size: 18),
                        label: Text('Start: 04.05.2026 09:30'),
                      ),
                      Chip(
                        avatar: Icon(Icons.payments_outlined, size: 18),
                        label: Text('Price: 420 BYN'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _PreviewSection(
            title: 'Actions',
            icon: Icons.bolt_outlined,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: null,
                  icon: Icon(Icons.person_add_alt_1_outlined),
                  label: Text('Assign brigadier'),
                ),
                OutlinedButton.icon(
                  onPressed: null,
                  icon: Icon(Icons.groups_2_outlined),
                  label: Text('Assign masters'),
                ),
                OutlinedButton.icon(
                  onPressed: null,
                  icon: Icon(Icons.sync_alt_rounded),
                  label: Text('Change status'),
                ),
                OutlinedButton.icon(
                  onPressed: null,
                  icon: Icon(Icons.receipt_long_outlined),
                  label: Text('Add expense'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _PreviewSection(
            title: 'Main info',
            icon: Icons.info_outline,
            child: Column(
              children: [
                _PreviewInfoTile(label: 'Order id', value: '1042'),
                _PreviewInfoTile(
                  label: 'Work details',
                  value: 'Replace electrical wiring in kitchen and hallway.',
                ),
                _PreviewInfoTile(
                  label: 'Address',
                  value: 'Minsk, Pobediteley Ave., bld. 87, apt. 54',
                  icon: Icons.location_on_outlined,
                ),
                _PreviewInfoTile(label: 'Start date', value: '04.05.2026 09:30'),
                _PreviewInfoTile(label: 'End date', value: '06.05.2026 18:00'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _PreviewSection(
            title: 'Client and brigade',
            icon: Icons.groups_outlined,
            child: Column(
              children: [
                _PreviewInfoTile(
                  label: 'Client',
                  value: 'Ivanov Petr Andreevich',
                  icon: Icons.person_outline,
                ),
                _PreviewInfoTile(
                  label: 'Brigadier',
                  value: 'Petrov Ivan Sergeevich',
                  icon: Icons.engineering_outlined,
                ),
                _PreviewInfoTile(label: 'Brigade number', value: '7'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UserOrderDetailPreviewScreen extends StatelessWidget {
  const UserOrderDetailPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const status = 'COMPLETED';
    final color = orderStatusColor(status);

    return Scaffold(
      appBar: AppBar(title: const Text('Order #1042')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.assignment_turned_in_outlined,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order status',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Created: ${formatOrderDate('2026-05-02T10:20:00')}',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      orderStatusLabel(status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _PreviewSection(
            title: 'Actions',
            icon: Icons.bolt_outlined,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: null,
                  icon: Icon(Icons.thumb_up_alt_outlined),
                  label: Text('Approve work'),
                ),
                OutlinedButton.icon(
                  onPressed: null,
                  icon: Icon(Icons.thumb_down_alt_outlined),
                  label: Text('Reject work'),
                ),
                FilledButton.icon(
                  onPressed: null,
                  icon: Icon(Icons.rate_review_outlined),
                  label: Text('Leave review'),
                ),
                OutlinedButton.icon(
                  onPressed: null,
                  icon: Icon(Icons.picture_as_pdf_outlined),
                  label: Text('Export PDF'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _PreviewSection(
            title: 'Order communication',
            icon: Icons.chat_bubble_outline_rounded,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: null,
                  icon: Icon(Icons.support_agent_rounded),
                  label: Text('Admin'),
                ),
                OutlinedButton.icon(
                  onPressed: null,
                  icon: Icon(Icons.engineering_outlined),
                  label: Text('Brigadier'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _PreviewSection(
            title: 'Reviews',
            icon: Icons.star_outline_rounded,
            child: Column(
              children: [
                _ReviewPreviewCard(
                  employee: 'Petrov Ivan Sergeevich',
                  role: 'Brigadier',
                  average: '4.8',
                  title: 'Work completed on time',
                  comment:
                      'Clear communication, neat work and no delays during the visit.',
                ),
                SizedBox(height: 12),
                _ReviewPreviewCard(
                  employee: 'Karpov Alexey',
                  role: 'Master',
                  average: '5.0',
                  title: 'Excellent specialist',
                  comment:
                      'Explained every step and solved the issue in one visit.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationsPreviewScreen extends StatelessWidget {
  const NotificationsPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const items = <Map<String, dynamic>>[
      {
        'title': 'New message from brigadier',
        'message': 'Petrov Ivan sent an update about wiring replacement.',
        'type': 'CHAT_MESSAGE',
        'meta': 'Chat • Order #1042 • 04.05.2026 13:15',
        'read': false,
      },
      {
        'title': 'Order moved to completed',
        'message': 'Order #1042 is ready for client approval.',
        'type': 'ORDER_STATUS',
        'meta': 'Status update • Order #1042 • 04.05.2026 12:48',
        'read': false,
      },
      {
        'title': 'Expense added',
        'message': 'Additional materials were added to order #1038.',
        'type': 'SYSTEM',
        'meta': 'System • Order #1038 • 03.05.2026 19:20',
        'read': true,
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          final accent = _notificationAccent(item['type'].toString());
          final isRead = item['read'] == true;
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isRead
                          ? Icons.notifications_none_rounded
                          : Icons.notifications_active_rounded,
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item['title'].toString(),
                                style: TextStyle(
                                  fontWeight:
                                      isRead ? FontWeight.w600 : FontWeight.w800,
                                ),
                              ),
                            ),
                            if (!isRead)
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['message'].toString(),
                          style: const TextStyle(color: Color(0xFF475569)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['meta'].toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ChatPreviewScreen extends StatelessWidget {
  const ChatPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const messages = <Map<String, dynamic>>[
      {
        'author': 'other',
        'name': 'Petrov Ivan',
        'time': '12:04',
        'text': 'We arrived on site and started dismantling the old wiring.',
      },
      {
        'author': 'me',
        'name': 'You',
        'time': '12:06',
        'text': 'Understood. Please send an update if materials are needed.',
      },
      {
        'author': 'other',
        'name': 'Petrov Ivan',
        'time': '12:11',
        'text': 'Need one extra socket frame. I will add it as expense.',
      },
      {
        'author': 'me',
        'name': 'You',
        'time': '12:14',
        'text': 'Approved.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chat with brigadier'),
            SizedBox(height: 2),
            Text(
              'Order #1042',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: false,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final item = messages[index];
                final isMine = item['author'] == 'me';
                return Align(
                  alignment:
                      isMine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 420),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isMine
                          ? const Color(0xFF0F766E)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'].toString(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isMine ? Colors.white70 : const Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['text'].toString(),
                          style: TextStyle(
                            color: isMine ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            item['time'].toString(),
                            style: TextStyle(
                              fontSize: 11,
                              color:
                                  isMine ? Colors.white70 : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.withValues(alpha: 0.12)),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Write a message...',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color _notificationAccent(String code) {
  switch (code) {
    case 'CHAT_MESSAGE':
      return Colors.blue;
    case 'ORDER_STATUS':
      return Colors.orange;
    case 'SYSTEM':
      return Colors.purple;
    default:
      return const Color(0xFF0F766E);
  }
}

class _PreviewSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _PreviewSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
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
            child,
          ],
        ),
      ),
    );
  }
}

class _PreviewInfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const _PreviewInfoTile({
    required this.label,
    required this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: Colors.grey.shade700),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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

class _PreviewMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PreviewMetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
    );
  }
}

class _ReviewPreviewCard extends StatelessWidget {
  final String employee;
  final String role;
  final String average;
  final String title;
  final String comment;

  const _ReviewPreviewCard({
    required this.employee,
    required this.role,
    required this.average,
    required this.title,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$employee • $role',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                'Rating: $average',
                style: const TextStyle(
                  color: Color(0xFF0F766E),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(comment),
        ],
      ),
    );
  }
}
