import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/mock_reading_service.dart';
import '../services/journal_service.dart';

/// Provider for the MockReadingService instance
final readingServiceProvider = Provider<MockReadingService>((ref) {
  return MockReadingService.instance;
});

/// State notifier for managing current reading state
class ReadingNotifier extends StateNotifier<AsyncValue<Reading?>> {
  ReadingNotifier(this._readingService) : super(const AsyncValue.data(null));

  final MockReadingService _readingService;

  /// Create a new reading
  Future<void> createReading({
    required ReadingTopic topic,
    required SpreadType spreadType,
    String? customTitle,
    GuideType? selectedGuide,
  }) async {
    state = const AsyncValue.loading();
    try {
      final reading = await _readingService.createReading(
        topic: topic,
        spreadType: spreadType,
        customTitle: customTitle,
        selectedGuide: selectedGuide,
      );
      state = AsyncValue.data(reading);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Clear current reading
  void clearReading() {
    state = const AsyncValue.data(null);
  }

  /// Update reading with user reflection
  void updateReflection(String reflection) {
    final currentReading = state.value;
    if (currentReading != null) {
      final updatedReading = currentReading.copyWith(
        userReflection: reflection,
      );
      state = AsyncValue.data(updatedReading);
    }
  }

  /// Mark reading as saved
  void markAsSaved() {
    final currentReading = state.value;
    if (currentReading != null) {
      final updatedReading = currentReading.copyWith(isSaved: true);
      state = AsyncValue.data(updatedReading);
    }
  }

  /// Save current reading to journal
  Future<bool> saveCurrentReading() async {
    final currentReading = state.value;
    if (currentReading == null) return false;

    try {
      // Import journal service here to avoid circular dependency
      final journalService = JournalService.instance;
      final success = await journalService.saveReading(currentReading);

      if (success) {
        markAsSaved();
      }

      return success;
    } catch (e) {
      return false;
    }
  }
}

/// Provider for current reading state
final currentReadingProvider =
    StateNotifierProvider<ReadingNotifier, AsyncValue<Reading?>>((ref) {
      return ReadingNotifier(ref.read(readingServiceProvider));
    });

/// Provider for sample readings
final sampleReadingsProvider = FutureProvider<List<Reading>>((ref) async {
  final readingService = ref.read(readingServiceProvider);
  return readingService.getSampleReadings();
});

/// Provider for daily affirmation
final dailyAffirmationProvider = FutureProvider.family<String, TarotCard>((
  ref,
  card,
) async {
  final readingService = ref.read(readingServiceProvider);
  return readingService.generateDailyAffirmation(card);
});

/// Provider for spreads available for a topic
final spreadsByTopicProvider = Provider.family<List<SpreadType>, ReadingTopic>((
  ref,
  topic,
) {
  return SpreadType.getSpreadsByTopic(topic);
});

/// State notifier for reading creation flow
class ReadingFlowNotifier extends StateNotifier<ReadingFlowState> {
  ReadingFlowNotifier() : super(ReadingFlowState.initial());

  /// Set the selected topic
  void setTopic(ReadingTopic topic) {
    state = state.copyWith(
      topic: topic,
      clearSpreadType: true,
      clearSelectedGuide: true,
    );
  }

  /// Set the selected spread type
  void setSpreadType(SpreadType spreadType) {
    state = state.copyWith(spreadType: spreadType);
  }

  /// Set custom title
  void setCustomTitle(String? title) {
    state = state.copyWith(customTitle: title);
  }

  /// Set the selected guide
  void setSelectedGuide(GuideType? guide) {
    state = state.copyWith(selectedGuide: guide);
  }

  /// Reset the flow
  void reset() {
    state = ReadingFlowState.initial();
  }

  /// Check if ready to create reading
  bool get canCreateReading => state.topic != null && state.spreadType != null;

  /// Check if guide selection is complete (optional step)
  bool get hasGuideSelection => state.selectedGuide != null;
}

/// State class for reading creation flow
class ReadingFlowState {
  const ReadingFlowState({
    this.topic,
    this.spreadType,
    this.customTitle,
    this.selectedGuide,
  });

  final ReadingTopic? topic;
  final SpreadType? spreadType;
  final String? customTitle;
  final GuideType? selectedGuide;

  factory ReadingFlowState.initial() {
    return const ReadingFlowState();
  }

  ReadingFlowState copyWith({
    ReadingTopic? topic,
    SpreadType? spreadType,
    String? customTitle,
    GuideType? selectedGuide,
    bool clearSpreadType = false,
    bool clearSelectedGuide = false,
  }) {
    return ReadingFlowState(
      topic: topic ?? this.topic,
      spreadType: clearSpreadType ? null : (spreadType ?? this.spreadType),
      customTitle: customTitle ?? this.customTitle,
      selectedGuide: clearSelectedGuide
          ? null
          : (selectedGuide ?? this.selectedGuide),
    );
  }
}

/// Provider for reading creation flow
final readingFlowProvider =
    StateNotifierProvider<ReadingFlowNotifier, ReadingFlowState>((ref) {
      return ReadingFlowNotifier();
    });

/// Provider that creates a reading with guide selection from the reading flow
final createReadingWithGuideProvider =
    FutureProvider.family<Reading, ReadingFlowState>((ref, flowState) async {
      if (flowState.topic == null || flowState.spreadType == null) {
        throw Exception(
          'Topic and spread type must be selected before creating reading',
        );
      }

      final readingNotifier = ref.read(currentReadingProvider.notifier);
      await readingNotifier.createReading(
        topic: flowState.topic!,
        spreadType: flowState.spreadType!,
        customTitle: flowState.customTitle,
        selectedGuide: flowState.selectedGuide,
      );

      final reading = ref.read(currentReadingProvider).value;
      if (reading == null) {
        throw Exception('Failed to create reading');
      }

      return reading;
    });
