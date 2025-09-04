import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/enums.dart';
import '../models/card_position.dart';
import '../utils/app_theme.dart';
import 'card_widget.dart';

/// A widget that displays tarot cards in different spread layouts
class ReadingSpreadWidget extends StatelessWidget {
  final SpreadType spreadType;
  final List<CardPosition> cards;
  final Function(int)? onCardTapped;
  final bool showPositionLabels;
  final bool enableCardInteraction;
  final double cardWidth;
  final double cardHeight;

  const ReadingSpreadWidget({
    super.key,
    required this.spreadType,
    required this.cards,
    this.onCardTapped,
    this.showPositionLabels = true,
    this.enableCardInteraction = true,
    this.cardWidth = 100,
    this.cardHeight = 160,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (showPositionLabels) ...[
            Text(
              spreadType.displayName,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              spreadType.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
          ],
          Expanded(child: _buildSpreadLayout(context)),
        ],
      ),
    );
  }

  Widget _buildSpreadLayout(BuildContext context) {
    switch (spreadType) {
      case SpreadType.singleCard:
        return _buildSingleCardLayout();
      case SpreadType.threeCard:
        return _buildThreeCardLayout();
      case SpreadType.celtic:
      case SpreadType.celticCross:
        return _buildCelticCrossLayout(context);
      case SpreadType.relationship:
        return _buildRelationshipLayout();
      case SpreadType.career:
        return _buildCareerLayout();
      case SpreadType.horseshoe:
        return _buildHorseshoeLayout();
    }
  }

  Widget _buildSingleCardLayout() {
    if (cards.isEmpty) return const SizedBox.shrink();
    return Center(child: _buildAnimatedCard(0));
  }

  Widget _buildThreeCardLayout() {
    if (cards.length < 3) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCardWithLabel(0, 'Past'),
        _buildCardWithLabel(1, 'Present'),
        _buildCardWithLabel(2, 'Future'),
      ],
    );
  }

  Widget _buildCelticCrossLayout(BuildContext context) {
    if (cards.length < 10) return const SizedBox.shrink();
    return Stack(
      children: [
        Positioned(
          left: MediaQuery.of(context).size.width * 0.3,
          top: MediaQuery.of(context).size.height * 0.15,
          child: _buildCardWithLabel(0, 'Present'),
        ),
        // Add other positions...
      ],
    );
  }

  Widget _buildRelationshipLayout() {
    if (cards.length < 5) return const SizedBox.shrink();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCardWithLabel(0, 'You'),
            _buildCardWithLabel(1, 'Them'),
          ],
        ),
        const SizedBox(height: 20),
        _buildCardWithLabel(2, 'Connection'),
      ],
    );
  }

  Widget _buildCareerLayout() {
    if (cards.length < 7) return const SizedBox.shrink();
    return Column(
      children: [
        _buildCardWithLabel(0, 'Current Situation'),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCardWithLabel(1, 'Strengths'),
            _buildCardWithLabel(2, 'Challenges'),
          ],
        ),
      ],
    );
  }

  Widget _buildHorseshoeLayout() {
    if (cards.length < 7) return const SizedBox.shrink();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCardWithLabel(0, 'Past'),
            _buildCardWithLabel(1, 'Present'),
            _buildCardWithLabel(2, 'Future'),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCardWithLabel(3, 'Foundation'),
            _buildCardWithLabel(4, 'Challenges'),
            _buildCardWithLabel(5, 'Guidance'),
          ],
        ),
        const SizedBox(height: 16),
        _buildCardWithLabel(6, 'Outcome'),
      ],
    );
  }

  Widget _buildCardWithLabel(int index, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showPositionLabels) ...[
          Text(
            label,
            style: TextStyle(
              color: AppTheme.primaryPurple,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
        ],
        _buildAnimatedCard(index),
      ],
    );
  }

  Widget _buildAnimatedCard(int index) {
    if (index >= cards.length) {
      return SizedBox(width: cardWidth, height: cardHeight);
    }

    return CardWidget.legacy(
          card: cards[index].card,
          width: cardWidth,
          height: cardHeight,
          onTap: enableCardInteraction && onCardTapped != null
              ? () => onCardTapped!(index)
              : null,
          enableFlipAnimation: false,
        )
        .animate()
        .fadeIn(duration: AppTheme.mediumAnimation, delay: (index * 150).ms)
        .slideY(
          begin: 0.5,
          end: 0,
          duration: AppTheme.mediumAnimation,
          delay: (index * 150).ms,
          curve: Curves.easeOutBack,
        );
  }
}

/// Compact version for displaying completed readings
class CompactReadingSpreadWidget extends StatelessWidget {
  final SpreadType spreadType;
  final List<CardPosition> cards;
  final Function(int)? onCardTapped;
  final double cardSize;

  const CompactReadingSpreadWidget({
    super.key,
    required this.spreadType,
    required this.cards,
    this.onCardTapped,
    this.cardSize = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: _buildCompactLayout(),
    );
  }

  Widget _buildCompactLayout() {
    if (cards.isEmpty) return const SizedBox.shrink();

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 96, // Minimum height for card display
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: cards.take(3).map((cardPosition) {
            final index = cards.indexOf(cardPosition);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: CardWidget.legacy(
                card: cardPosition.card,
                width: cardSize,
                height: cardSize * 1.6,
                onTap: onCardTapped != null ? () => onCardTapped!(index) : null,
                enableFlipAnimation: false,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
