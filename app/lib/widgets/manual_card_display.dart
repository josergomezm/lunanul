import 'package:flutter/material.dart';
import '../models/manual_interpretation.dart';
import '../widgets/card_widget.dart';
import '../utils/constants.dart';

/// Widget for displaying selected cards in a manual interpretation
class ManualCardDisplay extends StatelessWidget {
  final List<ManualCardPosition> selectedCards;
  final Function(int)? onRemoveCard;
  final Function(int, String)? onUpdatePosition;
  final bool isLoading;

  const ManualCardDisplay({
    super.key,
    required this.selectedCards,
    this.onRemoveCard,
    this.onUpdatePosition,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedCards.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Text(
              'Selected Cards',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${selectedCards.length}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Cards list
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          )
        else
          ...selectedCards.asMap().entries.map((entry) {
            final index = entry.key;
            final cardPosition = entry.value;
            return _buildCardItem(context, cardPosition, index);
          }),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.style_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No cards selected',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose cards from your physical deck to get AI-enhanced interpretations',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardItem(
    BuildContext context,
    ManualCardPosition cardPosition,
    int index,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card header with position and actions
            Row(
              children: [
                // Position name (editable)
                Expanded(
                  child: GestureDetector(
                    onTap: onUpdatePosition != null
                        ? () => _showPositionEditDialog(
                            context,
                            cardPosition,
                            index,
                          )
                        : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            cardPosition.positionName,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                          ),
                          if (onUpdatePosition != null) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.edit,
                              size: 16,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Remove button
                if (onRemoveCard != null)
                  IconButton(
                    onPressed: () => onRemoveCard!(index),
                    icon: const Icon(Icons.close),
                    iconSize: 20,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Card and interpretation
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card image
                SizedBox(
                  width: 80,
                  height: 120,
                  child: CardWidget(
                    card: cardPosition.card,
                    size: CardSize.small,
                    showAnimation: false,
                  ),
                ),

                const SizedBox(width: 16),

                // Card details and interpretation
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card name
                      Text(
                        cardPosition.card.displayName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),

                      const SizedBox(height: 4),

                      // Card suit and keywords
                      Text(
                        '${cardPosition.card.suit.displayName} • ${cardPosition.card.keywords.take(3).join(', ')}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Card description
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          cardPosition.card.currentMeaning,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontStyle: FontStyle.italic,
                              ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPositionEditDialog(
    BuildContext context,
    ManualCardPosition cardPosition,
    int index,
  ) {
    final controller = TextEditingController(text: cardPosition.positionName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Position Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Position Name',
            hintText: 'e.g., Past, Present, Future',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && onUpdatePosition != null) {
                onUpdatePosition!(index, newName);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

/// Widget for displaying interpretations separately from card selection
class InterpretationDisplay extends StatelessWidget {
  final List<ManualCardPosition> selectedCards;
  final bool isLoading;

  const InterpretationDisplay({
    super.key,
    required this.selectedCards,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Only show if there are cards with interpretations
    final cardsWithInterpretations = selectedCards
        .where((card) => card.interpretation.isNotEmpty)
        .toList();

    if (cardsWithInterpretations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(
              Icons.auto_awesome,
              color: Theme.of(context).colorScheme.secondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Interpretations', // TODO: Use localizations when available
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${cardsWithInterpretations.length}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Interpretations list
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          )
        else
          ...cardsWithInterpretations.map((cardPosition) {
            return _buildInterpretationItem(context, cardPosition);
          }),
      ],
    );
  }

  Widget _buildInterpretationItem(
    BuildContext context,
    ManualCardPosition cardPosition,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Position and card name header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    cardPosition.positionName,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    cardPosition.card.displayName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Interpretation text
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                cardPosition.interpretation,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact horizontal display of selected cards
class CompactCardDisplay extends StatelessWidget {
  final List<ManualCardPosition> selectedCards;
  final Function(int)? onCardTap;

  const CompactCardDisplay({
    super.key,
    required this.selectedCards,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedCards.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: selectedCards.length,
        itemBuilder: (context, index) {
          final cardPosition = selectedCards[index];
          return GestureDetector(
            onTap: onCardTap != null ? () => onCardTap!(index) : null,
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 8),
              child: Column(
                children: [
                  // Card image
                  Expanded(
                    child: CardWidget(
                      card: cardPosition.card,
                      size: CardSize.tiny,
                      showAnimation: false,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Position name
                  Text(
                    cardPosition.positionName,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
