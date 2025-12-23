import 'package:flutter/material.dart';
import '../services/brigade_service.dart';

class BrigadeDetailScreen extends StatefulWidget {
  final int brigadeId;

  const BrigadeDetailScreen({super.key, required this.brigadeId});

  @override
  State<BrigadeDetailScreen> createState() => _BrigadeDetailScreenState();
}

class _BrigadeDetailScreenState extends State<BrigadeDetailScreen> {
  final _brigadeService = BrigadeService();
  bool _isLoading = true;
  List<dynamic> _masters = [];
  List<dynamic> _allMasters = [];
  Map<String, dynamic>? _brigade;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final masters = await _brigadeService.getBrigadeMasters(widget.brigadeId);
      final allMasters = await _brigadeService.getAllMasters();
      
      setState(() {
        _masters = masters;
        _allMasters = allMasters;
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

  Future<void> _addMaster(int userId) async {
    try {
      await _brigadeService.addMasterToBrigade(widget.brigadeId, userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Мастер добавлен')),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeMaster(int userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить мастера?'),
        content: const Text('Вы уверены, что хотите удалить этого мастера из бригады?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _brigadeService.removeMasterFromBrigade(widget.brigadeId, userId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Мастер удален')),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _getMasterName(dynamic master) {
    if (master is Map) {
      final name = master['name'] ?? '';
      final surname = master['surname'] ?? '';
      final patronymic = master['patronymic'] ?? '';
      if (name.isNotEmpty || surname.isNotEmpty) {
        return '${surname} ${name} ${patronymic}'.trim();
      }
      return master['username'] ?? 'Неизвестно';
    }
    return 'Неизвестно';
  }

  String _getMasterInitials(dynamic master) {
    final name = _getMasterName(master);
    if (name.isNotEmpty && name != 'Неизвестно') {
      return name[0].toUpperCase();
    }
    return 'M';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Управление бригадой')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final availableMasters = _allMasters.where((master) {
      final masterId = master['id'];
      return !_masters.any((m) => m['id'] == masterId);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Бригада #${widget.brigadeId}'),
      ),
      body: Column(
        children: [
          // Текущие мастера
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Мастера в бригаде (${_masters.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Expanded(
                  child: _masters.isEmpty
                      ? const Center(child: Text('Нет мастеров в бригаде'))
                      : ListView.builder(
                          itemCount: _masters.length,
                          itemBuilder: (context, index) {
                            final master = _masters[index];
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(_getMasterInitials(master)),
                              ),
                              title: Text(_getMasterName(master)),
                              subtitle: Text(master['email'] ?? ''),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeMaster(master['id']),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          const Divider(),
          // Доступные мастера
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Доступные мастера (${availableMasters.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Expanded(
                  child: availableMasters.isEmpty
                      ? const Center(child: Text('Нет доступных мастеров'))
                      : ListView.builder(
                          itemCount: availableMasters.length,
                          itemBuilder: (context, index) {
                            final master = availableMasters[index];
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(_getMasterInitials(master)),
                              ),
                              title: Text(_getMasterName(master)),
                              subtitle: Text(master['email'] ?? ''),
                              trailing: IconButton(
                                icon: const Icon(Icons.add, color: Colors.green),
                                onPressed: () => _addMaster(master['id']),
                              ),
                            );
                          },
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

