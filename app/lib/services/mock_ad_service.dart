import 'dart:math';
import 'ad_service.dart';
import '../models/enums.dart';

/// Mock implementation of AdService for development and testing
class MockAdService implements AdService {
  MockAdService({AdConfiguration? configuration})
    : _configuration = configuration ?? const AdConfiguration();

  final AdConfiguration _configuration;
  final Random _random = Random();

  bool _isInitialized = false;
  int _adsShownThisSession = 0;
  DateTime? _lastAdShown;

  // Mock spiritual and wellness-focused ad content
  static const List<Map<String, String>> _mockAds = [
    {
      'id': 'spiritual_journal_1',
      'content': 'Deepen your spiritual practice with guided journaling',
      'type': 'spiritual',
    },
    {
      'id': 'meditation_app_1',
      'content': 'Find inner peace with daily meditation',
      'type': 'spiritual',
    },
    {
      'id': 'crystal_healing_1',
      'content': 'Discover the power of healing crystals',
      'type': 'spiritual',
    },
    {
      'id': 'astrology_guide_1',
      'content': 'Unlock your cosmic potential with astrology',
      'type': 'spiritual',
    },
    {
      'id': 'mindfulness_book_1',
      'content': 'Transform your life with mindful living',
      'type': 'spiritual',
    },
    {
      'id': 'yoga_practice_1',
      'content': 'Connect body and spirit through yoga',
      'type': 'spiritual',
    },
  ];

  @override
  Future<void> initialize() async {
    // Simulate initialization delay
    await Future.delayed(const Duration(milliseconds: 500));
    _isInitialized = true;
  }

  @override
  Future<bool> shouldShowAds() async {
    if (!_isInitialized) {
      await initialize();
    }

    // Check session limits
    if (_adsShownThisSession >= _configuration.maxAdsPerSession) {
      return false;
    }

    // Check time between ads
    if (_lastAdShown != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastAdShown!);
      if (timeSinceLastAd < _configuration.minTimeBetweenAds) {
        return false;
      }
    }

    // For mock purposes, show ads 70% of the time for free users
    return _random.nextDouble() < 0.7;
  }

  @override
  Future<AdContent?> loadReadingAd({
    required ReadingTopic topic,
    required SpreadType spreadType,
  }) async {
    if (!await shouldShowAds()) {
      return null;
    }

    // Select a random ad from our mock collection
    final adData = _mockAds[_random.nextInt(_mockAds.length)];

    // Create contextual content based on reading topic
    String contextualContent = _getContextualContent(topic, adData['content']!);

    return AdContent(
      id: adData['id']!,
      type: AdType.fromString(adData['type']!),
      content: contextualContent,
      displayDuration: const Duration(seconds: 5),
    );
  }

  @override
  Future<void> showAd(AdContent adContent) async {
    // Simulate ad display
    await Future.delayed(const Duration(milliseconds: 300));

    _adsShownThisSession++;
    _lastAdShown = DateTime.now();

    // Track impression
    await trackAdImpression(adContent.id);
  }

  @override
  Future<void> trackAdImpression(String adId) async {
    // Mock analytics tracking
    // ignore: avoid_print
    print('Mock Ad Service: Tracked impression for ad $adId');
  }

  @override
  Future<void> trackAdClick(String adId) async {
    // Mock analytics tracking
    // ignore: avoid_print
    print('Mock Ad Service: Tracked click for ad $adId');
  }

  @override
  Future<void> dispose() async {
    _isInitialized = false;
    _adsShownThisSession = 0;
    _lastAdShown = null;
  }

  /// Generate contextual ad content based on reading topic
  String _getContextualContent(ReadingTopic topic, String baseContent) {
    switch (topic) {
      case ReadingTopic.love:
        return baseContent
            .replaceAll('spiritual practice', 'relationships')
            .replaceAll('inner peace', 'emotional harmony');
      case ReadingTopic.work:
        return baseContent
            .replaceAll('spiritual practice', 'career growth')
            .replaceAll('inner peace', 'professional clarity');
      case ReadingTopic.social:
        return baseContent
            .replaceAll('spiritual practice', 'social connections')
            .replaceAll('inner peace', 'social harmony');
      case ReadingTopic.self:
        return baseContent;
    }
  }

  /// Get current session statistics for testing
  Map<String, dynamic> getSessionStats() {
    return {
      'adsShownThisSession': _adsShownThisSession,
      'lastAdShown': _lastAdShown?.toIso8601String(),
      'isInitialized': _isInitialized,
    };
  }

  /// Reset session for testing
  void resetSession() {
    _adsShownThisSession = 0;
    _lastAdShown = null;
  }
}
