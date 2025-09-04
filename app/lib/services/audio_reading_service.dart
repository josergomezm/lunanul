import '../models/enums.dart';

/// Service interface for generating AI-powered audio interpretations of tarot readings
/// This is an Oracle tier premium feature that provides voice narration of readings
abstract class AudioReadingService {
  /// Generates an audio interpretation for a single card reading
  ///
  /// [cardName] - The name of the tarot card
  /// [guide] - The selected guide for the reading
  /// [context] - Additional context about the reading (position, question, etc.)
  ///
  /// Returns the URL or path to the generated audio file
  Future<String?> generateCardAudio({
    required String cardName,
    required GuideType guide,
    String? context,
  });

  /// Generates an audio interpretation for a multi-card spread
  ///
  /// [cards] - List of card names in the spread
  /// [spreadType] - The type of spread being read
  /// [guide] - The selected guide for the reading
  /// [interpretation] - The text interpretation to convert to audio
  ///
  /// Returns the URL or path to the generated audio file
  Future<String?> generateSpreadAudio({
    required List<String> cards,
    required SpreadType spreadType,
    required GuideType guide,
    required String interpretation,
  });

  /// Checks if audio generation is available for the given guide
  ///
  /// [guide] - The guide to check availability for
  ///
  /// Returns true if audio generation is supported for this guide
  bool isAudioAvailableForGuide(GuideType guide);

  /// Gets the estimated duration for audio generation
  ///
  /// [textLength] - Length of text to be converted to audio
  ///
  /// Returns estimated duration in seconds
  int getEstimatedGenerationTime(int textLength);

  /// Cancels an ongoing audio generation request
  ///
  /// [requestId] - The ID of the generation request to cancel
  Future<void> cancelGeneration(String requestId);

  /// Gets the current status of an audio generation request
  ///
  /// [requestId] - The ID of the generation request
  ///
  /// Returns the current status of the generation
  Future<AudioGenerationStatus> getGenerationStatus(String requestId);
}

/// Status of an audio generation request
enum AudioGenerationStatus { pending, processing, completed, failed, cancelled }

/// Exception thrown when audio generation fails
class AudioGenerationException implements Exception {
  final String message;
  final AudioGenerationError error;
  final dynamic originalError;

  const AudioGenerationException({
    required this.message,
    required this.error,
    this.originalError,
  });

  @override
  String toString() => 'AudioGenerationException: $message';
}

/// Types of audio generation errors
enum AudioGenerationError {
  networkError,
  quotaExceeded,
  unsupportedGuide,
  textTooLong,
  serviceUnavailable,
  invalidRequest,
}
