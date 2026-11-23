import '../entities/review.dart';

/// Contract for storing and managing user reviews locally.
abstract class ReviewsRepository {
  Future<List<Review>> getReviews(String userId);

  Future<void> saveReviews(String userId, List<Review> reviews);
}
