import 'dart:math';
import 'early_access_service.dart';

/// Mock implementation of EarlyAccessService for development and testing
class MockEarlyAccessService implements EarlyAccessService {
  final Random _random = Random();
  final Set<String> _enabledFeatures = {
    'beta_guide_oracle',
    'experimental_spread_chakra',
  };
  final Map<String, bool> _readAnnouncements = {};

  // Mock early access features
  static final List<EarlyAccessFeature> _mockFeatures = [
    EarlyAccessFeature(
      id: 'beta_guide_oracle',
      name: 'The Oracle Guide (Beta)',
      description:
          'A new AI guide specializing in prophetic insights and future guidance',
      type: EarlyAccessFeatureType.guide,
      availableFrom: DateTime.now().subtract(const Duration(days: 30)),
      availableUntil: DateTime.now().add(const Duration(days: 60)),
      isStable: false,
      version: '0.8.2',
      requirements: ['oracle_subscription'],
      configuration: {
        'personality': 'prophetic',
        'specialty': 'future_insights',
        'voice_available': true,
      },
    ),
    EarlyAccessFeature(
      id: 'experimental_spread_chakra',
      name: 'Chakra Alignment Spread',
      description: 'A 7-card spread for chakra balancing and energy work',
      type: EarlyAccessFeatureType.spread,
      availableFrom: DateTime.now().subtract(const Duration(days: 15)),
      availableUntil: DateTime.now().add(const Duration(days: 45)),
      isStable: false,
      version: '0.5.1',
      requirements: ['oracle_subscription'],
      configuration: {
        'card_count': 7,
        'positions': [
          'root',
          'sacral',
          'solar_plexus',
          'heart',
          'throat',
          'third_eye',
          'crown',
        ],
      },
    ),
    EarlyAccessFeature(
      id: 'aurora_theme',
      name: 'Aurora Borealis Theme',
      description: 'Dynamic theme with northern lights animations',
      type: EarlyAccessFeatureType.theme,
      availableFrom: DateTime.now().subtract(const Duration(days: 7)),
      availableUntil: DateTime.now().add(const Duration(days: 90)),
      isStable: true,
      version: '1.0.0-beta',
      requirements: ['oracle_subscription'],
      configuration: {'animated_background': true, 'particle_effects': true},
    ),
    EarlyAccessFeature(
      id: 'ai_journal_analysis',
      name: 'AI Journal Pattern Analysis',
      description:
          'AI-powered analysis of journal entries to identify patterns and insights',
      type: EarlyAccessFeatureType.ai,
      availableFrom: DateTime.now().subtract(const Duration(days: 3)),
      availableUntil: DateTime.now().add(const Duration(days: 120)),
      isStable: false,
      version: '0.3.0',
      requirements: ['oracle_subscription', 'journal_entries_min_10'],
      configuration: {
        'analysis_depth': 'comprehensive',
        'pattern_detection': true,
      },
    ),
  ];

  // Mock beta guides
  static final List<BetaGuideConfig> _mockBetaGuides = [
    BetaGuideConfig(
      id: 'oracle_guide',
      name: 'The Oracle',
      description: 'A mystical guide with prophetic abilities and deep wisdom',
      personality: 'Wise, mysterious, speaks in riddles and metaphors',
      specialty: 'Future insights, prophetic visions, destiny guidance',
      avatarUrl: 'assets/images/guides/oracle_avatar.png',
      isAvailable: true,
      releaseDate: DateTime.now().add(const Duration(days: 30)),
      betaFeatures: ['voice_synthesis', 'prophetic_mode', 'vision_cards'],
    ),
    BetaGuideConfig(
      id: 'shadow_worker',
      name: 'The Shadow Worker',
      description:
          'A guide specializing in shadow work and deep psychological insights',
      personality: 'Direct, compassionate, helps face difficult truths',
      specialty: 'Shadow work, psychological healing, inner transformation',
      avatarUrl: 'assets/images/guides/shadow_worker_avatar.png',
      isAvailable: false,
      releaseDate: DateTime.now().add(const Duration(days: 60)),
      betaFeatures: [
        'shadow_spreads',
        'psychological_analysis',
        'healing_prompts',
      ],
    ),
  ];

  // Mock experimental spreads
  static final List<ExperimentalSpreadConfig> _mockExperimentalSpreads = [
    ExperimentalSpreadConfig(
      id: 'chakra_alignment',
      name: 'Chakra Alignment Spread',
      description:
          'A 7-card spread for balancing and understanding your chakra system',
      cardCount: 7,
      positions: [
        'Root Chakra',
        'Sacral Chakra',
        'Solar Plexus',
        'Heart Chakra',
        'Throat Chakra',
        'Third Eye',
        'Crown Chakra',
      ],
      difficulty: 'intermediate',
      requiresFeedback: true,
      experimentEndDate: DateTime.now().add(const Duration(days: 45)),
    ),
    ExperimentalSpreadConfig(
      id: 'lunar_phases',
      name: 'Lunar Phases Spread',
      description:
          'A 4-card spread following the moon\'s cycle for manifestation work',
      cardCount: 4,
      positions: [
        'New Moon - Intention',
        'Waxing Moon - Action',
        'Full Moon - Manifestation',
        'Waning Moon - Release',
      ],
      difficulty: 'beginner',
      requiresFeedback: true,
      experimentEndDate: DateTime.now().add(const Duration(days: 60)),
    ),
  ];

  // Mock announcements
  static final List<EarlyAccessAnnouncement> _mockAnnouncements = [
    EarlyAccessAnnouncement(
      id: 'oracle_guide_beta',
      title: 'New Beta Guide: The Oracle',
      content:
          'We\'re excited to introduce The Oracle, our newest AI guide specializing in prophetic insights. This beta version includes voice synthesis and experimental vision card features.',
      type: EarlyAccessAnnouncementType.betaRelease,
      publishedAt: DateTime.now().subtract(const Duration(days: 2)),
      featureId: 'beta_guide_oracle',
      imageUrl: 'assets/images/announcements/oracle_guide.png',
    ),
    EarlyAccessAnnouncement(
      id: 'chakra_spread_feedback',
      title: 'Feedback Needed: Chakra Alignment Spread',
      content:
          'Help us perfect the new Chakra Alignment Spread! Try it out and let us know how it works for your energy balancing practice.',
      type: EarlyAccessAnnouncementType.feedbackRequest,
      publishedAt: DateTime.now().subtract(const Duration(days: 5)),
      featureId: 'experimental_spread_chakra',
    ),
    EarlyAccessAnnouncement(
      id: 'aurora_theme_graduation',
      title: 'Aurora Theme Graduating to Full Release',
      content:
          'The Aurora Borealis theme has been so well-received in beta that we\'re moving it to full release next month!',
      type: EarlyAccessAnnouncementType.graduation,
      publishedAt: DateTime.now().subtract(const Duration(days: 7)),
      featureId: 'aurora_theme',
    ),
  ];

  @override
  Future<List<EarlyAccessFeature>> getAvailableFeatures() async {
    await Future.delayed(Duration(milliseconds: 150 + _random.nextInt(250)));

    // Filter features that are currently available
    final now = DateTime.now();
    return _mockFeatures.where((feature) {
      return feature.availableFrom.isBefore(now) &&
          (feature.availableUntil == null ||
              feature.availableUntil!.isAfter(now));
    }).toList();
  }

  @override
  Future<List<EarlyAccessFeature>> getEnabledFeatures() async {
    await Future.delayed(Duration(milliseconds: 100 + _random.nextInt(150)));

    return _mockFeatures
        .where((feature) => _enabledFeatures.contains(feature.id))
        .toList();
  }

  @override
  Future<bool> enableFeature(String featureId) async {
    await Future.delayed(Duration(milliseconds: 100 + _random.nextInt(200)));

    // Check if feature exists and is available
    final feature = _mockFeatures.firstWhere(
      (f) => f.id == featureId,
      orElse: () => throw const EarlyAccessException(
        message: 'Feature not found',
        error: EarlyAccessError.featureNotFound,
      ),
    );

    final now = DateTime.now();
    if (feature.availableFrom.isAfter(now) ||
        (feature.availableUntil != null &&
            feature.availableUntil!.isBefore(now))) {
      throw const EarlyAccessException(
        message: 'Feature not currently available',
        error: EarlyAccessError.featureNotAvailable,
      );
    }

    // Simulate occasional failures
    if (_random.nextDouble() < 0.05) {
      throw const EarlyAccessException(
        message: 'Failed to enable feature',
        error: EarlyAccessError.configurationError,
      );
    }

    _enabledFeatures.add(featureId);
    return true;
  }

  @override
  Future<bool> disableFeature(String featureId) async {
    await Future.delayed(Duration(milliseconds: 100 + _random.nextInt(150)));

    _enabledFeatures.remove(featureId);
    return true;
  }

  @override
  Future<bool> isFeatureAvailable(String featureId) async {
    await Future.delayed(const Duration(milliseconds: 50));

    final feature = _mockFeatures.firstWhere(
      (f) => f.id == featureId,
      orElse: () => throw const EarlyAccessException(
        message: 'Feature not found',
        error: EarlyAccessError.featureNotFound,
      ),
    );

    final now = DateTime.now();
    return feature.availableFrom.isBefore(now) &&
        (feature.availableUntil == null ||
            feature.availableUntil!.isAfter(now));
  }

  @override
  Future<bool> isFeatureEnabled(String featureId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _enabledFeatures.contains(featureId);
  }

  @override
  Future<List<BetaGuideConfig>> getBetaGuides() async {
    await Future.delayed(Duration(milliseconds: 100 + _random.nextInt(200)));
    return List.from(_mockBetaGuides);
  }

  @override
  Future<bool> enableBetaGuide(String guideId) async {
    await Future.delayed(Duration(milliseconds: 100 + _random.nextInt(150)));

    final guide = _mockBetaGuides.firstWhere(
      (g) => g.id == guideId,
      orElse: () => throw const EarlyAccessException(
        message: 'Beta guide not found',
        error: EarlyAccessError.featureNotFound,
      ),
    );

    if (!guide.isAvailable) {
      throw const EarlyAccessException(
        message: 'Beta guide not yet available',
        error: EarlyAccessError.featureNotAvailable,
      );
    }

    _enabledFeatures.add('beta_guide_$guideId');
    return true;
  }

  @override
  Future<List<ExperimentalSpreadConfig>> getExperimentalSpreads() async {
    await Future.delayed(Duration(milliseconds: 100 + _random.nextInt(200)));

    // Filter spreads that haven't expired
    final now = DateTime.now();
    return _mockExperimentalSpreads
        .where((spread) => spread.experimentEndDate.isAfter(now))
        .toList();
  }

  @override
  Future<bool> enableExperimentalSpread(String spreadId) async {
    await Future.delayed(Duration(milliseconds: 100 + _random.nextInt(150)));

    final spread = _mockExperimentalSpreads.firstWhere(
      (s) => s.id == spreadId,
      orElse: () => throw const EarlyAccessException(
        message: 'Experimental spread not found',
        error: EarlyAccessError.featureNotFound,
      ),
    );

    if (spread.experimentEndDate.isBefore(DateTime.now())) {
      throw const EarlyAccessException(
        message: 'Experimental spread has expired',
        error: EarlyAccessError.featureNotAvailable,
      );
    }

    _enabledFeatures.add('experimental_spread_$spreadId');
    return true;
  }

  @override
  Future<bool> submitFeatureFeedback({
    required String featureId,
    required String feedback,
    int? rating,
  }) async {
    await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(300)));

    // Validate feature exists
    final featureExists =
        _mockFeatures.any((f) => f.id == featureId) ||
        _mockBetaGuides.any((g) => 'beta_guide_${g.id}' == featureId) ||
        _mockExperimentalSpreads.any(
          (s) => 'experimental_spread_${s.id}' == featureId,
        );

    if (!featureExists) {
      throw const EarlyAccessException(
        message: 'Feature not found for feedback',
        error: EarlyAccessError.featureNotFound,
      );
    }

    // Simulate occasional submission failures
    if (_random.nextDouble() < 0.03) {
      throw const EarlyAccessException(
        message: 'Failed to submit feedback',
        error: EarlyAccessError.feedbackSubmissionFailed,
      );
    }

    return true;
  }

  @override
  Future<List<EarlyAccessAnnouncement>> getAnnouncements({
    bool unreadOnly = false,
  }) async {
    await Future.delayed(Duration(milliseconds: 100 + _random.nextInt(200)));

    List<EarlyAccessAnnouncement> announcements = List.from(_mockAnnouncements);

    if (unreadOnly) {
      announcements = announcements
          .where(
            (announcement) =>
                !_readAnnouncements.containsKey(announcement.id) ||
                !_readAnnouncements[announcement.id]!,
          )
          .toList();
    } else {
      // Mark read status based on our tracking
      announcements = announcements
          .map(
            (announcement) => EarlyAccessAnnouncement(
              id: announcement.id,
              title: announcement.title,
              content: announcement.content,
              type: announcement.type,
              publishedAt: announcement.publishedAt,
              isRead: _readAnnouncements[announcement.id] ?? false,
              featureId: announcement.featureId,
              imageUrl: announcement.imageUrl,
            ),
          )
          .toList();
    }

    // Sort by published date, newest first
    announcements.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    return announcements;
  }

  @override
  Future<bool> markAnnouncementAsRead(String announcementId) async {
    await Future.delayed(const Duration(milliseconds: 100));

    _readAnnouncements[announcementId] = true;
    return true;
  }

  @override
  Future<EarlyAccessPreferences> getPreferences() async {
    await Future.delayed(Duration(milliseconds: 100 + _random.nextInt(150)));

    // Return mock preferences
    return const EarlyAccessPreferences(
      autoEnableStableFeatures: false,
      receiveAnnouncements: true,
      participateInFeedback: true,
      interestedFeatureTypes: [
        EarlyAccessFeatureType.guide,
        EarlyAccessFeatureType.spread,
        EarlyAccessFeatureType.theme,
      ],
      allowExperimentalFeatures: true,
    );
  }

  @override
  Future<bool> updatePreferences(EarlyAccessPreferences preferences) async {
    await Future.delayed(Duration(milliseconds: 150 + _random.nextInt(200)));

    // Simulate occasional update failures
    if (_random.nextDouble() < 0.02) {
      throw const EarlyAccessException(
        message: 'Failed to update preferences',
        error: EarlyAccessError.preferencesUpdateFailed,
      );
    }

    return true;
  }

  /// Gets statistics about early access participation
  Future<Map<String, dynamic>> getParticipationStats() async {
    await Future.delayed(Duration(milliseconds: 100 + _random.nextInt(150)));

    return {
      'enabled_features_count': _enabledFeatures.length,
      'available_features_count': _mockFeatures.length,
      'beta_guides_accessed': _enabledFeatures
          .where((f) => f.startsWith('beta_guide_'))
          .length,
      'experimental_spreads_tried': _enabledFeatures
          .where((f) => f.startsWith('experimental_spread_'))
          .length,
      'feedback_submitted_count': _random.nextInt(10) + 1,
      'unread_announcements':
          _mockAnnouncements.length - _readAnnouncements.length,
    };
  }

  /// Clears all enabled features (useful for testing)
  void clearEnabledFeatures() {
    _enabledFeatures.clear();
  }

  /// Marks all announcements as read (useful for testing)
  void markAllAnnouncementsAsRead() {
    for (final announcement in _mockAnnouncements) {
      _readAnnouncements[announcement.id] = true;
    }
  }
}
