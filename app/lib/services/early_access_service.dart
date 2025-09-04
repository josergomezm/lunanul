/// Service interface for managing Oracle tier early access features
/// Provides access to beta features, new guides, and experimental functionality
abstract class EarlyAccessService {
  /// Gets all available early access features for the current user
  ///
  /// Returns a list of early access features available to Oracle subscribers
  Future<List<EarlyAccessFeature>> getAvailableFeatures();

  /// Gets features that are currently enabled for the user
  ///
  /// Returns a list of enabled early access features
  Future<List<EarlyAccessFeature>> getEnabledFeatures();

  /// Enables an early access feature for the user
  ///
  /// [featureId] - The ID of the feature to enable
  ///
  /// Returns true if the feature was successfully enabled
  Future<bool> enableFeature(String featureId);

  /// Disables an early access feature for the user
  ///
  /// [featureId] - The ID of the feature to disable
  ///
  /// Returns true if the feature was successfully disabled
  Future<bool> disableFeature(String featureId);

  /// Checks if a specific early access feature is available
  ///
  /// [featureId] - The ID of the feature to check
  ///
  /// Returns true if the feature is available for early access
  Future<bool> isFeatureAvailable(String featureId);

  /// Checks if a specific early access feature is enabled for the user
  ///
  /// [featureId] - The ID of the feature to check
  ///
  /// Returns true if the feature is currently enabled
  Future<bool> isFeatureEnabled(String featureId);

  /// Gets beta guides that are available for early access
  ///
  /// Returns a list of beta guide configurations
  Future<List<BetaGuideConfig>> getBetaGuides();

  /// Enables access to a beta guide
  ///
  /// [guideId] - The ID of the beta guide to enable
  ///
  /// Returns true if access was successfully granted
  Future<bool> enableBetaGuide(String guideId);

  /// Gets experimental spreads available for testing
  ///
  /// Returns a list of experimental spread configurations
  Future<List<ExperimentalSpreadConfig>> getExperimentalSpreads();

  /// Enables access to an experimental spread
  ///
  /// [spreadId] - The ID of the experimental spread to enable
  ///
  /// Returns true if access was successfully granted
  Future<bool> enableExperimentalSpread(String spreadId);

  /// Submits feedback for an early access feature
  ///
  /// [featureId] - The ID of the feature being reviewed
  /// [feedback] - User feedback about the feature
  /// [rating] - Optional rating (1-5 stars)
  ///
  /// Returns true if feedback was successfully submitted
  Future<bool> submitFeatureFeedback({
    required String featureId,
    required String feedback,
    int? rating,
  });

  /// Gets announcements about new early access features
  ///
  /// [unreadOnly] - Whether to return only unread announcements
  ///
  /// Returns a list of early access announcements
  Future<List<EarlyAccessAnnouncement>> getAnnouncements({
    bool unreadOnly = false,
  });

  /// Marks an announcement as read
  ///
  /// [announcementId] - The ID of the announcement to mark as read
  ///
  /// Returns true if the announcement was successfully marked as read
  Future<bool> markAnnouncementAsRead(String announcementId);

  /// Gets the user's early access preferences
  ///
  /// Returns the current early access preferences
  Future<EarlyAccessPreferences> getPreferences();

  /// Updates the user's early access preferences
  ///
  /// [preferences] - The new preferences to save
  ///
  /// Returns true if preferences were successfully updated
  Future<bool> updatePreferences(EarlyAccessPreferences preferences);
}

/// Configuration for early access features
class EarlyAccessFeature {
  final String id;
  final String name;
  final String description;
  final EarlyAccessFeatureType type;
  final DateTime availableFrom;
  final DateTime? availableUntil;
  final bool isStable;
  final String version;
  final List<String> requirements;
  final Map<String, dynamic> configuration;

  const EarlyAccessFeature({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.availableFrom,
    this.availableUntil,
    this.isStable = false,
    required this.version,
    this.requirements = const [],
    this.configuration = const {},
  });
}

/// Configuration for beta guides
class BetaGuideConfig {
  final String id;
  final String name;
  final String description;
  final String personality;
  final String specialty;
  final String avatarUrl;
  final bool isAvailable;
  final DateTime releaseDate;
  final List<String> betaFeatures;

  const BetaGuideConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.personality,
    required this.specialty,
    required this.avatarUrl,
    this.isAvailable = true,
    required this.releaseDate,
    this.betaFeatures = const [],
  });
}

/// Configuration for experimental spreads
class ExperimentalSpreadConfig {
  final String id;
  final String name;
  final String description;
  final int cardCount;
  final List<String> positions;
  final String difficulty;
  final bool requiresFeedback;
  final DateTime experimentEndDate;

  const ExperimentalSpreadConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.cardCount,
    required this.positions,
    this.difficulty = 'intermediate',
    this.requiresFeedback = true,
    required this.experimentEndDate,
  });
}

/// Early access announcements
class EarlyAccessAnnouncement {
  final String id;
  final String title;
  final String content;
  final EarlyAccessAnnouncementType type;
  final DateTime publishedAt;
  final bool isRead;
  final String? featureId;
  final String? imageUrl;

  const EarlyAccessAnnouncement({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.publishedAt,
    this.isRead = false,
    this.featureId,
    this.imageUrl,
  });
}

/// User preferences for early access
class EarlyAccessPreferences {
  final bool autoEnableStableFeatures;
  final bool receiveAnnouncements;
  final bool participateInFeedback;
  final List<EarlyAccessFeatureType> interestedFeatureTypes;
  final bool allowExperimentalFeatures;

  const EarlyAccessPreferences({
    this.autoEnableStableFeatures = false,
    this.receiveAnnouncements = true,
    this.participateInFeedback = true,
    this.interestedFeatureTypes = const [],
    this.allowExperimentalFeatures = false,
  });
}

/// Types of early access features
enum EarlyAccessFeatureType {
  guide,
  spread,
  theme,
  animation,
  integration,
  ai,
  customization,
  analytics,
}

/// Types of early access announcements
enum EarlyAccessAnnouncementType {
  newFeature,
  featureUpdate,
  betaRelease,
  feedbackRequest,
  graduation,
}

/// Exception thrown when early access operations fail
class EarlyAccessException implements Exception {
  final String message;
  final EarlyAccessError error;
  final dynamic originalError;

  const EarlyAccessException({
    required this.message,
    required this.error,
    this.originalError,
  });

  @override
  String toString() => 'EarlyAccessException: $message';
}

/// Types of early access errors
enum EarlyAccessError {
  featureNotFound,
  featureNotAvailable,
  subscriptionRequired,
  networkError,
  configurationError,
  feedbackSubmissionFailed,
  preferencesUpdateFailed,
}
