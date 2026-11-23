import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/animated_game_background.dart';
import '../../domain/entities/game.dart';
import '../providers/browse_games_provider.dart';
import '../widgets/game_cover_image.dart';

class GameDetailsPage extends StatelessWidget {
  const GameDetailsPage({super.key, required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BrowseGamesProvider>();
    final isInMyList = provider.isInMyList(game.id);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(game.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: AnimatedGameBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 760;
              final image = ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      GameCoverImage(
                        game: game,
                        fit: BoxFit.cover,
                        fallbackIconSize: 64,
                        showFallbackLabel: true,
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.background.withValues(alpha: 0.25),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );

              final details = Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.cyan.withValues(alpha: 0.16)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blue.withValues(alpha: 0.12),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _Badge(label: game.classification, color: AppColors.cyan),
                        _Badge(label: game.releaseYear, color: AppColors.blue),
                        if (game.rating != null)
                          _Badge(label: '? ${game.rating!.toStringAsFixed(1)}', color: AppColors.cyan),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      game.title,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: game.genres
                          .map(
                            (genre) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.cyan.withValues(alpha: 0.14)),
                              ),
                              child: Text(
                                genre,
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 18),
                    _InfoRow(icon: Icons.business_rounded, label: 'Developer', value: game.developer),
                    const SizedBox(height: 10),
                    _InfoRow(icon: Icons.videogame_asset_outlined, label: 'Platforms', value: game.platforms.join(', ')),
                    const SizedBox(height: 10),
                    _InfoRow(icon: Icons.workspace_premium_outlined, label: 'Classification', value: game.classification),
                    const SizedBox(height: 10),
                    _InfoRow(icon: Icons.star_rounded, label: 'Rating', value: game.rating == null ? 'N/A' : game.rating!.toStringAsFixed(1)),
                    const SizedBox(height: 20),
                    const Text(
                      'Description',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      game.description,
                      style: const TextStyle(color: AppColors.textSecondary, height: 1.55, fontSize: 15),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await provider.toggleMyList(game);
                          if (!context.mounted) return;
                          final added = provider.isInMyList(game.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                added
                                    ? 'Added "${game.title}" to My List.'
                                    : 'Removed "${game.title}" from My List.',
                              ),
                            ),
                          );
                        },
                        icon: Icon(isInMyList ? Icons.bookmark_remove_rounded : Icons.bookmark_add_rounded),
                        label: Text(isInMyList ? 'Remove from My List' : 'Add to My List'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Cover art loads from local offline assets. If a cover file is unavailable, a cinematic fallback is shown.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary.withValues(alpha: 0.9), height: 1.35),
                    ),
                  ],
                ),
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 4, child: image),
                              const SizedBox(width: 18),
                              Expanded(flex: 6, child: details),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              image,
                              const SizedBox(height: 16),
                              details,
                            ],
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.cyan),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.4),
              children: [
                TextSpan(text: '$label: ', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
