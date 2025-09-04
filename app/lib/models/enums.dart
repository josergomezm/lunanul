// Enums for the Lunanul tarot app

/// Topics available for tarot readings
enum ReadingTopic {
  self('Self', 'Personal growth and self-reflection'),
  love('Love', 'Relationships and romantic connections'),
  work('Work', 'Career and professional matters'),
  social('Social', 'Friendships and social connections');

  const ReadingTopic(this.displayName, this.description);

  final String displayName;
  final String description;

  /// Convert from string to enum
  static ReadingTopic fromString(String value) {
    return ReadingTopic.values.firstWhere(
      (topic) => topic.name == value,
      orElse: () => ReadingTopic.self,
    );
  }
}

/// Types of tarot spreads available
enum SpreadType {
  singleCard('Single Card', 1, 'Quick insight for immediate guidance'),
  threeCard(
    'Three Card',
    3,
    'Past, Present, Future or Situation, Action, Outcome',
  ),
  celtic('Celtic Cross', 10, 'Comprehensive reading for complex situations'),
  celticCross(
    'Celtic Cross',
    10,
    'Comprehensive reading for complex situations',
  ), // Alias for backward compatibility
  horseshoe('Horseshoe', 7, 'Seven-card spread for guidance and outcomes'),
  relationship('Relationship', 5, 'Focused on relationship dynamics'),
  career('Career Path', 7, 'Professional guidance and career decisions');

  const SpreadType(this.displayName, this.cardCount, this.description);

  final String displayName;
  final int cardCount;
  final String description;

  /// Get spreads available for a specific topic
  static List<SpreadType> getSpreadsByTopic(ReadingTopic topic) {
    switch (topic) {
      case ReadingTopic.self:
        return [SpreadType.singleCard, SpreadType.threeCard, SpreadType.celtic];
      case ReadingTopic.love:
        return [
          SpreadType.singleCard,
          SpreadType.threeCard,
          SpreadType.relationship,
        ];
      case ReadingTopic.work:
        return [SpreadType.singleCard, SpreadType.threeCard, SpreadType.career];
      case ReadingTopic.social:
        return [
          SpreadType.singleCard,
          SpreadType.threeCard,
          SpreadType.relationship,
        ];
    }
  }

  /// Convert from string to enum
  static SpreadType fromString(String value) {
    return SpreadType.values.firstWhere(
      (spread) => spread.name == value,
      orElse: () => SpreadType.singleCard,
    );
  }
}

/// Tarot card suits
enum TarotSuit {
  majorArcana('Major Arcana', 'The major life themes and spiritual lessons'),
  cups('Cups', 'Emotions, relationships, and intuition'),
  wands('Wands', 'Creativity, passion, and career'),
  swords('Swords', 'Thoughts, communication, and challenges'),
  pentacles('Pentacles', 'Material matters, money, and health');

  const TarotSuit(this.displayName, this.description);

  final String displayName;
  final String description;

  /// Convert from string to enum
  static TarotSuit fromString(String value) {
    return TarotSuit.values.firstWhere(
      (suit) => suit.name == value,
      orElse: () => TarotSuit.majorArcana,
    );
  }
}

/// Status of friend connections
enum FriendshipStatus {
  pending('Pending', 'Invitation sent, awaiting response'),
  accepted('Connected', 'Active friendship connection'),
  blocked('Blocked', 'User has been blocked');

  const FriendshipStatus(this.displayName, this.description);

  final String displayName;
  final String description;

  /// Convert from string to enum
  static FriendshipStatus fromString(String value) {
    return FriendshipStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => FriendshipStatus.pending,
    );
  }
}

/// Types of tarot guide personalities available
enum GuideType {
  sage(
    'Zian',
    'The Wise Mystic',
    'Deep spiritual insight and universal patterns',
  ),
  healer(
    'Lyra',
    'The Compassionate Healer',
    'Emotional healing and self-compassion',
  ),
  mentor(
    'Kael',
    'The Practical Strategist',
    'Clear guidance and actionable advice',
  ),
  visionary(
    'Elara',
    'The Creative Muse',
    'Inspiration and creative possibilities',
  );

  const GuideType(this.guideName, this.title, this.expertise);

  final String guideName;
  final String title;
  final String expertise;

  /// Convert from string to enum
  static GuideType fromString(String value) {
    return GuideType.values.firstWhere(
      (guide) => guide.name == value,
      orElse: () => GuideType.sage,
    );
  }

  /// Get recommended guides for a specific reading topic
  static List<GuideType> getRecommendedForTopic(ReadingTopic topic) {
    switch (topic) {
      case ReadingTopic.self:
        return [GuideType.sage, GuideType.healer];
      case ReadingTopic.love:
        return [GuideType.healer, GuideType.visionary];
      case ReadingTopic.work:
        return [GuideType.mentor, GuideType.sage];
      case ReadingTopic.social:
        return [GuideType.healer, GuideType.mentor];
    }
  }
}

/// Subscription tiers available in the app
enum SubscriptionTier {
  seeker('Seeker', 'Free', 'Essential daily tarot experience'),
  mystic('Mystic', '\$4.99/month', 'Complete tarot experience without limits'),
  oracle(
    'Oracle',
    '\$9.99/month',
    'Premium features and advanced capabilities',
  );

  const SubscriptionTier(this.displayName, this.price, this.description);

  final String displayName;
  final String price;
  final String description;

  /// Convert from string to enum
  static SubscriptionTier fromString(String value) {
    return SubscriptionTier.values.firstWhere(
      (tier) => tier.name == value,
      orElse: () => SubscriptionTier.seeker,
    );
  }

  /// Check if this tier is paid
  bool get isPaid => this != SubscriptionTier.seeker;

  /// Check if this tier has premium features
  bool get hasPremiumFeatures => this == SubscriptionTier.oracle;
}
