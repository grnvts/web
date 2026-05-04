import '../../domain/repositories/review_repository.dart';
import '../datasources/review_service.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewService _dataSource;

  const ReviewRepositoryImpl(this._dataSource);

  @override
  Future<List<dynamic>> getOrderReviews(int orderId) =>
      _dataSource.getOrderReviews(orderId);

  @override
  Future<List<dynamic>> getRatingCategories() => _dataSource.getRatingCategories();

  @override
  Future<Map<String, dynamic>> createReview(
    int orderId,
    Map<String, dynamic> payload,
  ) =>
      _dataSource.createReview(orderId, payload);
}
