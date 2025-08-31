import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/tarot_card.dart';
import '../utils/app_theme.dart';
import 'cached_card_image.dart';

/// Enum for different card sizes
enum CardSize {
  tiny(40, 60),
  small(80, 120),
  medium(120, 200),
  large(160, 260);

  const CardSize(this.width, this.height);
  final double width;
  final double height;
}

/// A reusable widget for displaying tarot cards with flip animations and image caching
class CardWidget extends StatelessWidget {
  final TarotCard card;
  final bool isRevealed;
  final VoidCallback? onTap;
  final CardSize size;
  final bool showMeaning;
  final bool enableFlipAnimation;
  final bool showAnimation;

  const CardWidget({
    super.key,
    required this.card,
    this.isRevealed = true,
    this.onTap,
    this.size = CardSize.medium,
    this.showMeaning = false,
    this.enableFlipAnimation = true,
    this.showAnimation = true,
  });

  // Legacy constructor for backward compatibility
  const CardWidget.legacy({
    super.key,
    required this.card,
    this.isRevealed = true,
    this.onTap,
    double width = 120,
    double height = 200,
    this.showMeaning = false,
    this.enableFlipAnimation = true,
    this.showAnimation = true,
  }) : size = CardSize.medium;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: enableFlipAnimation ? _buildAnimatedCard() : _buildStaticCard(),
      ),
    );
  }

  Widget _buildAnimatedCard() {
    if (isRevealed) {
      return _buildCardFront()
          .animate()
          .flip(
            duration: AppTheme.longAnimation,
            curve: Curves.easeInOut,
            perspective: 0.001,
          )
          .scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1.0, 1.0),
            duration: AppTheme.mediumAnimation,
            curve: Curves.elasticOut,
          )
          .shimmer(
            duration: AppTheme.extraLongAnimation,
            color: AppTheme.softGold.withValues(alpha: 0.3),
          );
    } else {
      return _buildCardBack().animate().scale(
        begin: const Offset(1.0, 1.0),
        end: const Offset(0.98, 0.98),
        duration: AppTheme.shortAnimation,
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildStaticCard() {
    return (isRevealed ? _buildCardFront() : _buildCardBack())
        .animate()
        .fadeIn(duration: AppTheme.shortAnimation)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1.0, 1.0),
          duration: AppTheme.mediumAnimation,
          curve: Curves.easeOut,
        );
  }

  Widget _buildCardFront() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppTheme.cardRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.white.withValues(alpha: 0.95)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppTheme.cardRadius,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // Main card image
                  CachedCardImage(
                    card: card,
                    width: size.width,
                    height: size.height - (showMeaning ? 60 : 0),
                    fit: BoxFit.cover,
                    fadeInDuration: AppTheme.mediumAnimation,
                    enableProgressiveLoading: true,
                  ),
                  // Subtle overlay for depth
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (showMeaning)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryPurple,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    Text(
                      card.currentMeaning,
                      style: TextStyle(
                        height: 1.3,
                        color: AppTheme.darkGray.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppTheme.cardRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryPurple,
            AppTheme.mysticPurple,
            AppTheme.deepBlue,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppTheme.cardRadius,
        child: Stack(
          children: [
            // Animated background pattern
            Positioned.fill(
              child: CustomPaint(painter: _EnhancedCardBackPainter()),
            ),
            // Subtle shimmer effect
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: AppTheme.cardRadius,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ),
            // Center celestial icon with glow
            Center(
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Icon(
                  Icons.nights_stay,
                  size: size.width * 0.3,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),
            // Corner decorative elements
            Positioned(
              top: AppTheme.spacingS,
              left: AppTheme.spacingS,
              child: Icon(
                Icons.star,
                size: 12,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            Positioned(
              top: AppTheme.spacingS,
              right: AppTheme.spacingS,
              child: Icon(
                Icons.star,
                size: 8,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
            Positioned(
              bottom: AppTheme.spacingS,
              left: AppTheme.spacingS,
              child: Icon(
                Icons.star,
                size: 10,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            Positioned(
              bottom: AppTheme.spacingS,
              right: AppTheme.spacingS,
              child: Icon(
                Icons.star,
                size: 14,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Enhanced custom painter for the card back decorative pattern
class _EnhancedCardBackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    // Draw outer decorative border
    final outerBorderRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        AppTheme.spacingS,
        AppTheme.spacingS,
        size.width - (AppTheme.spacingS * 2),
        size.height - (AppTheme.spacingS * 2),
      ),
      const Radius.circular(12),
    );
    canvas.drawRRect(outerBorderRect, paint);

    // Draw inner decorative border
    final innerBorderRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        AppTheme.spacingM,
        AppTheme.spacingM,
        size.width - (AppTheme.spacingM * 2),
        size.height - (AppTheme.spacingM * 2),
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(innerBorderRect, paint);

    // Draw mystical geometric patterns
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width * 0.15;

    // Draw hexagon pattern
    final hexagonPath = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * (3.14159 / 180);
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);

      if (i == 0) {
        hexagonPath.moveTo(x, y);
      } else {
        hexagonPath.lineTo(x, y);
      }
    }
    hexagonPath.close();

    canvas.drawPath(hexagonPath, fillPaint);
    canvas.drawPath(hexagonPath, paint);

    // Draw connecting lines from corners to center
    final cornerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 0.8;

    final corners = [
      Offset(AppTheme.spacingM, AppTheme.spacingM),
      Offset(size.width - AppTheme.spacingM, AppTheme.spacingM),
      Offset(AppTheme.spacingM, size.height - AppTheme.spacingM),
      Offset(size.width - AppTheme.spacingM, size.height - AppTheme.spacingM),
    ];

    for (final corner in corners) {
      canvas.drawLine(corner, Offset(centerX, centerY), cornerPaint);
    }

    // Draw small circles at corners
    final circlePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    for (final corner in corners) {
      canvas.drawCircle(corner, 3, circlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
