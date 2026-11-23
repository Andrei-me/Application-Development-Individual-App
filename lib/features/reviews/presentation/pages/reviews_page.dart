import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../browse_games/domain/entities/game.dart';
import '../../../browse_games/presentation/providers/browse_games_provider.dart';
import '../../../browse_games/presentation/widgets/game_cover_image.dart';
import '../../domain/entities/review.dart';
import '../providers/reviews_provider.dart';
import 'review_form_page.dart';

/// Displays the current user's game reviews.
class ReviewsPage extends StatefulWidget {
  const ReviewsPage({super.key, this.embedded = false});

  static const String routeName = '/reviews';

  final bool embedded;

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureLoaded());
  }

  void _ensureLoaded() {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    context.read<BrowseGamesProvider>().load(user.id);
    context.read<ReviewsProvider>().load(user.id);
  }

  Future<void> _openCreateReview() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReviewFormPage()),
    );
  }

  Future<void> _openEditReview(Review review, Game game) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewFormPage(existingReview: review, selectedGame: game),
      ),
    );
  }

  Future<void> _deleteReview(Review review, Game? game) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete review?'),
        content: Text(
          'Delete your review for "${game?.title ?? 'this game'}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<ReviewsProvider>().deleteReview(review.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Review deleted.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final reviewsProvider = context.watch<ReviewsProvider>();
    final browseProvider = context.watch<BrowseGamesProvider>();

    Widget body;
    if (user == null) {
      body = const Center(child: Text('Please log in to view your reviews.'));
    } else {
      body = _buildBody(reviewsProvider, browseProvider);
    }

    if (widget.embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reviews',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Your ratings and thoughts',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _openCreateReview,
                  icon: const Icon(Icons.rate_review_rounded),
                  label: const Text('Write'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(0, 44)),
                ),
              ],
            ),
          ),
          Expanded(child: body),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Reviews')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateReview,
        backgroundColor: AppColors.cyan,
        foregroundColor: const Color(0xFF041018),
        icon: const Icon(Icons.rate_review_rounded),
        label: const Text('Write Review'),
      ),
      body: body,
    );
  }

  Widget _buildBody(ReviewsProvider reviewsProvider, BrowseGamesProvider browseProvider) {
    if ((reviewsProvider.isLoading && reviewsProvider.reviews.isEmpty) ||
        (browseProvider.isLoading && browseProvider.allGames.isEmpty)) {
      return const Center(child: CircularProgressIndicator(color: AppColors.cyan));
    }

    final error = reviewsProvider.errorMessage ?? browseProvider.errorMessage;
    if (error != null && reviewsProvider.reviews.isEmpty && browseProvider.allGames.isEmpty) {
      return Center(
        child: Text(error, style: const TextStyle(color: AppColors.error), textAlign: TextAlign.center),
      );
    }

    final reviews = reviewsProvider.reviews;
    if (reviews.isEmpty) return _buildEmptyState();

    final gameById = <String, Game>{for (final game in browseProvider.allGames) game.id: game};
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: reviews.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final review = reviews[index];
        final game = gameById[review.gameId];
        return _ReviewCard(
          review: review,
          game: game,
          onEdit: game == null ? null : () => _openEditReview(review, game),
          onDelete: () => _deleteReview(review, game),
        );
      },
    );
  }

  Widget _buildEmptyState() {
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.rate_review_outlined, size: 64, color: AppColors.cyan),
              const SizedBox(height: 14),
              const Text(
                'No reviews yet',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Rate games and share your thoughts. Your reviews help build your gaming legacy.',
                style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _openCreateReview,
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Write a review'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.review,
    required this.game,
    required this.onEdit,
    required this.onDelete,
  });

  final Review review;
  final Game? game;
  final VoidCallback? onEdit;
  final VoidCallback onDelete;

  String _formatDate(String isoDate) {
    final parsed = DateTime.tryParse(isoDate)?.toLocal();
    if (parsed == null) return isoDate;
    final y = parsed.year.toString().padLeft(4, '0');
    final m = parsed.month.toString().padLeft(2, '0');
    final d = parsed.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  @override
  Widget build(BuildContext context) {
    final title = game?.title ?? 'Unknown game';
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 78,
                    height: 108,
                    child: game == null
                        ? Container(
                            color: AppColors.secondary,
                            child: const Icon(Icons.videogame_asset_rounded, color: AppColors.cyan),
                          )
                        : GameCoverImage(game: game!, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _RatingPill(rating: review.rating),
                          Text(
                            'Reviewed ${_formatDate(review.date)}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Edit review',
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                      color: AppColors.cyan,
                    ),
                    IconButton(
                      tooltip: 'Delete review',
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded),
                      color: AppColors.error.withValues(alpha: 0.9),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cyan.withValues(alpha: 0.08)),
              ),
              child: Text(
                review.reviewText,
                style: const TextStyle(color: AppColors.textSecondary, height: 1.5, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  const _RatingPill({required this.rating});
  final int rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.cyan.withValues(alpha: 0.22),
            AppColors.blue.withValues(alpha: 0.18),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 16, color: AppColors.cyan),
          const SizedBox(width: 4),
          Text(
            '$rating/10',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
