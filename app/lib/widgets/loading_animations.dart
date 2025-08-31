import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';

/// Calming loading animations for the Lunanul app
class CalmingLoadingAnimation extends StatelessWidget {
  final double size;
  final Color? color;
  final String? message;

  const CalmingLoadingAnimation({
    super.key,
    this.size = 48,
    this.color,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? AppTheme.primaryPurple;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color.withValues(alpha: 0.3),
                    color.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Center(
                child: Icon(Icons.nights_stay, size: size * 0.4, color: color),
              ),
            )
            .animate(onPlay: (controller) => controller.repeat())
            .rotate(duration: 3.seconds, curve: Curves.linear)
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.2, 1.2),
              duration: 1.5.seconds,
              curve: Curves.easeInOut,
            )
            .shimmer(duration: 2.seconds, color: color.withValues(alpha: 0.3)),

        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              )
              .animate()
              .fadeIn(duration: 500.ms, delay: 200.ms)
              .slideY(begin: 0.3, end: 0, duration: 400.ms, delay: 200.ms),
        ],
      ],
    );
  }
}

/// Floating particles animation for background ambiance
class FloatingParticlesAnimation extends StatelessWidget {
  final int particleCount;
  final double width;
  final double height;
  final Color? particleColor;

  const FloatingParticlesAnimation({
    super.key,
    this.particleCount = 20,
    this.width = 300,
    this.height = 200,
    this.particleColor,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        particleColor ?? AppTheme.primaryPurple.withValues(alpha: 0.1);

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: List.generate(particleCount, (index) {
          final delay = (index * 100).ms;
          final duration = (3000 + (index * 200)).ms;

          return Positioned(
            left: (index * 15) % width,
            child:
                Container(
                      width: 4 + (index % 3).toDouble(),
                      height: 4 + (index % 3).toDouble(),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                      ),
                    )
                    .animate(onPlay: (controller) => controller.repeat())
                    .moveY(
                      begin: height + 20,
                      end: -20,
                      duration: duration,
                      delay: delay,
                      curve: Curves.linear,
                    )
                    .fadeIn(duration: 500.ms, delay: delay)
                    .fadeOut(duration: 500.ms, delay: duration - 500.ms),
          );
        }),
      ),
    );
  }
}

/// Breathing animation for meditation-like effects
class BreathingAnimation extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;

  const BreathingAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 4),
    this.minScale = 0.95,
    this.maxScale = 1.05,
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: Offset(minScale, minScale),
          end: Offset(maxScale, maxScale),
          duration: duration,
          curve: Curves.easeInOut,
        );
  }
}

/// Gentle wave animation for backgrounds
class WaveAnimation extends StatelessWidget {
  final double height;
  final Color color;
  final Duration duration;

  const WaveAnimation({
    super.key,
    this.height = 100,
    required this.color,
    this.duration = const Duration(seconds: 3),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
          size: Size(double.infinity, height),
          painter: _WavePainter(color: color),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .custom(
          duration: duration,
          builder: (context, value, child) {
            return CustomPaint(
              size: Size(double.infinity, height),
              painter: _WavePainter(color: color, animationValue: value),
            );
          },
        );
  }
}

class _WavePainter extends CustomPainter {
  final double animationValue;
  final Color color;

  _WavePainter({this.animationValue = 0.0, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = size.height * 0.3;
    final waveLength = size.width;

    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x += 1) {
      final y =
          size.height -
          waveHeight *
              (0.5 +
                  0.5 *
                      (sin(
                            (x / waveLength * 2 * 3.14159) +
                                (animationValue * 2 * 3.14159),
                          ) +
                          0.3 *
                              sin(
                                (x / waveLength * 4 * 3.14159) +
                                    (animationValue * 4 * 3.14159),
                              )));
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _WavePainter &&
        oldDelegate.animationValue != animationValue;
  }
}

/// Staggered fade-in animation for lists
class StaggeredFadeInAnimation extends StatelessWidget {
  final List<Widget> children;
  final Duration delay;
  final Duration duration;
  final Axis direction;

  const StaggeredFadeInAnimation({
    super.key,
    required this.children,
    this.delay = const Duration(milliseconds: 100),
    this.duration = const Duration(milliseconds: 300),
    this.direction = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    final animatedChildren = children.asMap().entries.map((entry) {
      final index = entry.key;
      final child = entry.value;
      final staggerDelay = delay * index;

      final slideOffset = direction == Axis.vertical
          ? const Offset(0, 0.3)
          : const Offset(0.3, 0);

      return child
          .animate()
          .fadeIn(duration: duration, delay: staggerDelay)
          .slideX(
            begin: slideOffset.dx,
            end: 0,
            duration: duration,
            delay: staggerDelay,
            curve: Curves.easeOutBack,
          )
          .slideY(
            begin: slideOffset.dy,
            end: 0,
            duration: duration,
            delay: staggerDelay,
            curve: Curves.easeOutBack,
          );
    }).toList();

    return direction == Axis.vertical
        ? Column(children: animatedChildren)
        : Row(children: animatedChildren);
  }
}

/// Gentle pulse animation for interactive elements
class PulseAnimation extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final double minOpacity;
  final double maxOpacity;

  const PulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 2),
    this.minOpacity = 0.6,
    this.maxOpacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .fade(
          begin: minOpacity,
          end: maxOpacity,
          duration: duration,
          curve: Curves.easeInOut,
        );
  }
}

/// Card reveal animation with enhanced effects
class CardRevealAnimation extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final bool isRevealed;

  const CardRevealAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.isRevealed = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isRevealed) {
      return child;
    }

    return child
        .animate()
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: duration,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: (duration.inMilliseconds * 0.6).ms)
        .shimmer(
          duration: (duration.inMilliseconds * 1.5).ms,
          color: AppTheme.softGold.withValues(alpha: 0.3),
        );
  }
}

/// Mystical glow effect for special elements
class MysticalGlowAnimation extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final double intensity;

  const MysticalGlowAnimation({
    super.key,
    required this.child,
    this.glowColor = AppTheme.primaryPurple,
    this.intensity = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .shimmer(
          duration: 2.seconds,
          color: glowColor.withValues(alpha: intensity),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .boxShadow(
          begin: BoxShadow(
            color: glowColor.withValues(alpha: 0.0),
            blurRadius: 0,
            spreadRadius: 0,
          ),
          end: BoxShadow(
            color: glowColor.withValues(alpha: intensity),
            blurRadius: 20,
            spreadRadius: 5,
          ),
          duration: 3.seconds,
          curve: Curves.easeInOut,
        );
  }
}
