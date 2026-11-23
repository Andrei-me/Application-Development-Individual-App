import 'package:flutter/foundation.dart';

import '../../domain/entities/game.dart';
import '../../domain/repositories/games_repository.dart';

/// Manages browse/search/filter state and the user's saved game list.
class BrowseGamesProvider extends ChangeNotifier {
  BrowseGamesProvider(this._gamesRepository);

  final GamesRepository _gamesRepository;

  List<Game> _allGames = <Game>[];
  Set<String> _myListGameIds = <String>{};
  String _searchQuery = '';
  String _selectedGenre = 'All';
  String _selectedClassification = 'All';
  String _selectedPlatform = 'All';
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentUserId;

  List<Game> get allGames => _allGames;
  String get searchQuery => _searchQuery;
  String get selectedGenre => _selectedGenre;
  String get selectedClassification => _selectedClassification;
  String get selectedPlatform => _selectedPlatform;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<String> get availableGenres {
    final genres = <String>{};
    for (final game in _allGames) {
      genres.addAll(game.genres);
    }
    final sorted = genres.toList()..sort();
    return <String>['All', ...sorted];
  }

  List<String> get availableClassifications {
    final values = <String>{};
    for (final game in _allGames) {
      values.add(game.classification);
    }
    final sorted = values.toList()..sort();
    return <String>['All', ...sorted];
  }

  List<String> get availablePlatforms {
    final platforms = <String>{};
    for (final game in _allGames) {
      platforms.addAll(game.platforms);
    }
    final sorted = platforms.toList()..sort();
    return <String>['All', ...sorted];
  }

  List<Game> get filteredGames {
    final query = _searchQuery.trim().toLowerCase();

    return _allGames.where((game) {
      final matchesTitle = query.isEmpty ||
          game.title.toLowerCase().contains(query);
      final matchesGenre =
          _selectedGenre == 'All' || game.genres.contains(_selectedGenre);
      final matchesClassification = _selectedClassification == 'All' ||
          game.classification == _selectedClassification;
      final matchesPlatform = _selectedPlatform == 'All' ||
          game.platforms.contains(_selectedPlatform);
      return matchesTitle &&
          matchesGenre &&
          matchesClassification &&
          matchesPlatform;
    }).toList();
  }

  bool isInMyList(String gameId) => _myListGameIds.contains(gameId);

  /// Loads the catalog and the current user's saved list.
  Future<void> load(String userId) async {
    _currentUserId = userId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allGames = await _gamesRepository.getGames();
      _myListGameIds = await _gamesRepository.getMyListGameIds(userId);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void selectGenre(String genre) {
    _selectedGenre = genre;
    notifyListeners();
  }

  void selectClassification(String classification) {
    _selectedClassification = classification;
    notifyListeners();
  }

  void selectPlatform(String platform) {
    _selectedPlatform = platform;
    notifyListeners();
  }

  Future<void> toggleMyList(Game game) async {
    final userId = _currentUserId;
    if (userId == null) return;

    if (isInMyList(game.id)) {
      await _gamesRepository.removeFromMyList(userId: userId, gameId: game.id);
      _myListGameIds.remove(game.id);
    } else {
      await _gamesRepository.addToMyList(userId: userId, gameId: game.id);
      _myListGameIds.add(game.id);
    }
    notifyListeners();
  }
}
