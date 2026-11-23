import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/game.dart';
import '../providers/browse_games_provider.dart';
import '../widgets/game_cover_image.dart';
import 'game_details_page.dart';

/// Collection shelves for games saved to "My List".
class MyListsPage extends StatefulWidget {
  const MyListsPage({super.key, this.embedded = false});

  static const String routeName = '/my-lists';

  final bool embedded;

  @override
  State<MyListsPage> createState() => _MyListsPageState();
}

class _MyListsPageState extends State<MyListsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureLoaded());
  }

  void _ensureLoaded() {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    context.read<BrowseGamesProvider>().load(user.id);
  }

  Future<void> _removeGame(Game game) async {
    final provider = context.read<BrowseGamesProvider>();
    if (!provider.isInMyList(game.id)) return;
    await provider.toggleMyList(game);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed "${game.title}" from My List.')),
    );
  }

  void _open(Game game) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameDetailsPage(game: game)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final provider = context.watch<BrowseGamesProvider>();

    Widget body;
    if (user == null) {
      body = const Center(child: Text('Please log in to view your list.'));
    } else {
      final savedGames =
          provider.allGames.where((g) => provider.isInMyList(g.id)).toList();
      body = _buildBody(provider, savedGames);
    }

    if (widget.embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(
              'My Lists',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Your curated collection shelves',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          Expanded(child: body),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('My Lists')),
      body: body,
    );
  }

  Widget _buildBody(BrowseGamesProvider provider, List<Game> savedGames) {
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
    if (savedGames.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.cyan.withValues(alpha: 0.15)),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bookmarks_outlined, size: 64, color: AppColors.cyan),
                SizedBox(height: 14),
                Text(
                  'Your shelves are empty',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Save games from Browse to build your personal collection shelves.',
                  style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 800;
        if (wide) {
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            itemCount: savedGames.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 420,
              mainAxisExtent: 150,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) => _ShelfTile(
              game: savedGames[index],
              onOpen: () => _open(savedGames[index]),
              onRemove: () => _removeGame(savedGames[index]),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          itemCount: savedGames.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _ShelfTile(
            game: savedGames[index],
            onOpen: () => _open(savedGames[index]),
            onRemove: () => _removeGame(savedGames[index]),
          ),
        );
      },
    );
  }
}

class _ShelfTile extends StatefulWidget {
  const _ShelfTile({
    required this.game,
    required this.onOpen,
    required this.onRemove,
  });

  final Game game;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  @override
  State<_ShelfTile> createState() => _ShelfTileState();
}

class _ShelfTileState extends State<_ShelfTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.84),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hover
                ? AppColors.cyan.withValues(alpha: 0.45)
                : AppColors.cyan.withValues(alpha: 0.12),
          ),
          boxShadow: _hover
              ? [
                  BoxShadow(
                    color: AppColors.cyan.withValues(alpha: 0.14),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: InkWell(
          onTap: widget.onOpen,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 84,
                    height: 120,
                    child: GameCoverImage(game: game, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              game.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const _StatusChip(label: 'In My List'),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        game.genres.take(3).join(' ? '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${game.classification} ? ${game.releaseYear}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 16, color: AppColors.cyan),
                          const SizedBox(width: 4),
                          Text(
                            game.rating == null ? 'N/A' : game.rating!.toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            tooltip: 'Remove from My List',
                            onPressed: widget.onRemove,
                            icon: const Icon(Icons.delete_outline_rounded),
                            color: AppColors.error.withValues(alpha: 0.9),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cyan.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.cyan,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
