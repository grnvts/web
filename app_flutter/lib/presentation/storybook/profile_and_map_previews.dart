import 'package:flutter/material.dart';

class ProfilePreviewScreen extends StatelessWidget {
  const ProfilePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(70),
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF0F766E).withOpacity(0.18),
                            const Color(0xFF0F766E).withOpacity(0.08),
                          ],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'PI',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F766E),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Petrov Ivan Sergeevich',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '@petrov_ivan',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: const [
                        Chip(label: Text('BRIGADIER')),
                        Chip(label: Text('ACTIVE')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _PreviewSection(
              title: 'Contact info',
              icon: Icons.contact_mail_outlined,
              children: const [
                _PreviewField(label: 'Email', value: 'petrov@example.com'),
                SizedBox(height: 12),
                _PreviewField(label: 'Phone', value: '+375291112233'),
              ],
            ),
            const SizedBox(height: 16),
            _PreviewSection(
              title: 'Personal data',
              icon: Icons.badge_outlined,
              children: const [
                _PreviewField(label: 'Surname', value: 'Petrov'),
                SizedBox(height: 12),
                _PreviewField(label: 'Name', value: 'Ivan'),
                SizedBox(height: 12),
                _PreviewField(label: 'Patronymic', value: 'Sergeevich'),
                SizedBox(height: 12),
                _PreviewField(label: 'Birth date', value: '1991-03-14'),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class MapWidgetPreviewScreen extends StatelessWidget {
  const MapWidgetPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map and route preview')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 980;
            final infoPanel = const _MapInfoPanel();
            final mapPanel = const _MapCanvasPanel();

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Expanded(flex: 3, child: _MapInfoPanel()),
                  SizedBox(width: 20),
                  Expanded(flex: 4, child: _MapCanvasPanel()),
                ],
              );
            }

            return Column(
              children: [
                infoPanel,
                const SizedBox(height: 20),
                Expanded(child: mapPanel),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PreviewSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _PreviewSection({
    required this.title,
    required this.icon,
    required this.children,
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
                    color: const Color(0xFF0F766E).withOpacity(0.12),
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
}

class _PreviewField extends StatelessWidget {
  final String label;
  final String value;

  const _PreviewField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      enabled: false,
      decoration: InputDecoration(labelText: label),
    );
  }
}

class _MapInfoPanel extends StatelessWidget {
  const _MapInfoPanel();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Office location',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 14),
            const _InfoRow(
              icon: Icons.location_on_outlined,
              label: 'Minsk, Leonida Bedy St. 4/1',
            ),
            const _InfoRow(
              icon: Icons.phone_outlined,
              label: '+375 (29) 123-45-67',
            ),
            const _InfoRow(
              icon: Icons.alternate_email_outlined,
              label: 'info@repair-master.by',
            ),
            const SizedBox(height: 18),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Destination address',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F766E).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.route_outlined, color: Color(0xFF0F766E)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Distance: 8.4 km - Time: 19 min',
                      style: TextStyle(color: Color(0xFF0F172A)),
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

class _MapCanvasPanel extends StatelessWidget {
  const _MapCanvasPanel();

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFE0F2FE),
              const Color(0xFFCCFBF1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _MapPreviewPainter(),
              ),
            ),
            Positioned(
              left: 52,
              top: 70,
              child: _MapPin(
                label: 'Office',
                color: const Color(0xFF0F766E),
              ),
            ),
            Positioned(
              right: 84,
              bottom: 92,
              child: _MapPin(
                label: 'Client',
                color: const Color(0xFFEA580C),
              ),
            ),
            Positioned(
              right: 20,
              top: 20,
              child: Column(
                children: [
                  _MapZoomButton(icon: Icons.add),
                  const SizedBox(height: 8),
                  _MapZoomButton(icon: Icons.remove),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final String label;
  final Color color;

  const _MapPin({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 6),
        Icon(Icons.location_on_rounded, color: color, size: 34),
      ],
    );
  }
}

class _MapZoomButton extends StatelessWidget {
  final IconData icon;

  const _MapZoomButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Icon(icon, color: const Color(0xFF0F172A)),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF64748B)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF475569)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPreviewPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final streetPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final routePaint = Paint()
      ..color = const Color(0xFF0F766E)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final street1 = Path()
      ..moveTo(40, size.height * 0.25)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.18,
        size.width * 0.62,
        size.height * 0.38,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.48,
        size.width - 40,
        size.height * 0.42,
      );

    final street2 = Path()
      ..moveTo(60, size.height * 0.68)
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.58,
        size.width * 0.46,
        size.height * 0.74,
      )
      ..quadraticBezierTo(
        size.width * 0.7,
        size.height * 0.92,
        size.width - 60,
        size.height * 0.78,
      );

    final street3 = Path()
      ..moveTo(size.width * 0.22, 40)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.35,
        size.width * 0.24,
        size.height - 40,
      );

    canvas.drawPath(street1, streetPaint);
    canvas.drawPath(street2, streetPaint);
    canvas.drawPath(street3, streetPaint);

    final route = Path()
      ..moveTo(70, size.height * 0.28)
      ..quadraticBezierTo(
        size.width * 0.36,
        size.height * 0.18,
        size.width * 0.6,
        size.height * 0.42,
      )
      ..quadraticBezierTo(
        size.width * 0.73,
        size.height * 0.56,
        size.width - 100,
        size.height * 0.72,
      );

    canvas.drawPath(route, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
