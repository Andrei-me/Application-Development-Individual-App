import '../../domain/entities/game.dart';
import '../../domain/repositories/games_repository.dart';
import '../datasources/games_local_data_source.dart';

/// Data-layer implementation of [GamesRepository].
class GamesRepositoryImpl implements GamesRepository {
  GamesRepositoryImpl(this._localDataSource);

  final GamesLocalDataSource _localDataSource;

  @override
  Future<List<Game>> getGames() {
    return _localDataSource.getGames();
  }

  @override
  Future<Set<String>> getMyListGameIds(String userId) {
    return _localDataSource.getMyListGameIds(userId);
  }

  @override
  Future<void> addToMyList({
    required String userId,
    required String gameId,
  }) async {
    final ids = await _localDataSource.getMyListGameIds(userId);
    ids.add(gameId);
    await _localDataSource.saveMyListGameIds(userId, ids);
  }

  @override
  Future<void> removeFromMyList({
    required String userId,
    required String gameId,
  }) async {
    final ids = await _localDataSource.getMyListGameIds(userId);
    ids.remove(gameId);
    await _localDataSource.saveMyListGameIds(userId, ids);
  }
}
