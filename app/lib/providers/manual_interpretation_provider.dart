import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/manual_interpretation.dart';
import '../models/tarot_card.dart';
import '../models/enums.dart';
import '../services/manual_interpretation_service.dart';
import '../services/card_service.dart';
import 'feature_gate_provider.dart';

/// Provider for manual interpretation service
final manualInterpretationServiceProvider =
    Provider<ManualInterpretationService>((ref) {
      return ManualInterpretationService.instance;
    });

/// State for the current manual interpretation session
class ManualInterpretationState {
  final ReadingTopic? selectedTopic;
  final GuideType? selectedGuide;
  final List<ManualCardPosition> selectedCards;
  final List<TarotCard> availableCards;
  final bool isLoading;
  final String? error;
  final List<CardConnection> connections;
  final bool isSearching;
  final String searchQuery;
  final bool hasRequestedInterpretation;

  const ManualInterpretationState({
    this.selectedTopic,
    this.selectedGuide,
    this.selectedCards = const [],
    this.availableCards = const [],
    this.isLoading = false,
    this.error,
    this.connections = const [],
    this.isSearching = false,
    this.searchQuery = '',
    this.hasRequestedInterpretation = false,
  });

  ManualInterpretationState copyWith({
    ReadingTopic? selectedTopic,
    GuideType? selectedGuide,
    List<ManualCardPosition>? selectedCards,
    List<TarotCard>? availableCards,
    bool? isLoading,
    String? error,
    List<CardConnection>? connections,
    bool? isSearching,
    String? searchQuery,
    bool? hasRequestedInterpretation,
  }) {
    return ManualInterpretationState(
      selectedTopic: selectedTopic ?? this.selectedTopic,
      selectedGuide: selectedGuide ?? this.selectedGuide,
      selectedCards: selectedCards ?? this.selectedCards,
      availableCards: availableCards ?? this.availableCards,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      connections: connections ?? this.connections,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      hasRequestedInterpretation:
          hasRequestedInterpretation ?? this.hasRequestedInterpretation,
    );
  }

  bool get hasSelectedCards {
    try {
      return selectedCards.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  bool get canGenerateInterpretation {
    try {
      return selectedTopic != null && hasSelectedCards;
    } catch (e) {
      return false;
    }
  }

  bool get hasConnections {
    try {
      return connections.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  bool get hasCardsWithoutInterpretation {
    try {
      return selectedCards.any((card) => card.interpretation.isEmpty);
    } catch (e) {
      return false;
    }
  }

  bool get canInterpretCards {
    try {
      return selectedTopic != null && hasSelectedCards;
    } catch (e) {
      return false;
    }
  }

  bool get shouldShowInterpretations {
    try {
      return (hasRequestedInterpretation == true) &&
          selectedCards.any((card) => card.interpretation.isNotEmpty);
    } catch (e) {
      return false;
    }
  }
}

/// Notifier for managing manual interpretation state
class ManualInterpretationNotifier
    extends StateNotifier<ManualInterpretationState> {
  ManualInterpretationNotifier(this._service, this._cardService, this._ref)
    : super(const ManualInterpretationState()) {
    _loadAvailableCards();
  }

  final ManualInterpretationService _service;
  final CardService _cardService;
  final Ref _ref;

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

  /// Select a guide for the interpretation
  void selectGuide(GuideType? guide) {
    state = state.copyWith(selectedGuide: guide);
  }

  /// Check if user can perform manual interpretation and consume usage
  Future<bool> validateManualInterpretationUsage() async {
    try {
      // Use the feature gate service to validate and consume usage
      final featureGateNotifier = _ref.read(
        featureGateNotifierProvider.notifier,
      );
      return await featureGateNotifier.validateAndConsumeUsage(
        'manual_interpretations',
      );
    } catch (e) {
      return false;
    }
  }

  /// Add a card to the interpretation without generating interpretation
  void addCardWithoutInterpretation(
    TarotCard card, {
    String? customPosition,
    bool isReversed = false,
  }) {
    if (state.selectedTopic == null) return;

    // Apply reversed orientation to the card
    final orientedCard = card.copyWith(isReversed: isReversed);

    // Determine position name
    final currentCount = state.selectedCards.length;
    final suggestedPositions = _service.getSuggestedPositions(currentCount + 1);
    final positionName =
        customPosition ??
        (currentCount < suggestedPositions.length
            ? suggestedPositions[currentCount]
            : 'Position ${currentCount + 1}');

    // Create new card position without interpretation
    final cardPosition = ManualCardPosition(
      card: orientedCard,
      positionName: positionName,
      interpretation: '', // Empty interpretation - will be filled later
      order: currentCount,
    );

    // Add to selected cards
    final updatedCards = [...state.selectedCards, cardPosition];

    state = state.copyWith(selectedCards: updatedCards);
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

      // Check if user can perform manual interpretation and consume usage
      final canPerform = await validateManualInterpretationUsage();
      if (!canPerform) {
        state = state.copyWith(
          error:
              'You have reached your monthly limit for manual interpretations. Upgrade to continue.',
          isLoading: false,
        );
        return;
      }

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
        selectedGuide: state.selectedGuide,
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
        selectedGuide: state.selectedGuide,
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
      // Debug: Searching for: "$query"
      state = state.copyWith(isSearching: true, searchQuery: query);

      List<TarotCard> filteredCards;
      if (query.trim().isEmpty) {
        // If query is empty, show all cards
        filteredCards = await _cardService.getAllCards();
        // Debug: Empty query, showing ${filteredCards.length} cards
      } else {
        // Search with the query
        filteredCards = await _cardService.searchCards(query.trim());
        // Debug: Search found ${filteredCards.length} cards
      }

      state = state.copyWith(availableCards: filteredCards, isSearching: false);
    } catch (e) {
      // Debug: Search error: $e
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
      // Debug: Filtering by suit: ${suit?.name ?? "all"}
      state = state.copyWith(isLoading: true);

      List<TarotCard> filteredCards;
      if (suit == null) {
        // Show all cards, but apply current search if any
        if (state.searchQuery.trim().isNotEmpty) {
          filteredCards = await _cardService.searchCards(
            state.searchQuery.trim(),
          );
          // Debug: All cards with search "${state.searchQuery}": ${filteredCards.length}
        } else {
          filteredCards = await _cardService.getAllCards();
          // Debug: All cards: ${filteredCards.length}
        }
      } else {
        // Filter by suit first, then apply search if any
        filteredCards = await _cardService.getCardsBySuit(suit);
        // Debug: Cards for suit ${suit.name}: ${filteredCards.length}
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
          // Debug: Cards after search filter: ${filteredCards.length}
        }
      }

      state = state.copyWith(availableCards: filteredCards, isLoading: false);
    } catch (e) {
      // Debug: Filter error: $e
      state = state.copyWith(error: 'Filter failed: $e', isLoading: false);
    }
  }

  /// Clear all selected cards and start over
  void clearSelection() {
    state = state.copyWith(
      selectedCards: [],
      connections: [],
      selectedTopic: null,
      selectedGuide: null,
      hasRequestedInterpretation: false,
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

  /// Generate interpretations for all selected cards
  Future<void> interpretAllCards() async {
    if (state.selectedTopic == null || state.selectedCards.isEmpty) return;

    try {
      state = state.copyWith(isLoading: true, error: null);

      // Check if user can perform manual interpretation and consume usage
      final canPerform = await validateManualInterpretationUsage();
      if (!canPerform) {
        state = state.copyWith(
          error:
              'You have reached your monthly limit for manual interpretations. Upgrade to continue.',
          isLoading: false,
        );
        return;
      }

      // Generate interpretations for all cards
      final updatedCards = <ManualCardPosition>[];

      for (int i = 0; i < state.selectedCards.length; i++) {
        final cardPosition = state.selectedCards[i];

        // Generate new interpretation
        final interpretation = await _service.generateInterpretation(
          card: cardPosition.card,
          topic: state.selectedTopic!,
          positionName: cardPosition.positionName,
          selectedGuide: state.selectedGuide,
        );

        // Update the card position with new interpretation
        updatedCards.add(cardPosition.copyWith(interpretation: interpretation));
      }

      // Analyze connections with updated cards
      final connections = _service.analyzeCardConnections(updatedCards);

      state = state.copyWith(
        selectedCards: updatedCards,
        connections: connections,
        isLoading: false,
        hasRequestedInterpretation: true,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to interpret cards: $e',
        isLoading: false,
      );
    }
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
      return ManualInterpretationNotifier(service, cardService, ref);
    });

/// Provider for saved manual interpretations
final savedManualInterpretationsProvider =
    FutureProvider<List<ManualInterpretation>>((ref) async {
      final service = ref.watch(manualInterpretationServiceProvider);
      return service.getSavedInterpretations();
    });

/// Provider for checking manual interpretation access (without consuming usage)
final canAccessManualInterpretationProvider = FutureProvider<bool>((ref) async {
  return ref.watch(canPerformManualInterpretationProvider).value ?? false;
});

/// Provider for manual interpretation usage info
final manualInterpretationUsageProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  return ref.watch(featureUsageInfoProvider('manual_interpretations')).value ??
      {};
});
