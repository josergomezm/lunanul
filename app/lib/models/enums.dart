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
