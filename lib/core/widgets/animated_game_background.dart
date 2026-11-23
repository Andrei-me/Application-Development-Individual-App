import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../constants/app_colors.dart';

/// Cinematic animated background with shifting gradients, ambient glow,
/// and floating cyan/blue particles. Designed to be lightweight.
class AnimatedGameBackground extends StatefulWidget {
  const AnimatedGameBackground({
    super.key,
    this.child,
    this.showParticles = true,
    this.intensity = 1.0,
  });

  final Widget? child;
  final bool showParticles;
  final double intensity;

  @override
  State<AnimatedGameBackground> createState() => _AnimatedGameBackgroundState();
}

class _AnimatedGameBackgroundState extends State<AnimatedGameBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    final rand = math.Random(42);
    _particles = List<_Particle>.generate(26, (i) {
      final cyan = i.isEven;
      return _Particle(
        x: rand.nextDouble(),
        y: rand.nextDouble(),
        radius: 1.2 + rand.nextDouble() * 2.6,
        speed: 0.015 + rand.nextDouble() * 0.035,
        drift: (rand.nextDouble() - 0.5) * 0.02,
        phase: rand.nextDouble() * math.pi * 2,
        color: (cyan ? AppColors.cyan : AppColors.blue)
            .withValues(alpha: 0.18 + rand.nextDouble() * 0.28),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          final a = Alignment(
            math.sin(t * math.pi * 2) * 0.7,
            math.cos(t * math.pi * 2) * 0.7,
          );
          final b = Alignment(
            math.cos(t * math.pi * 2 + 1.2) * -0.8,
            math.sin(t * math.pi * 2 + 0.6) * 0.8,
          );
          return Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: a,
                    end: b,
                    colors: const [
                      AppColors.background,
                      AppColors.secondary,
                      Color(0xFF0B1630),
                      AppColors.background,
                    ],
                    stops: const [0.0, 0.35, 0.7, 1.0],
                  ),
                ),
              ),
              // Ambient glows
              Positioned(
                left: -80 + 40 * math.sin(t * math.pi * 2),
                top: -40 + 30 * math.cos(t * math.pi * 2),
                child: _GlowBlob(
                  size: 260 * widget.intensity,
                  color: AppColors.cyan.withValues(alpha: 0.12),
                ),
              ),
              Positioned(
                right: -60 + 30 * math.cos(t * math.pi * 2 + 0.8),
                bottom: 40 + 50 * math.sin(t * math.pi * 2),
                child: _GlowBlob(
                  size: 300 * widget.intensity,
                  color: AppColors.blue.withValues(alpha: 0.14),
                ),
              ),
              Positioned(
                right: 80 + 20 * math.sin(t * math.pi * 2 + 2),
                top: 120 + 20 * math.cos(t * math.pi * 2),
                child: _GlowBlob(
                  size: 180 * widget.intensity,
                  color: AppColors.cyan.withValues(alpha: 0.08),
                ),
              ),
              if (widget.showParticles)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ParticlePainter(
                      particles: _particles,
                      progress: t,
                    ),
                  ),
                ),
              // Soft vignette/overlay for readability
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.background.withValues(alpha: 0.15),
                        Colors.transparent,
                        AppColors.background.withValues(alpha: 0.35),
                      ],
                    ),
                  ),
                ),
              ),
              ?child,
            ],
          );
        },
        child: widget.child,
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0.0)],
          ),
        ),
      ),
    );
  }
}

class _Particle {
  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.drift,
    required this.phase,
    required this.color,
  });

  final double x;
  final double y;
  final double radius;
  final double speed;
  final double drift;
  final double phase;
  final Color color;
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({required this.particles, required this.progress});

  final List<_Particle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final dy = (p.y - progress * p.speed * 20) % 1.0;
      final dx = (p.x + math.sin(progress * math.pi * 2 + p.phase) * p.drift + 1.0) % 1.0;
      final twinkle = 0.55 + 0.45 * math.sin(progress * math.pi * 4 + p.phase);
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.color.a * twinkle)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
      canvas.drawCircle(Offset(dx * size.width, dy * size.height), p.radius, paint);
      final core = Paint()..color = Colors.white.withValues(alpha: 0.18 * twinkle);
      canvas.drawCircle(Offset(dx * size.width, dy * size.height), p.radius * 0.35, core);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}