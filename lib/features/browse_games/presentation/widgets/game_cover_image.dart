import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/game.dart';

/// Displays a local game cover image from bundled assets.
///
/// Tries common image extensions for `assets/game_covers/<gameId>.*` and shows
/// a cinematic fallback if no matching cover asset is available.
class GameCoverImage extends StatelessWidget {
  const GameCoverImage({
    super.key,
    required this.game,
    this.fit = BoxFit.cover,
    this.fallbackIconSize = 36,
    this.showFallbackLabel = false,
  });

  final Game game;
  final BoxFit fit;
  final double fallbackIconSize;
  final bool showFallbackLabel;

  static const List<String> _extensions = <String>[
    '.jpg',
    '.png',
    '.jpeg',
    '.webp',
  ];

  @override
  Widget build(BuildContext context) {
    return _buildAttempt(0);
  }

  Widget _buildAttempt(int index) {
    if (index >= _extensions.length) {
      return _FallbackCover(
        iconSize: fallbackIconSize,
        showLabel: showFallbackLabel,
      );
    }

    final path = 'assets/game_covers/${game.id}${_extensions[index]}';
    return Image.asset(
      path,
      fit: fit,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stackTrace) {
        return _buildAttempt(index + 1);
      },
    );
  }
}

class _FallbackCover extends StatelessWidget {
  const _FallbackCover({
    required this.iconSize,
    required this.showLabel,
  });

  final double iconSize;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondary,
            AppColors.surface,
            AppColors.blue.withValues(alpha: 0.35),
          ],
        ),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cyan.withValues(alpha: 0.12),
              border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
            ),
            child: Icon(
              Icons.sports_esports_rounded,
              size: iconSize,
              color: AppColors.cyan,
            ),
          ),
          if (showLabel) ...[
            const SizedBox(height: 10),
            const Text(
              'Cover unavailable',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
