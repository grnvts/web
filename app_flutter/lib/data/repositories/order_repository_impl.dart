import '../../domain/repositories/order_repository.dart';
import '../datasources/order_service.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderService _dataSource;

  const OrderRepositoryImpl(this._dataSource);

  @override
  Future<List<dynamic>> getAllOrders() => _dataSource.getAllOrders();

  @override
  Future<List<dynamic>> getMyOrders() => _dataSource.getMyOrders();

  @override
  Future<List<dynamic>> getActiveOrdersForBrigadier() =>
      _dataSource.getActiveOrdersForBrigadier();

  @override
  Future<List<dynamic>> getAssignedMasters(int orderId) =>
      _dataSource.getAssignedMasters(orderId);

  @override
  Future<List<dynamic>> getAllBrigadiers() => _dataSource.getAllBrigadiers();

  @override
  Future<Map<String, dynamic>> getOrderById(int orderId) =>
      _dataSource.getOrderById(orderId);

  @override
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> payload) =>
      _dataSource.createOrder(payload);

  @override
  Future<void> updateOrder(int orderId, Map<String, dynamic> payload) =>
      _dataSource.updateOrder(orderId, payload);

  @override
  Future<void> assignBrigadier(int orderId, String username) =>
      _dataSource.assignBrigadier(orderId, username);

  @override
  Future<void> updateOrderStatus(
    int orderId,
    String status, {
    String? message,
  }) =>
      _dataSource.updateOrderStatus(orderId, status, message: message);

  @override
  Future<void> assignMasters(int orderId, List<int> masterIds) =>
      _dataSource.assignMasters(orderId, masterIds);

  @override
  Future<Map<String, dynamic>> addExpense(int orderId, double amount) =>
      _dataSource.addExpense(orderId, amount);
}
