import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/tarot_card.dart';
import '../utils/app_theme.dart';
import 'cached_card_image.dart';

/// Enum for different card sizes
enum CardSize {
  tiny(40, 63),
  small(80, 125),
  medium(120, 188),
  large(160, 250);

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
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        borderRadius: AppTheme.cardRadius,
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
          fit: StackFit.expand,
          children: [
            // Card back image - fills entire container
            Image.asset(
              'assets/images/card_back.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            // Subtle overlay for depth and consistency
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.05),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
