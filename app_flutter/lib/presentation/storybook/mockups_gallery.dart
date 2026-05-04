import 'package:flutter/material.dart';

class MockupsGallery extends StatelessWidget {
  const MockupsGallery({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: const [
        _SectionTitle(
          title: 'Order board mockup',
          subtitle: 'Static composition for screenshots in the diploma.',
        ),
        SizedBox(height: 16),
        _OrderBoardMockup(),
        SizedBox(height: 32),
        _SectionTitle(
          title: 'Notification center mockup',
          subtitle: 'Preview of rating, reviews and notification UI blocks.',
        ),
        SizedBox(height: 16),
        _NotificationCenterMockup(),
      ],
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
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

class _OrderBoardMockup extends StatelessWidget {
  const _OrderBoardMockup();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1040;
        final summary = const _SummaryRail();
        final content = const _OrdersGrid();
        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(width: 280, child: _SummaryRail()),
              SizedBox(width: 24),
              Expanded(child: _OrdersGrid()),
            ],
          );
        }
        return Column(
          children: [
            summary,
            const SizedBox(height: 24),
            content,
          ],
        );
      },
    );
  }
}

class _SummaryRail extends StatelessWidget {
  const _SummaryRail();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _MetricCard(
          title: '12',
          subtitle: 'Orders in work',
          icon: Icons.assignment_turned_in_rounded,
          accent: Color(0xFF0F766E),
        ),
        SizedBox(height: 16),
        _MetricCard(
          title: '4.8',
          subtitle: 'Average team rating',
          icon: Icons.star_rounded,
          accent: Color(0xFFEA580C),
        ),
        SizedBox(height: 16),
        _MetricCard(
          title: '9',
          subtitle: 'Unread notifications',
          icon: Icons.notifications_active_rounded,
          accent: Color(0xFF1D4ED8),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;

  const _MetricCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
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
  }
}

class _OrdersGrid extends StatelessWidget {
  const _OrdersGrid();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: const [
        _MockOrderCard(
          orderNo: '#128',
          status: 'IN_PROGRESS',
          client: 'Smirnov A.A.',
          address: 'Minsk, Bedy St. 4/1',
          date: '12.04.2026',
          accent: Color(0xFF0F766E),
        ),
        _MockOrderCard(
          orderNo: '#133',
          status: 'CREATED',
          client: 'Novik E.A.',
          address: 'Minsk, Pobediteley Ave. 17',
          date: '18.04.2026',
          accent: Color(0xFF1D4ED8),
        ),
        _MockOrderCard(
          orderNo: '#141',
          status: 'COMPLETED',
          client: 'Kolesnik V.P.',
          address: 'Minsk, Surganova St. 25',
          date: '03.04.2026',
          accent: Color(0xFF16A34A),
        ),
      ],
    );
  }
}

class _MockOrderCard extends StatelessWidget {
  final String orderNo;
  final String status;
  final String client;
  final String address;
  final String date;
  final Color accent;

  const _MockOrderCard({
    required this.orderNo,
    required this.status,
    required this.client,
    required this.address,
    required this.date,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      orderNo,
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(status),
                    backgroundColor: accent.withOpacity(0.12),
                    labelStyle: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _InfoRow(label: 'Client', value: client),
              const SizedBox(height: 8),
              _InfoRow(label: 'Address', value: address),
              const SizedBox(height: 8),
              _InfoRow(label: 'Start date', value: date),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: status == 'COMPLETED'
                    ? 1
                    : status == 'IN_PROGRESS'
                    ? 0.65
                    : 0.2,
                color: accent,
                backgroundColor: accent.withOpacity(0.12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationCenterMockup extends StatelessWidget {
  const _NotificationCenterMockup();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Notifications and reviews',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 16),
            _NotificationTile(
              title: 'Order #128 moved to IN_PROGRESS',
              body: 'Brigadier Petrov assigned two masters to the repair team.',
              time: '10 minutes ago',
              accent: Color(0xFF0F766E),
            ),
            SizedBox(height: 12),
            _NotificationTile(
              title: 'New review from client',
              body: 'Average score: 4.8. Communication and quality marked high.',
              time: '1 hour ago',
              accent: Color(0xFFEA580C),
            ),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 20),
            Text(
              'Rating summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 14),
            _RatingRow(label: 'Overall', score: 4.8),
            SizedBox(height: 10),
            _RatingRow(label: 'Quality', score: 5.0),
            SizedBox(height: 10),
            _RatingRow(label: 'Communication', score: 4.0),
            SizedBox(height: 10),
            _RatingRow(label: 'Deadline', score: 4.5),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final String title;
  final String body;
  final String time;
  final Color accent;

  const _NotificationTile({
    required this.title,
    required this.body,
    required this.time,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withOpacity(0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.notifications_rounded, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: accent,
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

class _RatingRow extends StatelessWidget {
  final String label;
  final double score;

  const _RatingRow({required this.label, required this.score});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: score / 5,
              minHeight: 10,
              backgroundColor: const Color(0xFFE2E8F0),
              color: const Color(0xFF0F766E),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          score.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
