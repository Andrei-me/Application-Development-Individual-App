import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/review.dart';
import '../../domain/repositories/reviews_repository.dart';

/// Manages review state (create, edit, delete) for the current user.
class ReviewsProvider extends ChangeNotifier {
  ReviewsProvider(this._reviewsRepository);

  final ReviewsRepository _reviewsRepository;
  final Uuid _uuid = const Uuid();

  List<Review> _reviews = <Review>[];
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentUserId;

  List<Review> get reviews => List.unmodifiable(_reviews);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Loads saved reviews for the given user.
  Future<void> load(String userId) async {
    _currentUserId = userId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reviews = await _reviewsRepository.getReviews(userId);
      _sortReviews();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Review? getReviewForGame(String gameId) {
    for (final review in _reviews) {
      if (review.gameId == gameId) return review;
    }
    return null;
  }

  /// Creates a new review or updates an existing one for the same game.
  Future<void> saveReview({
    required String gameId,
    required int rating,
    required String reviewText,
    String? existingReviewId,
  }) async {
    final userId = _currentUserId;
    if (userId == null) return;

    final now = DateTime.now().toIso8601String();
    final trimmedText = reviewText.trim();

    if (existingReviewId != null) {
      final index = _reviews.indexWhere((r) => r.id == existingReviewId);
      if (index != -1) {
        _reviews[index] = _reviews[index].copyWith(
          rating: rating,
          reviewText: trimmedText,
          date: now,
        );
      }
    } else {
      // If a review for this game already exists, update it instead of duplicating.
      final existingIndex = _reviews.indexWhere((r) => r.gameId == gameId);
      if (existingIndex != -1) {
        _reviews[existingIndex] = _reviews[existingIndex].copyWith(
          rating: rating,
          reviewText: trimmedText,
          date: now,
        );
      } else {
        _reviews.add(
          Review(
            id: _uuid.v4(),
            gameId: gameId,
            userId: userId,
            rating: rating,
            reviewText: trimmedText,
            date: now,
          ),
        );
      }
    }

    _sortReviews();
    await _reviewsRepository.saveReviews(userId, _reviews);
    notifyListeners();
  }

  Future<void> deleteReview(String reviewId) async {
    final userId = _currentUserId;
    if (userId == null) return;

    _reviews.removeWhere((r) => r.id == reviewId);
    await _reviewsRepository.saveReviews(userId, _reviews);
    notifyListeners();
  }

  void _sortReviews() {
    _reviews.sort((a, b) => b.date.compareTo(a.date));
  }
}
