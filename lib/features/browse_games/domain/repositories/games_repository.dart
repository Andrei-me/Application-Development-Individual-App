import '../entities/game.dart';

/// Contract for accessing the game catalog and the user's saved list.
abstract class GamesRepository {
  Future<List<Game>> getGames();

  Future<Set<String>> getMyListGameIds(String userId);

  Future<void> addToMyList({
    required String userId,
    required String gameId,
  });

  Future<void> removeFromMyList({
    required String userId,
    required String gameId,
  });
}
