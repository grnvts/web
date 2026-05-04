import '../repositories/order_repository.dart';

class OrderUseCases {
  final OrderRepository _repository;

  const OrderUseCases(this._repository);

  Future<List<dynamic>> getAllOrders() => _repository.getAllOrders();

  Future<List<dynamic>> getMyOrders() => _repository.getMyOrders();

  Future<List<dynamic>> getActiveOrdersForBrigadier() =>
      _repository.getActiveOrdersForBrigadier();

  Future<List<dynamic>> getAssignedMasters(int orderId) =>
      _repository.getAssignedMasters(orderId);

  Future<List<dynamic>> getAllBrigadiers() => _repository.getAllBrigadiers();

  Future<Map<String, dynamic>> getOrderById(int orderId) =>
      _repository.getOrderById(orderId);

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> payload) =>
      _repository.createOrder(payload);

  Future<void> updateOrder(int orderId, Map<String, dynamic> payload) =>
      _repository.updateOrder(orderId, payload);

  Future<void> assignBrigadier(int orderId, String username) =>
      _repository.assignBrigadier(orderId, username);

  Future<void> updateOrderStatus(
    int orderId,
    String status, {
    String? message,
  }) =>
      _repository.updateOrderStatus(orderId, status, message: message);

  Future<void> assignMasters(int orderId, List<int> masterIds) =>
      _repository.assignMasters(orderId, masterIds);

  Future<Map<String, dynamic>> addExpense(int orderId, double amount) =>
      _repository.addExpense(orderId, amount);
}
