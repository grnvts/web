import 'package:flutter/material.dart';

import '../../core/di/app_container.dart';
import 'brigade_detail_screen.dart';

class BrigadesListScreen extends StatefulWidget {
  const BrigadesListScreen({super.key});

  @override
  State<BrigadesListScreen> createState() => _BrigadesListScreenState();
}

class _BrigadesListScreenState extends State<BrigadesListScreen> {
  final _brigadeUseCases = AppContainer.brigadeUseCases;

  List<dynamic> _brigades = <dynamic>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBrigades();
  }

  Future<void> _loadBrigades() async {
    setState(() => _isLoading = true);
    try {
      final brigades = await _brigadeUseCases.getAllBrigades();
      if (!mounted) return;
      setState(() {
        _brigades = brigades;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load brigades: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _brigadierName(dynamic brigade) {
    final brigadier = brigade['brigadier'];
    if (brigadier is! Map) return 'Not assigned';

    final surname = brigadier['surname']?.toString() ?? '';
    final name = brigadier['name']?.toString() ?? '';
    final patronymic = brigadier['patronymic']?.toString() ?? '';
    final fullName = '$surname $name $patronymic'.trim();
    if (fullName.isNotEmpty) return fullName;
    return brigadier['username']?.toString() ?? 'Unknown brigadier';
  }

  int _crossAxisCount(double width) {
    if (width >= 1320) return 3;
    if (width >= 900) return 2;
    return 1;
  }

  Future<void> _openDetails(dynamic brigade) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BrigadeDetailScreen(brigadeId: brigade['id']),
      ),
    );
    if (!mounted) return;
    _loadBrigades();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_brigades.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.group_work_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No brigades found',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.groups_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 14),
            const Text(
              'Brigades',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadBrigades,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = _crossAxisCount(constraints.maxWidth);
            return GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: columns == 1 ? 1.7 : 1.15,
              ),
              itemCount: _brigades.length,
              itemBuilder: (context, index) {
                final brigade = _brigades[index];
                final masters =
                    brigade['masters'] as List<dynamic>? ?? <dynamic>[];

                return Card(
                  child: InkWell(
                    onTap: () => _openDetails(brigade),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF0F766E,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${brigade['number'] ?? brigade['id']}',
                                  style: const TextStyle(
                                    color: Color(0xFF0F766E),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Color(0xFF94A3B8),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Brigade #${brigade['number'] ?? brigade['id']}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const _SectionLabel('Brigadier'),
                          const SizedBox(height: 4),
                          Text(
                            _brigadierName(brigade),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                          ),
                          const Spacer(),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _SummaryChip(
                                icon: Icons.people_alt_rounded,
                                label: '${masters.length} masters',
                              ),
                              _SummaryChip(
                                icon: Icons.badge_outlined,
                                label: 'ID ${brigade['id']}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F766E).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Open brigade details',
                              style: TextStyle(
                                color: Color(0xFF0F766E),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF64748B),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SummaryChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF475569)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}
