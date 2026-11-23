/// Represents a video game in the browse catalog.
class Game {
  const Game({
    required this.id,
    required this.title,
    required this.description,
    required this.genres,
    required this.releaseYear,
    required this.developer,
    required this.platforms,
    required this.classification,
    required this.coverImagePath,
    this.rating,
  });

  final String id;
  final String title;
  final String description;
  final List<String> genres;
  final String releaseYear;
  final String developer;
  final List<String> platforms;

  /// AAA, AA, or Indie classification.
  final String classification;

  /// Local asset path for the game's cover image (offline).
  final String coverImagePath;

  /// Optional rating. Null when no rating is provided/invented.
  final double? rating;
}
