import '../../domain/entities/review.dart';

/// Data model for persisting reviews in local storage.
class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.gameId,
    required super.userId,
    required super.rating,
    required super.reviewText,
    required super.date,
  });

  factory ReviewModel.fromEntity(Review review) {
    return ReviewModel(
      id: review.id,
      gameId: review.gameId,
      userId: review.userId,
      rating: review.rating,
      reviewText: review.reviewText,
      date: review.date,
    );
  }

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      gameId: json['gameId'] as String,
      userId: json['userId'] as String,
      rating: json['rating'] as int,
      reviewText: json['reviewText'] as String,
      date: json['date'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gameId': gameId,
      'userId': userId,
      'rating': rating,
      'reviewText': reviewText,
      'date': date,
    };
  }
}
