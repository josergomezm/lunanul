import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/manual_interpretation.dart';
import '../models/tarot_card.dart';
import '../models/enums.dart';
import '../services/manual_interpretation_service.dart';
import '../services/card_service.dart';

/// Provider for manual interpretation service
final manualInterpretationServiceProvider =
    Provider<ManualInterpretationService>((ref) {
      return ManualInterpretationService.instance;
    });

/// State for the current manual interpretation session
class ManualInterpretationState {
  final ReadingTopic? selectedTopic;
  final List<ManualCardPosition> selectedCards;
  final List<TarotCard> availableCards;
  final bool isLoading;
  final String? error;
  final List<CardConnection> connections;
  final bool isSearching;
  final String searchQuery;

  const ManualInterpretationState({
    this.selectedTopic,
    this.selectedCards = const [],
    this.availableCards = const [],
    this.isLoading = false,
    this.error,
    this.connections = const [],
    this.isSearching = false,
    this.searchQuery = '',
  });

  ManualInterpretationState copyWith({
    ReadingTopic? selectedTopic,
    List<ManualCardPosition>? selectedCards,
    List<TarotCard>? availableCards,
    bool? isLoading,
    String? error,
    List<CardConnection>? connections,
    bool? isSearching,
    String? searchQuery,
  }) {
    return ManualInterpretationState(
      selectedTopic: selectedTopic ?? this.selectedTopic,
      selectedCards: selectedCards ?? this.selectedCards,
      availableCards: availableCards ?? this.availableCards,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      connections: connections ?? this.connections,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool get hasSelectedCards => selectedCards.isNotEmpty;
  bool get canGenerateInterpretation =>
      selectedTopic != null && hasSelectedCards;
  bool get hasConnections => connections.isNotEmpty;
}

/// Notifier for managing manual interpretation state
class ManualInterpretationNotifier
    extends StateNotifier<ManualInterpretationState> {
  ManualInterpretationNotifier(this._service, this._cardService)
    : super(const ManualInterpretationState()) {
    _loadAvailableCards();
  }

  final ManualInterpretationService _service;
  final CardService _cardService;

  /// Load all available cards
  Future<void> _loadAvailableCards() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final cards = await _cardService.getAllCards();
      state = state.copyWith(availableCards: cards, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load cards: $e',
        isLoading: false,
      );
    }
  }

  /// Select a topic for the interpretation
  void selectTopic(ReadingTopic topic) {
    state = state.copyWith(selectedTopic: topic);
  }

  /// Add a card to the interpretation
  Future<void> addCard(
    TarotCard card, {
    String? customPosition,
    bool isReversed = false,
  }) async {
    if (state.selectedTopic == null) return;

    try {
      state = state.copyWith(isLoading: true, error: null);

      // Apply reversed orientation to the card
      final orientedCard = card.copyWith(isReversed: isReversed);

      // Determine position name
      final currentCount = state.selectedCards.length;
      final suggestedPositions = _service.getSuggestedPositions(
        currentCount + 1,
      );
      final positionName =
          customPosition ??
          (currentCount < suggestedPositions.length
              ? suggestedPositions[currentCount]
              : 'Position ${currentCount + 1}');

      // Generate interpretation
      final interpretation = await _service.generateInterpretation(
        card: orientedCard,
        topic: state.selectedTopic!,
        positionName: positionName,
      );

      // Create new card position
      final cardPosition = ManualCardPosition(
        card: orientedCard,
        positionName: positionName,
        interpretation: interpretation,
        order: currentCount,
      );

      // Add to selected cards
      final updatedCards = [...state.selectedCards, cardPosition];

      // Analyze connections
      final connections = _service.analyzeCardConnections(updatedCards);

      state = state.copyWith(
        selectedCards: updatedCards,
        connections: connections,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to add card: $e', isLoading: false);
    }
  }

  /// Remove a card from the interpretation
  void removeCard(int index) {
    if (index < 0 || index >= state.selectedCards.length) return;

    final updatedCards = [...state.selectedCards];
    updatedCards.removeAt(index);

    // Update order for remaining cards
    for (int i = 0; i < updatedCards.length; i++) {
      updatedCards[i] = updatedCards[i].copyWith(order: i);
    }

    // Recalculate connections
    final connections = _service.analyzeCardConnections(updatedCards);

    state = state.copyWith(
      selectedCards: updatedCards,
      connections: connections,
    );
  }

  /// Update position name for a card
  Future<void> updateCardPosition(int index, String newPositionName) async {
    if (index < 0 ||
        index >= state.selectedCards.length ||
        state.selectedTopic == null) {
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final cardPosition = state.selectedCards[index];

      // Regenerate interpretation with new position
      final newInterpretation = await _service.generateInterpretation(
        card: cardPosition.card,
        topic: state.selectedTopic!,
        positionName: newPositionName,
      );

      // Update the card position
      final updatedCards = [...state.selectedCards];
      updatedCards[index] = cardPosition.copyWith(
        positionName: newPositionName,
        interpretation: newInterpretation,
      );

      // Recalculate connections
      final connections = _service.analyzeCardConnections(updatedCards);

      state = state.copyWith(
        selectedCards: updatedCards,
        connections: connections,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update position: $e',
        isLoading: false,
      );
    }
  }

  /// Search cards by query
  Future<void> searchCards(String query) async {
    try {
      print('DEBUG: Searching for: "$query"'); // Debug print
      state = state.copyWith(isSearching: true, searchQuery: query);

      List<TarotCard> filteredCards;
      if (query.trim().isEmpty) {
        // If query is empty, show all cards
        filteredCards = await _cardService.getAllCards();
        print(
          'DEBUG: Empty query, showing ${filteredCards.length} cards',
        ); // Debug print
      } else {
        // Search with the query
        filteredCards = await _cardService.searchCards(query.trim());
        print(
          'DEBUG: Search found ${filteredCards.length} cards',
        ); // Debug print
      }

      state = state.copyWith(availableCards: filteredCards, isSearching: false);
    } catch (e) {
      print('DEBUG: Search error: $e'); // Debug print
      state = state.copyWith(error: 'Search failed: $e', isSearching: false);
    }
  }

  /// Clear search and show all cards
  Future<void> clearSearch() async {
    state = state.copyWith(searchQuery: '', isSearching: true);
    await _loadAvailableCards();
  }

  /// Filter cards by suit
  Future<void> filterBySuit(TarotSuit? suit) async {
    try {
      print('DEBUG: Filtering by suit: ${suit?.name ?? "all"}'); // Debug print
      state = state.copyWith(isLoading: true);

      List<TarotCard> filteredCards;
      if (suit == null) {
        // Show all cards, but apply current search if any
        if (state.searchQuery.trim().isNotEmpty) {
          filteredCards = await _cardService.searchCards(
            state.searchQuery.trim(),
          );
          print(
            'DEBUG: All cards with search "${state.searchQuery}": ${filteredCards.length}',
          ); // Debug print
        } else {
          filteredCards = await _cardService.getAllCards();
          print('DEBUG: All cards: ${filteredCards.length}'); // Debug print
        }
      } else {
        // Filter by suit first, then apply search if any
        filteredCards = await _cardService.getCardsBySuit(suit);
        print(
          'DEBUG: Cards for suit ${suit.name}: ${filteredCards.length}',
        ); // Debug print
        if (state.searchQuery.trim().isNotEmpty) {
          final query = state.searchQuery.trim().toLowerCase();
          filteredCards = filteredCards.where((card) {
            return card.name.toLowerCase().contains(query) ||
                card.keywords.any(
                  (keyword) => keyword.toLowerCase().contains(query),
                ) ||
                card.uprightMeaning.toLowerCase().contains(query) ||
                card.reversedMeaning.toLowerCase().contains(query);
          }).toList();
          print(
            'DEBUG: Cards after search filter: ${filteredCards.length}',
          ); // Debug print
        }
      }

      state = state.copyWith(availableCards: filteredCards, isLoading: false);
    } catch (e) {
      print('DEBUG: Filter error: $e'); // Debug print
      state = state.copyWith(error: 'Filter failed: $e', isLoading: false);
    }
  }

  /// Clear all selected cards and start over
  void clearSelection() {
    state = state.copyWith(
      selectedCards: [],
      connections: [],
      selectedTopic: null,
    );
  }

  /// Create a manual interpretation from current state
  ManualInterpretation? createInterpretation() {
    if (!state.canGenerateInterpretation) return null;

    return ManualInterpretation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      topic: state.selectedTopic!,
      selectedCards: state.selectedCards,
    );
  }

  /// Clear any error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for manual interpretation state
final manualInterpretationProvider =
    StateNotifierProvider<
      ManualInterpretationNotifier,
      ManualInterpretationState
    >((ref) {
      final service = ref.watch(manualInterpretationServiceProvider);
      final cardService = CardService.instance;
      return ManualInterpretationNotifier(service, cardService);
    });

/// Provider for saved manual interpretations
final savedManualInterpretationsProvider =
    FutureProvider<List<ManualInterpretation>>((ref) async {
      final service = ref.watch(manualInterpretationServiceProvider);
      return service.getSavedInterpretations();
    });
