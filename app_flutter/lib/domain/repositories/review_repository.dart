abstract class ReviewRepository {
  Future<List<dynamic>> getOrderReviews(int orderId);

  Future<List<dynamic>> getRatingCategories();

  Future<Map<String, dynamic>> createReview(
    int orderId,
    Map<String, dynamic> payload,
  );
}
