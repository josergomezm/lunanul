import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/card_provider.dart';
import '../models/tarot_card.dart';
import '../models/enums.dart';
import '../utils/constants.dart';
import '../widgets/card_widget.dart';
import 'card_detail_page.dart';

/// Card encyclopedia page with searchable interface for all 78 tarot cards
class CardEncyclopediaPage extends ConsumerStatefulWidget {
  const CardEncyclopediaPage({super.key});

  @override
  ConsumerState<CardEncyclopediaPage> createState() =>
      _CardEncyclopediaPageState();
}

class _CardEncyclopediaPageState extends ConsumerState<CardEncyclopediaPage> {
  String _searchQuery = '';
  TarotSuit? _selectedSuit;
  bool _showReversedMeanings = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allCardsAsync = ref.watch(allCardsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Encyclopedia'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _showReversedMeanings ? Icons.flip_to_back : Icons.flip_to_front,
            ),
            onPressed: () {
              setState(() {
                _showReversedMeanings = !_showReversedMeanings;
              });
            },
            tooltip: _showReversedMeanings
                ? 'Show upright meanings'
                : 'Show reversed meanings',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search and filter section
            _buildSearchAndFilter(context),

            // Cards grid
            Expanded(
              child: allCardsAsync.when(
                data: (cards) => _buildCardsGrid(context, cards),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => _buildErrorState(context, error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search cards by name or keywords...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),

          const SizedBox(height: 12),

          // Suit filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All Suits'),
                  selected: _selectedSuit == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSuit = null;
                    });
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
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardsGrid(BuildContext context, List<TarotCard> cards) {
    // Filter cards based on search and suit
    final filteredCards = cards.where((card) {
      // Suit filter
      if (_selectedSuit != null && card.suit != _selectedSuit) {
        return false;
      }

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return card.name.toLowerCase().contains(query) ||
            card.keywords.any((k) => k.toLowerCase().contains(query)) ||
            card.uprightMeaning.toLowerCase().contains(query) ||
            card.reversedMeaning.toLowerCase().contains(query);
      }

      return true;
    }).toList();

    // Sort cards: Major Arcana first, then by suit and number
    filteredCards.sort((a, b) {
      if (a.isMajorArcana && !b.isMajorArcana) return -1;
      if (!a.isMajorArcana && b.isMajorArcana) return 1;

      if (a.isMajorArcana && b.isMajorArcana) {
        return (a.number ?? 0).compareTo(b.number ?? 0);
      }

      // Minor Arcana: sort by suit, then by number
      final suitComparison = a.suit.index.compareTo(b.suit.index);
      if (suitComparison != 0) return suitComparison;

      return (a.number ?? 0).compareTo(b.number ?? 0);
    });

    if (filteredCards.isEmpty) {
      return _buildEmptyState(context);
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: filteredCards.length,
      itemBuilder: (context, index) {
        final card = filteredCards[index];
        return _buildCardItem(context, card);
      },
    );
  }

  Widget _buildCardItem(BuildContext context, TarotCard card) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToCardDetail(context, card),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card image
              Expanded(
                flex: 3,
                child: Center(
                  child: CardWidget(card: card, size: CardSize.medium),
                ),
              ),

              const SizedBox(height: 8),

              // Card name
              Text(
                card.name,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Suit and number
              Text(
                _getCardSubtitle(card),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),

              const SizedBox(height: 4),

              // Keywords or meaning preview
              Expanded(
                child: Text(
                  _showReversedMeanings
                      ? card.reversedMeaning
                      : card.uprightMeaning,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCardSubtitle(TarotCard card) {
    if (card.isMajorArcana) {
      return 'Major Arcana ${card.number ?? ''}';
    } else {
      final numberText = card.number != null ? card.number.toString() : 'Court';
      return '$numberText of ${card.suit.displayName}';
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
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
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
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

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load cards',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(allCardsProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCardDetail(BuildContext context, TarotCard card) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => CardDetailPage(card: card)));
  }
}
