import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tarot_card.dart';
import '../models/enums.dart';
import '../widgets/card_widget.dart';
import '../utils/constants.dart';
import '../l10n/generated/app_localizations.dart';
import '../providers/language_provider.dart';

/// Widget for displaying a searchable grid of tarot cards for selection
class CardSelectionGrid extends ConsumerStatefulWidget {
  final List<TarotCard> cards;
  final Function(TarotCard, {bool isReversed}) onCardSelected;
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
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(CardSelectionGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update search controller if the search query changed externally
    if (widget.searchQuery != oldWidget.searchQuery &&
        _searchController.text != widget.searchQuery) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    widget.onSearchChanged(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final locale = ref.watch(languageProvider);
    final dynamicLocalizations = ref.read(dynamicContentLocalizationsProvider);
    return Column(
      children: [
        // Search and filter section
        _buildSearchAndFilter(localizations, locale, dynamicLocalizations),
        const SizedBox(height: 16),

        // Cards grid
        Expanded(
          child: widget.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildCardsGrid(localizations),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter(
    AppLocalizations localizations,
    Locale locale,
    dynamic dynamicLocalizations,
  ) {
    return Column(
      children: [
        // Search bar
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: localizations.searchCardsHint,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged();
                    },
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

        const SizedBox(height: 12),

        // Suit filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: Text(localizations.allCards),
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
                    label: Text(
                      dynamicLocalizations.getTarotSuitDisplayName(
                        suit,
                        locale,
                      ),
                    ),
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

  Widget _buildCardsGrid(AppLocalizations localizations) {
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
              localizations.noCardsFound,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              localizations.tryAdjustingSearch,
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
      onTap: () => _showCardOrientationDialog(card),
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

  void _showCardOrientationDialog(TarotCard card) {
    final localizations = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.selectCardOrientation),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              card.name,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Text(localizations.chooseCardPosition),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onCardSelected(card, isReversed: false);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_upward, size: 16),
                const SizedBox(width: 4),
                Text(localizations.upright),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onCardSelected(card, isReversed: true);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_downward, size: 16),
                const SizedBox(width: 4),
                Text(localizations.reversed),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog for selecting cards from the full deck
class CardSelectionDialog extends ConsumerWidget {
  final Function(TarotCard, {bool isReversed}) onCardSelected;

  const CardSelectionDialog({super.key, required this.onCardSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);

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
                  localizations.selectCard,
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
                onCardSelected: (card, {bool isReversed = false}) {
                  onCardSelected(card, isReversed: isReversed);
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
