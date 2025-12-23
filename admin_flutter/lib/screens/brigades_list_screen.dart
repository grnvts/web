import 'package:flutter/material.dart';
import '../services/brigade_service.dart';
import 'brigade_detail_screen.dart';

class BrigadesListScreen extends StatefulWidget {
  const BrigadesListScreen({super.key});

  @override
  State<BrigadesListScreen> createState() => _BrigadesListScreenState();
}

class _BrigadesListScreenState extends State<BrigadesListScreen> {
  final _brigadeService = BrigadeService();
  List<dynamic> _brigades = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBrigades();
  }

  Future<void> _loadBrigades() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final brigades = await _brigadeService.getAllBrigades();
      setState(() {
        _brigades = brigades;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getBrigadierName(dynamic brigade) {
    final brigadier = brigade['brigadier'];
    if (brigadier == null) return 'Не назначен';
    
    if (brigadier is Map) {
      final name = brigadier['name'] ?? '';
      final surname = brigadier['surname'] ?? '';
      final patronymic = brigadier['patronymic'] ?? '';
      if (name.isNotEmpty || surname.isNotEmpty) {
        return '${surname} ${name} ${patronymic}'.trim();
      }
      return brigadier['username'] ?? 'Неизвестно';
    }
    
    return 'Неизвестно';
  }

  Widget _buildGridInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
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
              ),
              child: const Icon(Icons.group_work_rounded, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 14),
            const Text(
              'Управление бригадами',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _brigades.isEmpty
              ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_work_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Бригады не найдены',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            )
              : RefreshIndicator(
                  onRefresh: _loadBrigades,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1400),
                      child: GridView.builder(
                        padding: const EdgeInsets.all(20),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.9,
                        ),
                        itemCount: _brigades.length,
                        itemBuilder: (context, index) {
                          final brigade = _brigades[index];
                          final masters = brigade['masters'] as List<dynamic>? ?? [];
                          
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.2),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BrigadeDetailScreen(
                                        brigadeId: brigade['id'],
                                      ),
                                    ),
                                  ).then((_) => _loadBrigades());
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.orange.withOpacity(0.2),
                                                  Colors.deepOrange.withOpacity(0.1),
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(
                                                color: Colors.orange.withOpacity(0.3),
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${brigade['number'] ?? brigade['id']}',
                                                style: const TextStyle(
                                                  color: Colors.orange,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Бригада #${brigade['number'] ?? brigade['id']}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _buildGridInfoRow(Icons.person_outline, 'Бригадир', _getBrigadierName(brigade)),
                                            const SizedBox(height: 8),
                                            _buildGridInfoRow(Icons.people_outline, 'Мастеров', '${masters.length}'),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Подробнее',
                                              style: TextStyle(
                                                color: Colors.orange,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 14,
                                              color: Colors.orange,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
    );
  }
}

