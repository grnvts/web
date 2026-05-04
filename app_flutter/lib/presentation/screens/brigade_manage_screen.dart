import 'package:flutter/material.dart';

import '../../core/di/app_container.dart';

class BrigadeManageScreen extends StatefulWidget {
  const BrigadeManageScreen({super.key});

  @override
  State<BrigadeManageScreen> createState() => _BrigadeManageScreenState();
}

class _BrigadeManageScreenState extends State<BrigadeManageScreen> {
  final _brigadeUseCases = AppContainer.brigadeUseCases;
  final _searchController = TextEditingController();

  bool _isLoading = true;
  List<dynamic> _masters = <dynamic>[];
  List<dynamic> _allMasters = <dynamic>[];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMasters();
    _searchController.addListener(() {
      setState(
        () => _searchQuery = _searchController.text.trim().toLowerCase(),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMasters() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait<dynamic>(<Future<dynamic>>[
        _brigadeUseCases.getMyBrigadeMasters(),
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
    final name = _masterName(master);
    return name.isEmpty ? 'M' : name.substring(0, 1).toUpperCase();
  }

  List<dynamic> get _availableMasters {
    return _allMasters.where((master) {
      final masterId = master['id'];
      final alreadyInBrigade = _masters.any(
        (assigned) => assigned['id'] == masterId,
      );
      if (alreadyInBrigade) return false;
      if (_searchQuery.isEmpty) return true;
      final fullName = _masterName(master).toLowerCase();
      final username = master['username']?.toString().toLowerCase() ?? '';
      return fullName.contains(_searchQuery) || username.contains(_searchQuery);
    }).toList();
  }

  Future<void> _addMaster(int userId) async {
    try {
      await _brigadeUseCases.addMasterToMyBrigade(userId);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Master added to brigade')));
      await _loadMasters();
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
        content: Text('Master $label will be removed from your brigade.'),
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
      await _brigadeUseCases.removeMasterFromMyBrigade(userId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Master removed from brigade')),
      );
      await _loadMasters();
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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final availableMasters = _availableMasters;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadMasters,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'My brigade',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: <Widget>[
                        Chip(
                          avatar: const Icon(Icons.groups_2_outlined, size: 18),
                          label: Text('Masters in team: ${_masters.length}'),
                        ),
                        Chip(
                          avatar: const Icon(
                            Icons.person_search_outlined,
                            size: 18,
                          ),
                          label: Text(
                            'Available to add: ${availableMasters.length}',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Current members',
              subtitle: 'Masters already in your brigade',
              icon: Icons.engineering_outlined,
              children: _masters.isEmpty
                  ? <Widget>[
                      Text(
                        'No masters in your brigade yet.',
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
              subtitle: 'Add a master to your brigade',
              icon: Icons.person_add_alt_1_outlined,
              children: availableMasters.isEmpty
                  ? <Widget>[
                      Text(
                        'No available masters.',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ]
                  : <Widget>[
                      TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: 'Search masters',
                          prefixIcon: Icon(Icons.search_rounded),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...availableMasters.map(
                        (master) => _buildMasterCard(
                          master: master,
                          onPressed: () =>
                              _addMaster((master['id'] as num).toInt()),
                          actionIcon: Icons.add_circle_outline,
                          actionColor: Colors.green,
                          actionLabel: 'Add to brigade',
                        ),
                      ),
                    ],
            ),
          ],
        ),
      ),
    );
  }
}
