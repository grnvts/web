import 'package:flutter/material.dart';
import '../services/brigade_service.dart';

class BrigadeManageScreen extends StatefulWidget {
  const BrigadeManageScreen({super.key});

  @override
  State<BrigadeManageScreen> createState() => _BrigadeManageScreenState();
}

class _BrigadeManageScreenState extends State<BrigadeManageScreen> {
  final _brigadeService = BrigadeService();
  bool _isLoading = true;
  List<dynamic> _masters = [];
  List<dynamic> _allMasters = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMasters();
  }

  Future<void> _loadMasters() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final [masters, allMasters] = await Future.wait([
        _brigadeService.getMyBrigadeMasters(),
        _brigadeService.getAllMasters(),
      ]);

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
      await _brigadeService.addMasterToMyBrigade(userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Мастер добавлен в бригаду'),
            backgroundColor: Colors.green,
          ),
        );
        _loadMasters();
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
    try {
      await _brigadeService.removeMasterFromMyBrigade(userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Мастер удален из бригады'),
            backgroundColor: Colors.green,
          ),
        );
        _loadMasters();
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

  List<dynamic> get _filteredAvailableMasters {
    return _allMasters
        .where((m) => !_masters.any((u) => u['id'] == m['id']))
        .where((m) {
          final searchLower = _searchQuery.toLowerCase();
          final fullName = '${m['name'] ?? ''} ${m['surname'] ?? ''}'.toLowerCase();
          final username = (m['username'] ?? '').toLowerCase();
          return fullName.contains(searchLower) || username.contains(searchLower);
        })
        .toList();
  }

  String _getMasterName(dynamic master) {
    final name = master['name'] ?? '';
    final surname = master['surname'] ?? '';
    final patronymic = master['patronymic'] ?? '';
    if (name.isNotEmpty || surname.isNotEmpty) {
      return '${surname} ${name} ${patronymic}'.trim();
    }
    return master['username'] ?? 'Неизвестно';
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
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Мастера в бригаде
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Мастера в бригаде',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const Divider(),
                          if (_masters.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('В бригаде пока нет мастеров'),
                            )
                          else
                            ..._masters.map((master) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.orange.withOpacity(0.2),
                                    child: Text(
                                      _getMasterInitials(master),
                                      style: const TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(_getMasterName(master)),
                                  subtitle: Text(master['email'] ?? ''),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeMaster(master['id']),
                                  ),
                                ),
                              );
                            }).toList(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Доступные мастера
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Доступные мастера',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const Divider(),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Поиск',
                              hintText: 'Поиск по ФИО или логину...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          if (_filteredAvailableMasters.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('Мастера не найдены'),
                            )
                          else
                            ..._filteredAvailableMasters.map((master) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.grey.withOpacity(0.2),
                                    child: Text(
                                      _getMasterInitials(master),
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(_getMasterName(master)),
                                  subtitle: Text(master['email'] ?? ''),
                                  trailing: ElevatedButton.icon(
                                    onPressed: () => _addMaster(master['id']),
                                    icon: const Icon(Icons.add, size: 18),
                                    label: const Text('Добавить'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

