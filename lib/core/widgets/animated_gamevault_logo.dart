import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../constants/app_colors.dart';

/// Animated GameVault logo for splash and authentication screens.
class AnimatedGameVaultLogo extends StatefulWidget {
  const AnimatedGameVaultLogo({
    super.key,
    this.size = 96,
    this.showWordmark = true,
    this.compact = false,
  });

  final double size;
  final bool showWordmark;
  final bool compact;

  @override
  State<AnimatedGameVaultLogo> createState() => _AnimatedGameVaultLogoState();
}

class _AnimatedGameVaultLogoState extends State<AnimatedGameVaultLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final pulse = 0.92 + 0.08 * math.sin(t * math.pi * 2);
        final glow = 0.35 + 0.25 * (0.5 + 0.5 * math.sin(t * math.pi * 2));
        final rotate = math.sin(t * math.pi * 2) * 0.03;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.rotate(
              angle: rotate,
              child: Transform.scale(
                scale: pulse,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.size * 0.28),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.secondary, AppColors.surface],
                    ),
                    border: Border.all(
                      color: AppColors.cyan.withValues(alpha: 0.7),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cyan.withValues(alpha: glow),
                        blurRadius: 28,
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: AppColors.blue.withValues(alpha: glow * 0.6),
                        blurRadius: 36,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(widget.size * 0.28),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.cyan.withValues(alpha: 0.18),
                                Colors.transparent,
                                AppColors.blue.withValues(alpha: 0.16),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.sports_esports_rounded,
                        size: widget.size * 0.46,
                        color: AppColors.cyan,
                      ),
                      Positioned(
                        bottom: widget.size * 0.18,
                        child: Container(
                          width: widget.size * 0.34,
                          height: 3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: const LinearGradient(
                              colors: [AppColors.cyan, AppColors.blue],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.cyan.withValues(alpha: 0.6),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (widget.showWordmark) ...[
              SizedBox(height: widget.compact ? 10 : 16),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.textPrimary, AppColors.cyan],
                ).createShader(bounds),
                child: Text(
                  'GameVault',
                  style: TextStyle(
                    fontSize: widget.compact ? 24 : 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}