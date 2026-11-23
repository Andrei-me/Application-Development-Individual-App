import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/animated_game_background.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../browse_games/domain/entities/game.dart';
import '../../../browse_games/presentation/pages/browse_games_page.dart';
import '../../../browse_games/presentation/pages/game_details_page.dart';
import '../../../browse_games/presentation/pages/my_lists_page.dart';
import '../../../browse_games/presentation/providers/browse_games_provider.dart';
import '../../../browse_games/presentation/widgets/game_cover_image.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../reviews/presentation/pages/reviews_page.dart';
import '../../../reviews/presentation/providers/reviews_provider.dart';

/// Cinematic home dashboard for GameVault.
class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key, this.embedded = false, this.onNavigate});

  static const String routeName = '/home';

  final bool embedded;
  final ValueChanged<int>? onNavigate;

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureDataLoaded());
  }

  void _ensureDataLoaded() {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    context.read<BrowseGamesProvider>().load(user.id);
    context.read<ReviewsProvider>().load(user.id);
  }

  void _openSection(int index) {
    if (widget.embedded && widget.onNavigate != null) {
      widget.onNavigate!(index);
      return;
    }
    switch (index) {
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BrowseGamesPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MyListsPage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReviewsPage()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfilePage()),
        );
        break;
      default:
        Navigator.pushReplacementNamed(context, AppShellPage.routeName);
    }
  }

  void _openGame(Game game) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameDetailsPage(game: game)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final browse = context.watch<BrowseGamesProvider>();
    final reviewsProvider = context.watch<ReviewsProvider>();
    final games = browse.allGames;

    final featured = _pickFeatured(games);
    final recentlyAdded = games.length <= 8
        ? List<Game>.from(games.reversed)
        : games.reversed.take(10).toList();
    final trending = _pickTrending(games, featured);

    final myListCount = games.where((g) => browse.isInMyList(g.id)).length;
    final reviewCount = reviewsProvider.reviews.length;
    final avgRating = reviewCount == 0
        ? null
        : reviewsProvider.reviews.map((r) => r.rating).reduce((a, b) => a + b) /
            reviewCount;

    final content = RefreshIndicator(
      color: AppColors.cyan,
      onRefresh: () async => _ensureDataLoaded(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: _DashboardHeader(
                username: user?.username ?? 'Gamer',
                embedded: widget.embedded,
                onSearch: () => _openSection(1),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: _FeaturedHero(
                game: featured,
                isLoading: browse.isLoading && games.isEmpty,
                onBrowse: () => _openSection(1),
                onOpen: featured == null ? null : () => _openGame(featured),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _SectionBlock(
              title: 'Collection Statistics',
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _StatsGrid(
                catalogCount: games.length,
                myListCount: myListCount,
                reviewCount: reviewCount,
                averageRating: avgRating,
                onMyLists: () => _openSection(2),
                onReviews: () => _openSection(3),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _SectionBlock(
              title: 'Recently Added',
              actionLabel: 'Browse all',
              onAction: () => _openSection(1),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: _CoverShelf(
                games: recentlyAdded,
                isLoading: browse.isLoading && games.isEmpty,
                onOpen: _openGame,
                isSaved: browse.isInMyList,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _SectionBlock(
              title: 'Trending Games',
              actionLabel: 'Explore',
              onAction: () => _openSection(1),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: _CoverShelf(
                games: trending,
                isLoading: browse.isLoading && games.isEmpty,
                onOpen: _openGame,
                isSaved: browse.isInMyList,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _SectionBlock(
              title: 'Recently Reviewed',
              actionLabel: 'All reviews',
              onAction: () => _openSection(3),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: _RecentReviewsStrip(
                reviews: reviewsProvider.reviews.take(8).toList(),
                gameById: {for (final g in games) g.id: g},
                onOpen: _openGame,
                onOpenReviews: () => _openSection(3),
              ),
            ),
          ),
        ],
      ),
    );

    if (widget.embedded) {
      return content;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedGameBackground(child: SafeArea(child: content)),
    );
  }

  static Game? _pickFeatured(List<Game> games) {
    if (games.isEmpty) return null;
    final rated = games.where((g) => g.rating != null).toList()
      ..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    return rated.isNotEmpty ? rated.first : games.first;
  }

  static List<Game> _pickTrending(List<Game> games, Game? featured) {
    if (games.length <= 1) return List<Game>.from(games);
    final list = games.where((g) => g.id != featured?.id).toList();
    list.sort((a, b) {
      final ar = a.rating ?? -1;
      final br = b.rating ?? -1;
      final cmp = br.compareTo(ar);
      if (cmp != 0) return cmp;
      return b.releaseYear.compareTo(a.releaseYear);
    });
    return list.take(10).toList();
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.username,
    required this.embedded,
    required this.onSearch,
  });

  final String username;
  final bool embedded;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                embedded ? 'Command Center' : 'GameVault',
                style: const TextStyle(
                  color: AppColors.cyan,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Welcome back, $username',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Your cinematic collection awaits',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
        _GlowIconButton(
          icon: Icons.search_rounded,
          tooltip: 'Search catalog',
          onTap: onSearch,
        ),
      ],
    );
  }
}

class _GlowIconButton extends StatelessWidget {
  const _GlowIconButton({required this.icon, required this.tooltip, required this.onTap});
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cyan.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: AppColors.cyan.withValues(alpha: 0.12),
                blurRadius: 12,
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.cyan),
        ),
      ),
    );
  }
}

class _FeaturedHero extends StatelessWidget {
  const _FeaturedHero({
    required this.game,
    required this.isLoading,
    required this.onBrowse,
    this.onOpen,
  });

  final Game? game;
  final bool isLoading;
  final VoidCallback onBrowse;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 700;
        final height = wide ? 280.0 : 320.0;
        return Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.cyan.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: AppColors.blue.withValues(alpha: 0.18),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (game != null)
                  GameCoverImage(game: game!, fit: BoxFit.cover)
                else
                  Container(color: AppColors.secondary),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.background.withValues(alpha: 0.96),
                        AppColors.background.withValues(alpha: 0.75),
                        AppColors.background.withValues(alpha: 0.25),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppColors.background.withValues(alpha: 0.85),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                if (isLoading)
                  const Center(child: CircularProgressIndicator(color: AppColors.cyan))
                else
                  Padding(
                    padding: EdgeInsets.all(wide ? 28 : 20),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.cyan.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.cyan.withValues(alpha: 0.35)),
                            ),
                            child: const Text(
                              'CINEMATIC FEATURED',
                              style: TextStyle(
                                color: AppColors.cyan,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            game?.title ?? 'Discover GameVault',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: wide ? 34 : 26,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            game == null
                                ? 'Browse the full catalog, track your collection, and review your favorites.'
                                : '${game!.classification} ? ${game!.genres.take(3).join(' ? ')} ? ${game!.releaseYear}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                          ),
                          if (game?.description != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              game!.description,
                              maxLines: wide ? 2 : 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textSecondary.withValues(alpha: 0.95),
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            children: [
                              ElevatedButton.icon(
                                onPressed: onOpen ?? onBrowse,
                                icon: const Icon(Icons.play_arrow_rounded),
                                label: Text(game == null ? 'Browse catalog' : 'View game'),
                              ),
                              OutlinedButton.icon(
                                onPressed: onBrowse,
                                icon: const Icon(Icons.explore_outlined),
                                label: const Text('Browse Games'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({
    required this.title,
    required this.child,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 8),
  });

  final String title;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (actionLabel != null && onAction != null)
                TextButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: Text(actionLabel!),
                ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.catalogCount,
    required this.myListCount,
    required this.reviewCount,
    required this.averageRating,
    required this.onMyLists,
    required this.onReviews,
  });

  final int catalogCount;
  final int myListCount;
  final int reviewCount;
  final double? averageRating;
  final VoidCallback onMyLists;
  final VoidCallback onReviews;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 700;
        final cross = wide ? 4 : 2;
        final tiles = [
          _StatTileData('Catalog', '$catalogCount', Icons.videogame_asset_rounded, AppColors.cyan, null),
          _StatTileData('My List', '$myListCount', Icons.bookmark_rounded, AppColors.blue, onMyLists),
          _StatTileData('Reviews', '$reviewCount', Icons.rate_review_rounded, AppColors.cyan, onReviews),
          _StatTileData('Avg Rating', averageRating == null ? 'N/A' : averageRating!.toStringAsFixed(1), Icons.star_rounded, AppColors.blue, null),
        ];
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tiles.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cross,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: wide ? 1.9 : 1.55,
          ),
          itemBuilder: (context, i) => _StatCard(data: tiles[i]),
        );
      },
    );
  }
}

class _StatTileData {
  const _StatTileData(this.label, this.value, this.icon, this.color, this.onTap);
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});
  final _StatTileData data;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: data.color.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(color: data.color.withValues(alpha: 0.1), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.icon, color: data.color),
          const Spacer(),
          Text(
            data.value,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(data.label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
    if (data.onTap == null) return card;
    return InkWell(onTap: data.onTap, borderRadius: BorderRadius.circular(18), child: card);
  }
}

class _CoverShelf extends StatelessWidget {
  const _CoverShelf({
    required this.games,
    required this.isLoading,
    required this.onOpen,
    required this.isSaved,
  });

  final List<Game> games;
  final bool isLoading;
  final ValueChanged<Game> onOpen;
  final bool Function(String id) isSaved;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator(color: AppColors.cyan)),
      );
    }
    if (games.isEmpty) {
      return Container(
        height: 120,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cyan.withValues(alpha: 0.12)),
        ),
        child: const Text('No games to show yet.', style: TextStyle(color: AppColors.textSecondary)),
      );
    }
    return SizedBox(
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: games.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final game = games[index];
          return SizedBox(
            width: 150,
            child: _MiniCoverCard(
              game: game,
              saved: isSaved(game.id),
              onTap: () => onOpen(game),
            ),
          );
        },
      ),
    );
  }
}

class _MiniCoverCard extends StatefulWidget {
  const _MiniCoverCard({required this.game, required this.saved, required this.onTap});
  final Game game;
  final bool saved;
  final VoidCallback onTap;

  @override
  State<_MiniCoverCard> createState() => _MiniCoverCardState();
}

class _MiniCoverCardState extends State<_MiniCoverCard> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        scale: _hover ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _hover ? AppColors.cyan.withValues(alpha: 0.5) : AppColors.cyan.withValues(alpha: 0.12),
              ),
              boxShadow: _hover
                  ? [BoxShadow(color: AppColors.cyan.withValues(alpha: 0.18), blurRadius: 18, offset: const Offset(0, 8))]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                        child: GameCoverImage(game: widget.game, fit: BoxFit.cover),
                      ),
                      if (widget.saved)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: AppColors.background.withValues(alpha: 0.7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.bookmark_rounded, size: 14, color: AppColors.cyan),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.game.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.game.genres.isNotEmpty ? widget.game.genres.first : widget.game.classification,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
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

class _RecentReviewsStrip extends StatelessWidget {
  const _RecentReviewsStrip({
    required this.reviews,
    required this.gameById,
    required this.onOpen,
    required this.onOpenReviews,
  });

  final List reviews;
  final Map<String, Game> gameById;
  final ValueChanged<Game> onOpen;
  final VoidCallback onOpenReviews;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cyan.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            const Icon(Icons.rate_review_outlined, color: AppColors.cyan),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'No reviews yet. Share your thoughts on games you play.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(onPressed: onOpenReviews, child: const Text('Write one')),
          ],
        ),
      );
    }
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: reviews.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final review = reviews[index];
          final game = gameById[review.gameId];
          return InkWell(
            onTap: game == null ? onOpenReviews : () => onOpen(game),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 280,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.cyan.withValues(alpha: 0.14)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 70,
                      height: 100,
                      child: game == null
                          ? Container(color: AppColors.secondary, child: const Icon(Icons.videogame_asset, color: AppColors.cyan))
                          : GameCoverImage(game: game, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          game?.title ?? 'Unknown game',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: AppColors.cyan, size: 16),
                            const SizedBox(width: 4),
                            Text('${review.rating}/10', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: Text(
                            review.reviewText,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
