abstract class OrderRepository {
  Future<List<dynamic>> getAllOrders();

  Future<List<dynamic>> getMyOrders();

  Future<List<dynamic>> getActiveOrdersForBrigadier();

  Future<List<dynamic>> getAssignedMasters(int orderId);

  Future<List<dynamic>> getAllBrigadiers();

  Future<Map<String, dynamic>> getOrderById(int orderId);

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> payload);

  Future<void> updateOrder(int orderId, Map<String, dynamic> payload);

  Future<void> assignBrigadier(int orderId, String username);

  Future<void> updateOrderStatus(
    int orderId,
    String status, {
    String? message,
  });

  Future<void> assignMasters(int orderId, List<int> masterIds);

  Future<Map<String, dynamic>> addExpense(int orderId, double amount);
}
