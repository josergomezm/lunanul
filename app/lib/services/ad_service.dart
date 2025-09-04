import '../models/enums.dart';

/// Abstract service for managing advertisement display in the app
abstract class AdService {
  /// Initialize the ad service
  Future<void> initialize();

  /// Check if ads should be shown for the current user
  Future<bool> shouldShowAds();

  /// Load an ad for display after a reading
  Future<AdContent?> loadReadingAd({
    required ReadingTopic topic,
    required SpreadType spreadType,
  });

  /// Show an ad with the given content
  Future<void> showAd(AdContent adContent);

  /// Track ad impression for analytics
  Future<void> trackAdImpression(String adId);

  /// Track ad click for analytics
  Future<void> trackAdClick(String adId);

  /// Dispose of resources
  Future<void> dispose();
}

/// Represents ad content to be displayed
class AdContent {
  const AdContent({
    required this.id,
    required this.type,
    required this.content,
    this.imageUrl,
    this.actionUrl,
    this.displayDuration,
  });

  /// Unique identifier for the ad
  final String id;

  /// Type of advertisement
  final AdType type;

  /// Main content/text of the ad
  final String content;

  /// Optional image URL for visual ads
  final String? imageUrl;

  /// Optional action URL when ad is tapped
  final String? actionUrl;

  /// How long to display the ad (null for user-dismissible)
  final Duration? displayDuration;

  /// Convert to JSON for storage/transmission
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'content': content,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
      'displayDuration': displayDuration?.inMilliseconds,
    };
  }

  /// Create from JSON
  factory AdContent.fromJson(Map<String, dynamic> json) {
    return AdContent(
      id: json['id'] as String,
      type: AdType.fromString(json['type'] as String),
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      actionUrl: json['actionUrl'] as String?,
      displayDuration: json['displayDuration'] != null
          ? Duration(milliseconds: json['displayDuration'] as int)
          : null,
    );
  }
}

/// Types of advertisements supported
enum AdType {
  banner('Banner', 'Small banner advertisement'),
  interstitial('Interstitial', 'Full-screen advertisement'),
  native('Native', 'Content-integrated advertisement'),
  spiritual('Spiritual', 'Spirituality-focused content');

  const AdType(this.displayName, this.description);

  final String displayName;
  final String description;

  /// Convert from string to enum
  static AdType fromString(String value) {
    return AdType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => AdType.native,
    );
  }
}

/// Configuration for ad display behavior
class AdConfiguration {
  const AdConfiguration({
    this.enabledForFreeUsers = true,
    this.enabledForPaidUsers = false,
    this.maxAdsPerSession = 3,
    this.minTimeBetweenAds = const Duration(minutes: 5),
    this.respectDoNotTrack = true,
    this.preferredAdTypes = const [AdType.native, AdType.spiritual],
  });

  /// Whether ads are enabled for free tier users
  final bool enabledForFreeUsers;

  /// Whether ads are enabled for paid tier users
  final bool enabledForPaidUsers;

  /// Maximum number of ads to show per app session
  final int maxAdsPerSession;

  /// Minimum time between ad displays
  final Duration minTimeBetweenAds;

  /// Whether to respect user's Do Not Track preference
  final bool respectDoNotTrack;

  /// Preferred ad types in order of preference
  final List<AdType> preferredAdTypes;
}
