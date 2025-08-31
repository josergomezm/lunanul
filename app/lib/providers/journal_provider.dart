import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reading.dart';
import '../models/enums.dart';
import '../services/journal_service.dart';

/// Provider for the JournalService instance
final journalServiceProvider = Provider<JournalService>((ref) {
  return JournalService.instance;
});

/// State notifier for managing saved readings
class SavedReadingsNotifier extends StateNotifier<AsyncValue<List<Reading>>> {
  SavedReadingsNotifier(this._journalService)
    : super(const AsyncValue.loading()) {
    _loadSavedReadings();
  }

  final JournalService _journalService;

  /// Load all saved readings
  Future<void> _loadSavedReadings() async {
    try {
      final readings = await _journalService.getSavedReadings();
      state = AsyncValue.data(readings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh saved readings
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadSavedReadings();
  }

  /// Save a reading
  Future<bool> saveReading(Reading reading) async {
    try {
      final success = await _journalService.saveReading(reading);
      if (success) {
        // Refresh the list to show the new reading
        await _loadSavedReadings();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  /// Update reading reflection
  Future<bool> updateReflection(String readingId, String reflection) async {
    try {
      final success = await _journalService.updateReadingReflection(
        readingId,
        reflection,
      );
      if (success) {
        // Update the local state without full reload
        final currentReadings = state.value ?? [];
        final updatedReadings = currentReadings.map((reading) {
          if (reading.id == readingId) {
            return reading.copyWith(userReflection: reflection);
          }
          return reading;
        }).toList();
        state = AsyncValue.data(updatedReadings);
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  /// Delete a reading
  Future<bool> deleteReading(String readingId) async {
    try {
      final success = await _journalService.deleteReading(readingId);
      if (success) {
        // Remove from local state
        final currentReadings = state.value ?? [];
        final updatedReadings = currentReadings
            .where((reading) => reading.id != readingId)
            .toList();
        state = AsyncValue.data(updatedReadings);
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  /// Get readings by topic
  List<Reading> getReadingsByTopic(ReadingTopic topic) {
    final readings = state.value ?? [];
    return readings.where((reading) => reading.topic == topic).toList();
  }

  /// Get recent readings
  List<Reading> getRecentReadings({int limit = 5}) {
    final readings = state.value ?? [];
    return readings.take(limit).toList();
  }
}

/// Provider for saved readings state
final savedReadingsProvider =
    StateNotifierProvider<SavedReadingsNotifier, AsyncValue<List<Reading>>>((
      ref,
    ) {
      return SavedReadingsNotifier(ref.read(journalServiceProvider));
    });

/// Provider for reading statistics
final readingStatisticsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final journalService = ref.read(journalServiceProvider);
  return journalService.getReadingStatistics();
});

/// Provider for recent readings (for home page)
final recentReadingsProvider = Provider<List<Reading>>((ref) {
  final savedReadingsAsync = ref.watch(savedReadingsProvider);
  return savedReadingsAsync.when(
    data: (readings) => readings.take(3).toList(),
    loading: () => [],
    error: (_, _) => [],
  );
});

/// Provider for readings by topic
final readingsByTopicProvider = Provider.family<List<Reading>, ReadingTopic>((
  ref,
  topic,
) {
  final savedReadingsAsync = ref.watch(savedReadingsProvider);
  return savedReadingsAsync.when(
    data: (readings) => readings.where((r) => r.topic == topic).toList(),
    loading: () => [],
    error: (_, _) => [],
  );
});

/// Provider for a specific reading by ID
final readingByIdProvider = Provider.family<Reading?, String>((ref, readingId) {
  final savedReadingsAsync = ref.watch(savedReadingsProvider);
  return savedReadingsAsync.when(
    data: (readings) {
      try {
        return readings.firstWhere((r) => r.id == readingId);
      } catch (e) {
        return null;
      }
    },
    loading: () => null,
    error: (_, _) => null,
  );
});

/// Provider to check if a reading is saved
final isReadingSavedProvider = Provider.family<bool, String>((ref, readingId) {
  final savedReadingsAsync = ref.watch(savedReadingsProvider);
  return savedReadingsAsync.when(
    data: (readings) => readings.any((r) => r.id == readingId),
    loading: () => false,
    error: (_, _) => false,
  );
});

/// Provider for total saved reading count
final savedReadingCountProvider = Provider<int>((ref) {
  final savedReadingsAsync = ref.watch(savedReadingsProvider);
  return savedReadingsAsync.when(
    data: (readings) => readings.length,
    loading: () => 0,
    error: (_, _) => 0,
  );
});
