import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/card_service.dart';

/// Provider for the CardService instance
final cardServiceProvider = Provider<CardService>((ref) {
  return CardService.instance;
});

/// Provider for all tarot cards
final allCardsProvider = FutureProvider<List<TarotCard>>((ref) async {
  final cardService = ref.read(cardServiceProvider);
  return cardService.getAllCards();
});

/// Provider for card of the day
final cardOfTheDayProvider = FutureProvider<TarotCard>((ref) async {
  final cardService = ref.read(cardServiceProvider);
  return cardService.getCardOfTheDay();
});

/// Provider for searching cards
final cardSearchProvider =
    StateNotifierProvider<CardSearchNotifier, AsyncValue<List<TarotCard>>>((
      ref,
    ) {
      return CardSearchNotifier(ref.read(cardServiceProvider));
    });

/// State notifier for card search functionality
class CardSearchNotifier extends StateNotifier<AsyncValue<List<TarotCard>>> {
  CardSearchNotifier(this._cardService) : super(const AsyncValue.loading()) {
    // Initialize with all cards
    _loadAllCards();
  }

  final CardService _cardService;

  /// Load all cards initially
  Future<void> _loadAllCards() async {
    try {
      final cards = await _cardService.getAllCards();
      state = AsyncValue.data(cards);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Search cards by query
  Future<void> searchCards(String query) async {
    if (query.isEmpty) {
      _loadAllCards();
      return;
    }

    state = const AsyncValue.loading();
    try {
      final cards = await _cardService.searchCards(query);
      state = AsyncValue.data(cards);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Filter cards by criteria
  Future<void> filterCards({
    TarotSuit? suit,
    bool? isMajorArcana,
    bool? isCourtCard,
    List<String>? keywords,
  }) async {
    state = const AsyncValue.loading();
    try {
      final cards = await _cardService.getFilteredCards(
        suit: suit,
        isMajorArcana: isMajorArcana,
        isCourtCard: isCourtCard,
        keywords: keywords,
      );
      state = AsyncValue.data(cards);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Reset to show all cards
  void resetSearch() {
    _loadAllCards();
  }
}

/// Provider for cards by suit
final cardsBySuitProvider = FutureProvider.family<List<TarotCard>, TarotSuit>((
  ref,
  suit,
) async {
  final cardService = ref.read(cardServiceProvider);
  return cardService.getCardsBySuit(suit);
});

/// Provider for Major Arcana cards
final majorArcanaCardsProvider = FutureProvider<List<TarotCard>>((ref) async {
  final cardService = ref.read(cardServiceProvider);
  return cardService.getMajorArcanaCards();
});

/// Provider for Minor Arcana cards
final minorArcanaCardsProvider = FutureProvider<List<TarotCard>>((ref) async {
  final cardService = ref.read(cardServiceProvider);
  return cardService.getMinorArcanaCards();
});

/// Provider for court cards
final courtCardsProvider = FutureProvider<List<TarotCard>>((ref) async {
  final cardService = ref.read(cardServiceProvider);
  return cardService.getCourtCards();
});

/// Provider for card statistics
final cardStatisticsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final cardService = ref.read(cardServiceProvider);
  return cardService.getCardStatistics();
});

/// Provider for getting a specific card by ID
final cardByIdProvider = FutureProvider.family<TarotCard?, String>((
  ref,
  cardId,
) async {
  final cardService = ref.read(cardServiceProvider);
  return cardService.getCardById(cardId);
});

/// Provider for drawing random cards
final randomCardsProvider = FutureProvider.family<List<TarotCard>, int>((
  ref,
  count,
) async {
  final cardService = ref.read(cardServiceProvider);
  return cardService.drawCards(
    count,
    allowReversed: true,
    allowDuplicates: false,
  );
});
