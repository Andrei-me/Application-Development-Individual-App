/// Represents a user's review for a game.
class Review {
  const Review({
    required this.id,
    required this.gameId,
    required this.userId,
    required this.rating,
    required this.reviewText,
    required this.date,
  });

  final String id;
  final String gameId;
  final String userId;

  /// User rating on a 1-10 scale.
  final int rating;
  final String reviewText;

  /// ISO-8601 date/time string for when the review was created/last edited.
  final String date;

  Review copyWith({
    String? id,
    String? gameId,
    String? userId,
    int? rating,
    String? reviewText,
    String? date,
  }) {
    return Review(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      userId: userId ?? this.userId,
      rating: rating ?? this.rating,
      reviewText: reviewText ?? this.reviewText,
      date: date ?? this.date,
    );
  }
}
