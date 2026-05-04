import 'package:flutter/material.dart';

import '../../core/di/app_container.dart';

class BrigadeDetailScreen extends StatefulWidget {
  final int brigadeId;

  const BrigadeDetailScreen({super.key, required this.brigadeId});

  @override
  State<BrigadeDetailScreen> createState() => _BrigadeDetailScreenState();
}

class _BrigadeDetailScreenState extends State<BrigadeDetailScreen> {
  final _brigadeUseCases = AppContainer.brigadeUseCases;

  bool _isLoading = true;
  List<dynamic> _masters = <dynamic>[];
  List<dynamic> _allMasters = <dynamic>[];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait<dynamic>(<Future<dynamic>>[
        _brigadeUseCases.getBrigadeMasters(widget.brigadeId),
        _brigadeUseCases.getAllMasters(),
      ]);

      if (!mounted) return;
      setState(() {
        _masters = results[0] as List<dynamic>;
        _allMasters = results[1] as List<dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load brigade: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  String _masterName(dynamic master) {
    final surname = master['surname']?.toString() ?? '';
    final name = master['name']?.toString() ?? '';
    final patronymic = master['patronymic']?.toString() ?? '';
    final username = master['username']?.toString() ?? '';
    final fullName = '$surname $name $patronymic'.trim();
    return fullName.isEmpty
        ? (username.isEmpty ? 'Unknown master' : username)
        : fullName;
  }

  String _masterSubtitle(dynamic master) {
    final parts = <String>[];
    final username = master['username']?.toString() ?? '';
    final email = master['email']?.toString() ?? '';
    final qualification = master['qualification']?.toString() ?? '';
    if (username.isNotEmpty) parts.add('@$username');
    if (email.isNotEmpty) parts.add(email);
    if (qualification.isNotEmpty) parts.add(qualification);
    return parts.isEmpty ? 'No extra data' : parts.join(' | ');
  }

  String _masterInitial(dynamic master) {
    final value = _masterName(master);
    return value.isEmpty ? 'M' : value.substring(0, 1).toUpperCase();
  }

  Future<void> _addMaster(int userId) async {
    try {
      await _brigadeUseCases.addMasterToBrigade(widget.brigadeId, userId);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Master added to brigade')));
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add master: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removeMaster(int userId, String label) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove master from brigade?'),
        content: Text('Master $label will be removed from this brigade.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _brigadeUseCases.removeMasterFromBrigade(widget.brigadeId, userId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Master removed from brigade')),
      );
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove master: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildMasterCard({
    required dynamic master,
    required VoidCallback onPressed,
    required IconData actionIcon,
    required Color actionColor,
    required String actionLabel,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF0F766E).withValues(alpha: 0.12),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFF0F766E).withValues(alpha: 0.12),
          foregroundColor: const Color(0xFF0F766E),
          child: Text(
            _masterInitial(master),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        title: Text(
          _masterName(master),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(_masterSubtitle(master)),
        ),
        trailing: Tooltip(
          message: actionLabel,
          child: IconButton.filledTonal(
            onPressed: onPressed,
            icon: Icon(actionIcon),
            style: IconButton.styleFrom(foregroundColor: actionColor),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F766E).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: const Color(0xFF0F766E)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
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

  @override
  Widget build(BuildContext context) {
    final availableMasters = _allMasters.where((master) {
      final masterId = master['id'];
      return !_masters.any((assigned) => assigned['id'] == masterId);
    }).toList();

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Brigade #${widget.brigadeId}')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Brigade #${widget.brigadeId}')),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    Chip(
                      avatar: const Icon(Icons.groups_2_outlined, size: 18),
                      label: Text('Masters in brigade: ${_masters.length}'),
                    ),
                    Chip(
                      avatar: const Icon(
                        Icons.person_add_alt_1_outlined,
                        size: 18,
                      ),
                      label: Text(
                        'Available to add: ${availableMasters.length}',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Current members',
              subtitle: 'Masters already assigned to this brigade',
              icon: Icons.engineering_outlined,
              children: _masters.isEmpty
                  ? <Widget>[
                      Text(
                        'No masters in this brigade yet.',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ]
                  : _masters
                        .map(
                          (master) => _buildMasterCard(
                            master: master,
                            onPressed: () => _removeMaster(
                              (master['id'] as num).toInt(),
                              _masterName(master),
                            ),
                            actionIcon: Icons.remove_circle_outline,
                            actionColor: Colors.red,
                            actionLabel: 'Remove from brigade',
                          ),
                        )
                        .toList(),
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Available masters',
              subtitle: 'Select a master to add',
              icon: Icons.person_add_alt_1_outlined,
              children: availableMasters.isEmpty
                  ? <Widget>[
                      Text(
                        'No available masters to add.',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ]
                  : availableMasters
                        .map(
                          (master) => _buildMasterCard(
                            master: master,
                            onPressed: () =>
                                _addMaster((master['id'] as num).toInt()),
                            actionIcon: Icons.add_circle_outline,
                            actionColor: Colors.green,
                            actionLabel: 'Add to brigade',
                          ),
                        )
                        .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
