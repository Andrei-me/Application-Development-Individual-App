import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/animated_game_background.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../browse_games/domain/entities/game.dart';
import '../../../browse_games/presentation/providers/browse_games_provider.dart';
import '../../../browse_games/presentation/widgets/game_cover_image.dart';
import '../../domain/entities/review.dart';
import '../providers/reviews_provider.dart';

/// Form for creating or editing a game review.
class ReviewFormPage extends StatefulWidget {
  const ReviewFormPage({super.key, this.existingReview, this.selectedGame});

  final Review? existingReview;
  final Game? selectedGame;

  bool get isEditing => existingReview != null;

  @override
  State<ReviewFormPage> createState() => _ReviewFormPageState();
}

class _ReviewFormPageState extends State<ReviewFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reviewController;

  String? _selectedGameId;
  int _rating = 7;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _reviewController = TextEditingController(text: widget.existingReview?.reviewText ?? '');
    _selectedGameId = widget.existingReview?.gameId ?? widget.selectedGame?.id;
    _rating = widget.existingReview?.rating ?? 7;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<BrowseGamesProvider>().load(user.id);
      }
    });
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) return;

    if (_selectedGameId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a game to review.')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      await context.read<ReviewsProvider>().saveReview(
            gameId: _selectedGameId!,
            rating: _rating,
            reviewText: _reviewController.text,
            existingReviewId: widget.existingReview?.id,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.isEditing ? 'Review updated.' : 'Review saved.')),
      );
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final browseProvider = context.watch<BrowseGamesProvider>();
    final games = browseProvider.allGames;
    final selectedGame = _findSelectedGame(games);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(widget.isEditing ? 'Edit Review' : 'Write Review'),
      ),
      body: AnimatedGameBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.84),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.cyan.withValues(alpha: 0.16)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Game', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        if (widget.isEditing)
                          _SelectedGamePreview(game: selectedGame)
                        else
                          DropdownButtonFormField<String>(
                            key: ValueKey(_selectedGameId ?? 'no-game'),
                            initialValue: _selectedGameId,
                            isExpanded: true,
                            dropdownColor: AppColors.surface,
                            decoration: const InputDecoration(hintText: 'Select a game'),
                            items: games
                                .map((game) => DropdownMenuItem<String>(
                                      value: game.id,
                                      child: Text(game.title, overflow: TextOverflow.ellipsis),
                                    ))
                                .toList(),
                            onChanged: browseProvider.isLoading
                                ? null
                                : (value) => setState(() => _selectedGameId = value),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Please select a game.';
                              return null;
                            },
                          ),
                        if (!widget.isEditing && browseProvider.isLoading) ...[
                          const SizedBox(height: 8),
                          const LinearProgressIndicator(color: AppColors.cyan),
                        ],
                        if (_selectedGameId != null) ...[
                          const SizedBox(height: 12),
                          _SelectedGamePreview(game: selectedGame),
                        ],
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Text('Your rating (1-10)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.cyan.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star_rounded, size: 18, color: AppColors.cyan),
                                  const SizedBox(width: 4),
                                  Text('$_rating/10', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _rating.toDouble(),
                          min: 1,
                          max: 10,
                          divisions: 9,
                          label: '$_rating',
                          activeColor: AppColors.cyan,
                          inactiveColor: AppColors.secondary,
                          onChanged: (value) => setState(() => _rating = value.round()),
                        ),
                        const SizedBox(height: 8),
                        const Text('Review', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _reviewController,
                          minLines: 6,
                          maxLines: 12,
                          textInputAction: TextInputAction.newline,
                          decoration: const InputDecoration(
                            hintText: 'Share your thoughts about this game...',
                            alignLabelWithHint: true,
                          ),
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty) return 'Please write a review.';
                            if (text.length < 10) return 'Please write at least 10 characters.';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : _save,
                            icon: _isSaving
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                                : const Icon(Icons.save_outlined),
                            label: Text(widget.isEditing ? 'Update Review' : 'Save Review'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Game? _findSelectedGame(List<Game> games) {
    final id = _selectedGameId;
    if (id == null) return widget.selectedGame;
    for (final game in games) {
      if (game.id == id) return game;
    }
    return widget.selectedGame;
  }
}

class _SelectedGamePreview extends StatelessWidget {
  const _SelectedGamePreview({required this.game});
  final Game? game;

  @override
  Widget build(BuildContext context) {
    if (game == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cyan.withValues(alpha: 0.12)),
        ),
        child: const Text('Select a game to preview details.', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    final selected = game!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 58,
              height: 80,
              child: GameCoverImage(game: selected, fit: BoxFit.cover, fallbackIconSize: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(selected.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(selected.genres.join(', '), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
