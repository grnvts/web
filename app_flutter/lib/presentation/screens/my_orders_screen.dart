import 'package:flutter/material.dart';

import '../../core/di/app_container.dart';
import '../utils/order_view_utils.dart';
import 'user_order_detail_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final _orderUseCases = AppContainer.orderUseCases;

  bool _isLoading = true;
  List<dynamic> _orders = <dynamic>[];

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await _orderUseCases.getMyOrders();
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to load orders: $e');
      setState(() => _isLoading = false);
    }
  }

  Widget _infoRow(IconData icon, String value) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 16, color: Colors.grey.shade700),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.grey.shade800),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.assignment_outlined,
                    size: 72,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No orders yet',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first request from the home screen.',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadOrders,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  final status = order['status']?.toString();
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserOrderDetailScreen(
                              orderId: (order['id'] as num).toInt(),
                            ),
                          ),
                        );
                        if (mounted) {
                          await _loadOrders();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: orderStatusColor(
                                      status,
                                    ).withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '#${order['id']}',
                                      style: TextStyle(
                                        color: orderStatusColor(status),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Order #${order['id']}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: <Widget>[
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: orderStatusColor(
                                                status,
                                              ).withValues(alpha: 0.14),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              orderStatusLabel(status),
                                              style: TextStyle(
                                                color: orderStatusColor(status),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          Chip(
                                            label: Text(
                                              orderServiceTypeLabel(
                                                order['serviceType']
                                                    ?.toString(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _infoRow(
                              Icons.location_on_outlined,
                              formatOrderAddress(order['address']),
                            ),
                            const SizedBox(height: 8),
                            _infoRow(
                              Icons.calendar_today_outlined,
                              status == 'IN_PROGRESS'
                                  ? 'Work in progress'
                                  : formatOrderDate(
                                      order['startDate']?.toString(),
                                    ),
                            ),
                            if ((order['orderDetails']?.toString().isNotEmpty ??
                                false)) ...<Widget>[
                              const SizedBox(height: 8),
                              _infoRow(
                                Icons.notes_outlined,
                                order['orderDetails'].toString(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
