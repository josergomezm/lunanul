import 'dart:async';
import 'dart:math';
import '../models/enums.dart';
import 'audio_reading_service.dart';

/// Mock implementation of AudioReadingService for development and testing
class MockAudioReadingService implements AudioReadingService {
  final Random _random = Random();
  final Map<String, AudioGenerationStatus> _activeRequests = {};
  final Map<String, Timer> _requestTimers = {};

  @override
  Future<String?> generateCardAudio({
    required String cardName,
    required GuideType guide,
    String? context,
  }) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(300)));

    // Check if guide supports audio
    if (!isAudioAvailableForGuide(guide)) {
      throw const AudioGenerationException(
        message: 'Audio not available for this guide',
        error: AudioGenerationError.unsupportedGuide,
      );
    }

    // Simulate occasional failures
    if (_random.nextDouble() < 0.05) {
      throw const AudioGenerationException(
        message: 'Network error during audio generation',
        error: AudioGenerationError.networkError,
      );
    }

    // Return mock audio URL
    final requestId = _generateRequestId();
    return 'mock://audio/card/${cardName.toLowerCase().replaceAll(' ', '_')}_${guide.name}_$requestId.mp3';
  }

  @override
  Future<String?> generateSpreadAudio({
    required List<String> cards,
    required SpreadType spreadType,
    required GuideType guide,
    required String interpretation,
  }) async {
    // Simulate longer processing time for spreads
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)));

    if (!isAudioAvailableForGuide(guide)) {
      throw const AudioGenerationException(
        message: 'Audio not available for this guide',
        error: AudioGenerationError.unsupportedGuide,
      );
    }

    // Check text length limits
    if (interpretation.length > 5000) {
      throw const AudioGenerationException(
        message: 'Text too long for audio generation',
        error: AudioGenerationError.textTooLong,
      );
    }

    // Simulate quota limits
    if (_random.nextDouble() < 0.02) {
      throw const AudioGenerationException(
        message: 'Daily audio generation quota exceeded',
        error: AudioGenerationError.quotaExceeded,
      );
    }

    final requestId = _generateRequestId();
    return 'mock://audio/spread/${spreadType.name}_${guide.name}_$requestId.mp3';
  }

  @override
  bool isAudioAvailableForGuide(GuideType guide) {
    // Mock availability - all guides except one for testing
    switch (guide) {
      case GuideType.healer:
      case GuideType.mentor:
      case GuideType.sage:
        return true;
      case GuideType.visionary:
        return false; // Simulate unavailable guide for testing
    }
  }

  @override
  int getEstimatedGenerationTime(int textLength) {
    // Estimate based on text length (roughly 150 words per minute reading speed)
    final wordsEstimate = textLength / 5; // Rough words estimate
    final readingTimeSeconds = (wordsEstimate / 2.5).ceil(); // 150 WPM
    final processingOverhead = 5; // Base processing time

    return readingTimeSeconds + processingOverhead;
  }

  @override
  Future<void> cancelGeneration(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (_activeRequests.containsKey(requestId)) {
      _activeRequests[requestId] = AudioGenerationStatus.cancelled;
      _requestTimers[requestId]?.cancel();
      _requestTimers.remove(requestId);
    }
  }

  @override
  Future<AudioGenerationStatus> getGenerationStatus(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 50));

    return _activeRequests[requestId] ?? AudioGenerationStatus.completed;
  }

  /// Simulates a long-running audio generation process
  Future<String> generateAudioWithProgress({
    required String content,
    required GuideType guide,
    required Function(AudioGenerationStatus) onStatusUpdate,
  }) async {
    final requestId = _generateRequestId();

    // Start with pending status
    _activeRequests[requestId] = AudioGenerationStatus.pending;
    onStatusUpdate(AudioGenerationStatus.pending);

    // Simulate processing stages
    await Future.delayed(const Duration(milliseconds: 500));

    if (_activeRequests[requestId] == AudioGenerationStatus.cancelled) {
      return '';
    }

    _activeRequests[requestId] = AudioGenerationStatus.processing;
    onStatusUpdate(AudioGenerationStatus.processing);

    // Simulate processing time based on content length
    final processingTime = getEstimatedGenerationTime(content.length);
    await Future.delayed(Duration(seconds: processingTime));

    if (_activeRequests[requestId] == AudioGenerationStatus.cancelled) {
      return '';
    }

    // Complete generation
    _activeRequests[requestId] = AudioGenerationStatus.completed;
    onStatusUpdate(AudioGenerationStatus.completed);

    return 'mock://audio/generated_$requestId.mp3';
  }

  String _generateRequestId() {
    return 'req_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(1000)}';
  }

  /// Clears all active requests (useful for testing)
  void clearActiveRequests() {
    for (final timer in _requestTimers.values) {
      timer.cancel();
    }
    _activeRequests.clear();
    _requestTimers.clear();
  }
}
