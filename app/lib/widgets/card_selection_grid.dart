import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tarot_card.dart';
import '../models/enums.dart';
import '../widgets/card_widget.dart';
import '../utils/constants.dart';

/// Widget for displaying a searchable grid of tarot cards for selection
class CardSelectionGrid extends ConsumerStatefulWidget {
  final List<TarotCard> cards;
  final Function(TarotCard) onCardSelected;
  final bool isLoading;
  final String searchQuery;
  final Function(String) onSearchChanged;
  final Function(TarotSuit?) onSuitFilter;

  const CardSelectionGrid({
    super.key,
    required this.cards,
    required this.onCardSelected,
    this.isLoading = false,
    this.searchQuery = '',
    required this.onSearchChanged,
    required this.onSuitFilter,
  });

  @override
  ConsumerState<CardSelectionGrid> createState() => _CardSelectionGridState();
}

class _CardSelectionGridState extends ConsumerState<CardSelectionGrid> {
  final TextEditingController _searchController = TextEditingController();
  TarotSuit? _selectedSuit;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search and filter section
        _buildSearchAndFilter(),
        const SizedBox(height: 16),

        // Cards grid
        Expanded(
          child: widget.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildCardsGrid(),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Column(
      children: [
        // Search bar
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search cards by name or keywords...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      widget.onSearchChanged('');
                    },
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: widget.onSearchChanged,
        ),

        const SizedBox(height: 12),

        // Suit filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: const Text('All'),
                selected: _selectedSuit == null,
                onSelected: (selected) {
                  setState(() {
                    _selectedSuit = null;
                  });
                  widget.onSuitFilter(null);
                },
              ),
              const SizedBox(width: 8),
              ...TarotSuit.values.map(
                (suit) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(suit.displayName),
                    selected: _selectedSuit == suit,
                    onSelected: (selected) {
                      setState(() {
                        _selectedSuit = selected ? suit : null;
                      });
                      widget.onSuitFilter(selected ? suit : null);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardsGrid() {
    if (widget.cards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No cards found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filter',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: widget.cards.length,
      itemBuilder: (context, index) {
        final card = widget.cards[index];
        return _buildSelectableCard(card);
      },
    );
  }

  Widget _buildSelectableCard(TarotCard card) {
    return GestureDetector(
      onTap: () => widget.onCardSelected(card),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            // Card image
            Expanded(
              flex: 4,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                child: CardWidget(
                  card: card,
                  size: CardSize.small,
                  showAnimation: false,
                ),
              ),
            ),

            // Card name
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(8),
                  ),
                ),
                child: Center(
                  child: Text(
                    card.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog for selecting cards from the full deck
class CardSelectionDialog extends ConsumerWidget {
  final Function(TarotCard) onCardSelected;

  const CardSelectionDialog({super.key, required this.onCardSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Select a Card',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Card selection grid
            Expanded(
              child: CardSelectionGrid(
                cards: const [], // Will be populated by provider
                onCardSelected: (card) {
                  onCardSelected(card);
                  Navigator.of(context).pop();
                },
                onSearchChanged: (query) {
                  // Handle search through provider
                },
                onSuitFilter: (suit) {
                  // Handle filter through provider
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
