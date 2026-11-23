import '../../domain/entities/review.dart';
import '../../domain/repositories/reviews_repository.dart';
import '../datasources/reviews_local_data_source.dart';
import '../models/review_model.dart';

/// Data-layer implementation of [ReviewsRepository].
class ReviewsRepositoryImpl implements ReviewsRepository {
  ReviewsRepositoryImpl(this._localDataSource);

  final ReviewsLocalDataSource _localDataSource;

  @override
  Future<List<Review>> getReviews(String userId) async {
    final models = await _localDataSource.getReviews(userId);
    return models;
  }

  @override
  Future<void> saveReviews(String userId, List<Review> reviews) async {
    final models = reviews.map(ReviewModel.fromEntity).toList();
    await _localDataSource.saveReviews(userId, models);
  }
}
