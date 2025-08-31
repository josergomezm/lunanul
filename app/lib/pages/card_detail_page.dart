import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tarot_card.dart';
import '../models/enums.dart';
import '../utils/constants.dart';
import '../widgets/card_widget.dart';

/// Detailed view of a single tarot card with full meanings and information
class CardDetailPage extends ConsumerWidget {
  final TarotCard card;

  const CardDetailPage({super.key, required this.card});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(card.name), centerTitle: true, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card image and basic info
              _buildCardHeader(context),

              const SizedBox(height: 24),

              // Keywords section
              _buildKeywordsSection(context),

              const SizedBox(height: 24),

              // Upright meaning section
              _buildMeaningSection(
                context,
                'Upright Meaning',
                card.uprightMeaning,
                Icons.arrow_upward,
                Colors.green,
              ),

              const SizedBox(height: 24),

              // Reversed meaning section
              _buildMeaningSection(
                context,
                'Reversed Meaning',
                card.reversedMeaning,
                Icons.arrow_downward,
                Colors.orange,
              ),

              const SizedBox(height: 24),

              // Card details section
              _buildCardDetailsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card image
        SizedBox(
          width: 120,
          child: CardWidget(card: card, size: CardSize.large),
        ),

        const SizedBox(width: 20),

        // Card basic info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              _buildInfoChip(
                context,
                card.isMajorArcana ? 'Major Arcana' : 'Minor Arcana',
                card.isMajorArcana ? Colors.purple : Colors.blue,
              ),

              const SizedBox(height: 8),

              if (!card.isMajorArcana) ...[
                _buildInfoChip(
                  context,
                  card.suit.displayName,
                  _getSuitColor(card.suit),
                ),
                const SizedBox(height: 8),
              ],

              if (card.number != null) ...[
                _buildInfoChip(
                  context,
                  card.isCourtCard ? 'Court Card' : 'Number ${card.number}',
                  Colors.grey,
                ),
              ] else if (card.isMajorArcana) ...[
                _buildInfoChip(context, 'Trump Card', Colors.grey),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getSuitColor(TarotSuit suit) {
    switch (suit) {
      case TarotSuit.cups:
        return Colors.blue;
      case TarotSuit.wands:
        return Colors.red;
      case TarotSuit.swords:
        return Colors.grey;
      case TarotSuit.pentacles:
        return Colors.green;
      case TarotSuit.majorArcana:
        return Colors.purple;
    }
  }

  Widget _buildKeywordsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Keywords',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: card.keywords
              .map(
                (keyword) => Chip(
                  label: Text(
                    keyword,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildMeaningSection(
    BuildContext context,
    String title,
    String meaning,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              meaning,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardDetailsSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Card Details',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            _buildDetailRow(context, 'Card ID', card.id),
            _buildDetailRow(context, 'Suit', card.suit.displayName),
            if (card.number != null)
              _buildDetailRow(context, 'Number', card.number.toString()),
            _buildDetailRow(context, 'Type', _getCardType()),
            _buildDetailRow(
              context,
              'Arcana',
              card.isMajorArcana ? 'Major' : 'Minor',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  String _getCardType() {
    if (card.isMajorArcana) {
      return 'Major Arcana';
    } else if (card.isCourtCard) {
      return 'Court Card';
    } else {
      return 'Pip Card';
    }
  }
}
