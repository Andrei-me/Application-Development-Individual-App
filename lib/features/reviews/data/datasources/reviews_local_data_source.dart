import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/review_model.dart';

/// Handles local persistence for user reviews using SharedPreferences.
/// No database or paid API is used.
class ReviewsLocalDataSource {
  ReviewsLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const String _reviewsKeyPrefix = 'user_reviews_';

  Future<List<ReviewModel>> getReviews(String userId) async {
    final raw = _prefs.getString('$_reviewsKeyPrefix$userId');
    if (raw == null || raw.isEmpty) {
      return <ReviewModel>[];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => ReviewModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveReviews(String userId, List<ReviewModel> reviews) async {
    final encoded = jsonEncode(reviews.map((r) => r.toJson()).toList());
    await _prefs.setString('$_reviewsKeyPrefix$userId', encoded);
  }
}
