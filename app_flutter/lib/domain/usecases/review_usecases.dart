import '../repositories/review_repository.dart';

class ReviewUseCases {
  final ReviewRepository _repository;

  const ReviewUseCases(this._repository);

  Future<List<dynamic>> getOrderReviews(int orderId) =>
      _repository.getOrderReviews(orderId);

  Future<List<dynamic>> getRatingCategories() =>
      _repository.getRatingCategories();

  Future<Map<String, dynamic>> createReview(
    int orderId,
    Map<String, dynamic> payload,
  ) =>
      _repository.createReview(orderId, payload);
}
