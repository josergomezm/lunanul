/// Constants for subscription feature keys used throughout the app
class SubscriptionFeatures {
  // Private constructor to prevent instantiation
  SubscriptionFeatures._();

  // Reading Features
  /// Access to AI-generated tarot readings
  static const String aiReadings = 'ai_readings';

  /// Access to single card spreads
  static const String singleCardSpread = 'single_card_spread';

  /// Access to three card spreads
  static const String threeCardSpread = 'three_card_spread';

  /// Access to Celtic Cross spread (10 cards)
  static const String celticCrossSpread = 'celtic_cross_spread';

  /// Access to relationship spread (5 cards)
  static const String relationshipSpread = 'relationship_spread';

  /// Access to career path spread (7 cards)
  static const String careerSpread = 'career_spread';

  /// Access to advanced/specialized spreads
  static const String advancedSpreads = 'advanced_spreads';

  // Guide Features
  /// Access to Lyra - The Compassionate Healer
  static const String healerGuide = 'healer_guide';

  /// Access to Kael - The Practical Strategist
  static const String mentorGuide = 'mentor_guide';

  /// Access to Zian - The Wise Mystic
  static const String sageGuide = 'sage_guide';

  /// Access to Elara - The Creative Muse
  static const String visionaryGuide = 'visionary_guide';

  // Journal Features
  /// Ability to save readings to journal
  static const String journalSaving = 'journal_saving';

  /// Unlimited journal storage
  static const String unlimitedJournal = 'unlimited_journal';

  /// Personalized journal prompts (Oracle tier)
  static const String personalizedPrompts = 'personalized_prompts';

  // Manual Interpretation Features
  /// Access to manual card interpretations
  static const String manualInterpretations = 'manual_interpretations';

  /// Unlimited manual interpretations
  static const String unlimitedManualInterpretations =
      'unlimited_manual_interpretations';

  // Premium Features
  /// Ad-free experience
  static const String adFree = 'ad_free';

  /// AI-generated audio readings
  static const String audioReadings = 'audio_readings';

  /// Custom themes and app appearance
  static const String customThemes = 'custom_themes';

  /// Custom tarot card backs
  static const String customCardBacks = 'custom_card_backs';

  /// Early access to new features
  static const String earlyAccess = 'early_access';

  // Daily Features
  /// Access to daily card feature (always free)
  static const String dailyCard = 'daily_card';

  // Usage Tracking Keys
  /// Key for tracking manual interpretation usage
  static const String manualInterpretationUsage = 'manual_interpretations';

  /// Key for tracking journal entry usage
  static const String journalEntryUsage = 'journal_entries';

  // Feature Categories
  /// All reading-related features
  static const List<String> readingFeatures = [
    aiReadings,
    singleCardSpread,
    threeCardSpread,
    celticCrossSpread,
    relationshipSpread,
    careerSpread,
    advancedSpreads,
  ];

  /// All guide-related features
  static const List<String> guideFeatures = [
    healerGuide,
    mentorGuide,
    sageGuide,
    visionaryGuide,
  ];

  /// All journal-related features
  static const List<String> journalFeatures = [
    journalSaving,
    unlimitedJournal,
    personalizedPrompts,
  ];

  /// All premium features (Oracle tier only)
  static const List<String> premiumFeatures = [
    audioReadings,
    customThemes,
    customCardBacks,
    earlyAccess,
    personalizedPrompts,
    advancedSpreads,
  ];

  /// Features that have usage limits for free tier
  static const List<String> limitedFeatures = [
    manualInterpretations,
    journalSaving,
  ];

  /// Features that are always free
  static const List<String> freeFeatures = [
    dailyCard,
    singleCardSpread,
    threeCardSpread,
    healerGuide,
    mentorGuide,
  ];

  /// Get all feature keys
  static List<String> getAllFeatures() {
    return <String>{
      ...readingFeatures,
      ...guideFeatures,
      ...journalFeatures,
      ...premiumFeatures,
      manualInterpretations,
      unlimitedManualInterpretations,
      adFree,
      dailyCard,
    }.toList(); // Remove duplicates
  }

  /// Get features available for a specific tier
  static List<String> getFeaturesForTier(String tier) {
    switch (tier.toLowerCase()) {
      case 'seeker':
        return [
          dailyCard,
          singleCardSpread,
          threeCardSpread,
          healerGuide,
          mentorGuide,
          journalSaving, // limited to 3 entries
          manualInterpretations, // limited to 5 per month
        ];
      case 'mystic':
        return [
          ...freeFeatures,
          celticCrossSpread,
          relationshipSpread,
          careerSpread,
          sageGuide,
          visionaryGuide,
          unlimitedJournal,
          unlimitedManualInterpretations,
          adFree,
        ];
      case 'oracle':
        return getAllFeatures();
      default:
        return freeFeatures;
    }
  }

  /// Check if a feature is premium (requires paid subscription)
  static bool isPremiumFeature(String feature) {
    return !freeFeatures.contains(feature);
  }

  /// Check if a feature has usage limits
  static bool hasUsageLimit(String feature) {
    return limitedFeatures.contains(feature);
  }

  /// Get the display name for a feature
  static String getFeatureDisplayName(String feature) {
    switch (feature) {
      case aiReadings:
        return 'AI Readings';
      case singleCardSpread:
        return 'Single Card Spread';
      case threeCardSpread:
        return 'Three Card Spread';
      case celticCrossSpread:
        return 'Celtic Cross Spread';
      case relationshipSpread:
        return 'Relationship Spread';
      case careerSpread:
        return 'Career Path Spread';
      case advancedSpreads:
        return 'Advanced Spreads';
      case healerGuide:
        return 'Lyra - The Healer';
      case mentorGuide:
        return 'Kael - The Mentor';
      case sageGuide:
        return 'Zian - The Sage';
      case visionaryGuide:
        return 'Elara - The Visionary';
      case journalSaving:
        return 'Journal Saving';
      case unlimitedJournal:
        return 'Unlimited Journal';
      case personalizedPrompts:
        return 'Personalized Prompts';
      case manualInterpretations:
        return 'Manual Interpretations';
      case unlimitedManualInterpretations:
        return 'Unlimited Manual Interpretations';
      case adFree:
        return 'Ad-Free Experience';
      case audioReadings:
        return 'Audio Readings';
      case customThemes:
        return 'Custom Themes';
      case customCardBacks:
        return 'Custom Card Backs';
      case earlyAccess:
        return 'Early Access';
      case dailyCard:
        return 'Daily Card';
      default:
        return feature
            .replaceAll('_', ' ')
            .split(' ')
            .map(
              (word) =>
                  word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1),
            )
            .join(' ');
    }
  }

  /// Get the description for a feature
  static String getFeatureDescription(String feature) {
    switch (feature) {
      case aiReadings:
        return 'Get personalized AI-generated tarot readings';
      case singleCardSpread:
        return 'Quick single card readings for immediate guidance';
      case threeCardSpread:
        return 'Past, Present, Future or Situation, Action, Outcome readings';
      case celticCrossSpread:
        return 'Comprehensive 10-card reading for complex situations';
      case relationshipSpread:
        return 'Specialized 5-card spread focused on relationships';
      case careerSpread:
        return '7-card spread for career and professional guidance';
      case advancedSpreads:
        return 'Access to specialized and advanced tarot spreads';
      case healerGuide:
        return 'Compassionate guidance focused on emotional healing';
      case mentorGuide:
        return 'Practical advice and actionable strategies';
      case sageGuide:
        return 'Deep spiritual insight and universal patterns';
      case visionaryGuide:
        return 'Creative inspiration and visionary possibilities';
      case journalSaving:
        return 'Save your readings for future reflection';
      case unlimitedJournal:
        return 'Save unlimited readings to your personal journal';
      case personalizedPrompts:
        return 'AI-generated reflection questions based on your readings';
      case manualInterpretations:
        return 'Look up individual card meanings and interpretations';
      case unlimitedManualInterpretations:
        return 'Unlimited access to card meanings and interpretations';
      case adFree:
        return 'Enjoy a completely ad-free tarot experience';
      case audioReadings:
        return 'Listen to AI-generated audio interpretations';
      case customThemes:
        return 'Personalize your app with custom color themes';
      case customCardBacks:
        return 'Choose from multiple digital tarot card designs';
      case earlyAccess:
        return 'Be the first to try new features and guides';
      case dailyCard:
        return 'Daily card of the day for spiritual guidance';
      default:
        return 'Premium feature available with subscription';
    }
  }
}
