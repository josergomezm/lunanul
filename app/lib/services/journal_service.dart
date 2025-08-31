import 'package:shared_preferences/shared_preferences.dart';
import '../models/reading.dart';
import '../models/enums.dart';

/// Service for managing saved readings and journal functionality
class JournalService {
  static JournalService? _instance;
  static JournalService get instance => _instance ??= JournalService._();
  JournalService._();

  static const String _savedReadingsKey = 'saved_readings';
  static const String _readingCounterKey = 'reading_counter';

  /// Save a reading to local storage
  Future<bool> saveReading(Reading reading) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing saved readings
      final savedReadings = await getSavedReadings();

      // Create a saved version of the reading
      final savedReading = reading.copyWith(
        isSaved: true,
        id: reading.id.isEmpty ? await _generateReadingId() : reading.id,
      );

      // Add to the list (newest first)
      savedReadings.insert(0, savedReading);

      // Convert to JSON strings
      final readingJsonList = savedReadings
          .map((r) => r.toJsonString())
          .toList();

      // Save to SharedPreferences
      await prefs.setStringList(_savedReadingsKey, readingJsonList);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get all saved readings from local storage
  Future<List<Reading>> getSavedReadings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final readingJsonList = prefs.getStringList(_savedReadingsKey) ?? [];

      return readingJsonList
          .map((jsonString) => Reading.fromJsonString(jsonString))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Update a saved reading with new reflection
  Future<bool> updateReadingReflection(
    String readingId,
    String reflection,
  ) async {
    try {
      final savedReadings = await getSavedReadings();
      final readingIndex = savedReadings.indexWhere((r) => r.id == readingId);

      if (readingIndex == -1) return false;

      // Update the reading with new reflection
      final updatedReading = savedReadings[readingIndex].copyWith(
        userReflection: reflection,
      );

      savedReadings[readingIndex] = updatedReading;

      // Save back to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final readingJsonList = savedReadings
          .map((r) => r.toJsonString())
          .toList();

      await prefs.setStringList(_savedReadingsKey, readingJsonList);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete a saved reading
  Future<bool> deleteReading(String readingId) async {
    try {
      final savedReadings = await getSavedReadings();
      savedReadings.removeWhere((r) => r.id == readingId);

      // Save back to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final readingJsonList = savedReadings
          .map((r) => r.toJsonString())
          .toList();

      await prefs.setStringList(_savedReadingsKey, readingJsonList);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get a specific reading by ID
  Future<Reading?> getReading(String readingId) async {
    try {
      final savedReadings = await getSavedReadings();
      return savedReadings.firstWhere(
        (r) => r.id == readingId,
        orElse: () => throw StateError('Reading not found'),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get readings filtered by topic
  Future<List<Reading>> getReadingsByTopic(ReadingTopic topic) async {
    final savedReadings = await getSavedReadings();
    return savedReadings.where((r) => r.topic == topic).toList();
  }

  /// Get recent readings (last N readings)
  Future<List<Reading>> getRecentReadings({int limit = 5}) async {
    final savedReadings = await getSavedReadings();
    return savedReadings.take(limit).toList();
  }

  /// Get reading statistics
  Future<Map<String, dynamic>> getReadingStatistics() async {
    final savedReadings = await getSavedReadings();

    if (savedReadings.isEmpty) {
      return {
        'totalReadings': 0,
        'topicCounts': <String, int>{},
        'spreadCounts': <String, int>{},
        'averageReflectionLength': 0.0,
        'readingsWithReflections': 0,
        'mostFrequentCards': <String, int>{},
      };
    }

    // Count by topic
    final topicCounts = <String, int>{};
    for (final reading in savedReadings) {
      final topicName = reading.topic.displayName;
      topicCounts[topicName] = (topicCounts[topicName] ?? 0) + 1;
    }

    // Count by spread type
    final spreadCounts = <String, int>{};
    for (final reading in savedReadings) {
      final spreadName = reading.spreadType.displayName;
      spreadCounts[spreadName] = (spreadCounts[spreadName] ?? 0) + 1;
    }

    // Reflection statistics
    final readingsWithReflections = savedReadings
        .where((r) => r.hasReflection)
        .length;

    final totalReflectionLength = savedReadings
        .where((r) => r.hasReflection)
        .map((r) => r.userReflection!.length)
        .fold(0, (sum, length) => sum + length);

    final averageReflectionLength = readingsWithReflections > 0
        ? totalReflectionLength / readingsWithReflections
        : 0.0;

    // Most frequent cards
    final cardCounts = <String, int>{};
    for (final reading in savedReadings) {
      for (final cardId in reading.uniqueCardIds) {
        cardCounts[cardId] = (cardCounts[cardId] ?? 0) + 1;
      }
    }

    // Sort cards by frequency and take top 10
    final sortedCards = cardCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final mostFrequentCards = Map<String, int>.fromEntries(
      sortedCards.take(10),
    );

    return {
      'totalReadings': savedReadings.length,
      'topicCounts': topicCounts,
      'spreadCounts': spreadCounts,
      'averageReflectionLength': averageReflectionLength,
      'readingsWithReflections': readingsWithReflections,
      'mostFrequentCards': mostFrequentCards,
    };
  }

  /// Clear all saved readings (for testing or reset)
  Future<bool> clearAllReadings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_savedReadingsKey);
      await prefs.remove(_readingCounterKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Generate a unique reading ID
  Future<String> _generateReadingId() async {
    final prefs = await SharedPreferences.getInstance();
    final counter = prefs.getInt(_readingCounterKey) ?? 0;
    final newCounter = counter + 1;
    await prefs.setInt(_readingCounterKey, newCounter);

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'reading_${timestamp}_$newCounter';
  }

  /// Check if a reading is already saved
  Future<bool> isReadingSaved(String readingId) async {
    final savedReadings = await getSavedReadings();
    return savedReadings.any((r) => r.id == readingId);
  }

  /// Get total count of saved readings
  Future<int> getSavedReadingCount() async {
    final savedReadings = await getSavedReadings();
    return savedReadings.length;
  }
}
