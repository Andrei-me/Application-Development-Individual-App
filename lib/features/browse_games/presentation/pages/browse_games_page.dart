import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/game.dart';
import '../providers/browse_games_provider.dart';
import '../widgets/game_card.dart';
import 'game_details_page.dart';

/// Responsive catalog browser with search and filters.
class BrowseGamesPage extends StatefulWidget {
  const BrowseGamesPage({super.key, this.embedded = false});

  static const String routeName = '/browse-games';

  final bool embedded;

  @override
  State<BrowseGamesPage> createState() => _BrowseGamesPageState();
}

class _BrowseGamesPageState extends State<BrowseGamesPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<BrowseGamesProvider>().load(user.id);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetails(Game game) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameDetailsPage(game: game)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BrowseGamesProvider>();
    final user = context.watch<AuthProvider>().currentUser;

    final body = user == null
        ? const Center(child: Text('Please log in to browse games.'))
        : _buildBody(provider);

    if (widget.embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: _buildHeader(provider),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: body,
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Browse Games')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(provider),
            const SizedBox(height: 12),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BrowseGamesProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Browse Games',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Explore ${provider.allGames.length} titles across your GameVault catalog',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _searchController,
          onChanged: provider.updateSearchQuery,
          decoration: InputDecoration(
            hintText: 'Search games by title',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: provider.searchQuery.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      _searchController.clear();
                      provider.updateSearchQuery('');
                    },
                  ),
          ),
        ),
        const SizedBox(height: 12),
        _FilterRow(
          label: 'Classification',
          values: provider.availableClassifications,
          selectedValue: provider.selectedClassification,
          onSelected: provider.selectClassification,
        ),
        const SizedBox(height: 8),
        _FilterRow(
          label: 'Genre',
          values: provider.availableGenres,
          selectedValue: provider.selectedGenre,
          onSelected: provider.selectGenre,
        ),
        const SizedBox(height: 8),
        _FilterRow(
          label: 'Platform',
          values: provider.availablePlatforms,
          selectedValue: provider.selectedPlatform,
          onSelected: provider.selectPlatform,
        ),
      ],
    );
  }

  Widget _buildBody(BrowseGamesProvider provider) {
    if (provider.isLoading && provider.allGames.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.cyan),
      );
    }

    if (provider.errorMessage != null && provider.allGames.isEmpty) {
      return Center(
        child: Text(
          provider.errorMessage!,
          style: const TextStyle(color: AppColors.error),
          textAlign: TextAlign.center,
        ),
      );
    }

    final games = provider.filteredGames;
    if (games.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cyan.withValues(alpha: 0.12)),
          ),
          child: const Text(
            'No games found. Try a different search or filter.',
            style: TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            '${games.length} result${games.length == 1 ? '' : 's'}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              int crossAxisCount = 2;
              if (width >= 1200) {
                crossAxisCount = 5;
              } else if (width >= 900) {
                crossAxisCount = 4;
              } else if (width >= 600) {
                crossAxisCount = 3;
              }
              return GridView.builder(
                itemCount: games.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.62,
                ),
                itemBuilder: (context, index) {
                  final game = games[index];
                  return GameCard(
                    game: game,
                    isInMyList: provider.isInMyList(game.id),
                    onTap: () => _openDetails(game),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.label,
    required this.values,
    required this.selectedValue,
    required this.onSelected,
  });

  final String label;
  final List<String> values;
  final String selectedValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: values.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final value = values[index];
              final selected = value == selectedValue;
              return ChoiceChip(
                label: Text(value),
                selected: selected,
                onSelected: (_) => onSelected(value),
                selectedColor: AppColors.cyan.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  color: selected ? AppColors.cyan : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
                backgroundColor: AppColors.secondary.withValues(alpha: 0.7),
                side: BorderSide(
                  color: selected
                      ? AppColors.cyan.withValues(alpha: 0.5)
                      : AppColors.cyan.withValues(alpha: 0.12),
                ),
                visualDensity: VisualDensity.compact,
                showCheckmark: false,
              );
            },
          ),
        ),
      ],
    );
  }
}
