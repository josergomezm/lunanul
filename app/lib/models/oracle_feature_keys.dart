/// Feature keys for Oracle tier premium features
/// These constants are used by the feature gate service to control access
class OracleFeatureKeys {
  // Private constructor to prevent instantiation
  OracleFeatureKeys._();

  // Audio Reading Features
  static const String audioReadings = 'oracle.audio_readings';
  static const String audioCardInterpretation =
      'oracle.audio_card_interpretation';
  static const String audioSpreadInterpretation =
      'oracle.audio_spread_interpretation';
  static const String audioGuideVoices = 'oracle.audio_guide_voices';

  // Journal Prompt Features
  static const String personalizedJournalPrompts =
      'oracle.personalized_journal_prompts';
  static const String contextualPrompts = 'oracle.contextual_prompts';
  static const String followUpPrompts = 'oracle.follow_up_prompts';
  static const String thematicPrompts = 'oracle.thematic_prompts';
  static const String archetypePrompts = 'oracle.archetype_prompts';

  // Customization Features
  static const String premiumThemes = 'oracle.premium_themes';
  static const String customCardBacks = 'oracle.custom_card_backs';
  static const String accentColors = 'oracle.accent_colors';
  static const String animationStyles = 'oracle.animation_styles';
  static const String customThemeCreation = 'oracle.custom_theme_creation';
  static const String particleEffects = 'oracle.particle_effects';

  // Early Access Features
  static const String earlyAccess = 'oracle.early_access';
  static const String betaGuides = 'oracle.beta_guides';
  static const String experimentalSpreads = 'oracle.experimental_spreads';
  static const String betaFeatures = 'oracle.beta_features';
  static const String featureFeedback = 'oracle.feature_feedback';
  static const String earlyAnnouncements = 'oracle.early_announcements';

  // Advanced Spread Features
  static const String advancedSpreads = 'oracle.advanced_spreads';
  static const String specializedSpreads = 'oracle.specialized_spreads';
  static const String customSpreadCreation = 'oracle.custom_spread_creation';

  // AI Enhancement Features
  static const String aiJournalAnalysis = 'oracle.ai_journal_analysis';
  static const String patternRecognition = 'oracle.pattern_recognition';
  static const String personalizedInsights = 'oracle.personalized_insights';
  static const String advancedAiInterpretations =
      'oracle.advanced_ai_interpretations';

  /// Get all Oracle tier feature keys
  static List<String> get allFeatures => [
    audioReadings,
    audioCardInterpretation,
    audioSpreadInterpretation,
    audioGuideVoices,
    personalizedJournalPrompts,
    contextualPrompts,
    followUpPrompts,
    thematicPrompts,
    archetypePrompts,
    premiumThemes,
    customCardBacks,
    accentColors,
    animationStyles,
    customThemeCreation,
    particleEffects,
    earlyAccess,
    betaGuides,
    experimentalSpreads,
    betaFeatures,
    featureFeedback,
    earlyAnnouncements,
    advancedSpreads,
    specializedSpreads,
    customSpreadCreation,
    aiJournalAnalysis,
    patternRecognition,
    personalizedInsights,
    advancedAiInterpretations,
  ];

  /// Get audio-related feature keys
  static List<String> get audioFeatures => [
    audioReadings,
    audioCardInterpretation,
    audioSpreadInterpretation,
    audioGuideVoices,
  ];

  /// Get journal prompt-related feature keys
  static List<String> get journalPromptFeatures => [
    personalizedJournalPrompts,
    contextualPrompts,
    followUpPrompts,
    thematicPrompts,
    archetypePrompts,
  ];

  /// Get customization-related feature keys
  static List<String> get customizationFeatures => [
    premiumThemes,
    customCardBacks,
    accentColors,
    animationStyles,
    customThemeCreation,
    particleEffects,
  ];

  /// Get early access-related feature keys
  static List<String> get earlyAccessFeatures => [
    earlyAccess,
    betaGuides,
    experimentalSpreads,
    betaFeatures,
    featureFeedback,
    earlyAnnouncements,
  ];

  /// Check if a feature key is an Oracle tier feature
  static bool isOracleFeature(String featureKey) {
    return featureKey.startsWith('oracle.');
  }

  /// Get the feature category for a given feature key
  static String? getFeatureCategory(String featureKey) {
    if (audioFeatures.contains(featureKey)) {
      return 'Audio';
    } else if (journalPromptFeatures.contains(featureKey)) {
      return 'Journal Prompts';
    } else if (customizationFeatures.contains(featureKey)) {
      return 'Customization';
    } else if (earlyAccessFeatures.contains(featureKey)) {
      return 'Early Access';
    } else if (featureKey == advancedSpreads ||
        featureKey == specializedSpreads ||
        featureKey == customSpreadCreation) {
      return 'Advanced Spreads';
    } else if (featureKey == aiJournalAnalysis ||
        featureKey == patternRecognition ||
        featureKey == personalizedInsights ||
        featureKey == advancedAiInterpretations) {
      return 'AI Enhancement';
    }
    return null;
  }

  /// Get user-friendly display name for a feature key
  static String getDisplayName(String featureKey) {
    switch (featureKey) {
      case audioReadings:
        return 'Audio Readings';
      case audioCardInterpretation:
        return 'Audio Card Interpretation';
      case audioSpreadInterpretation:
        return 'Audio Spread Interpretation';
      case audioGuideVoices:
        return 'Guide Voice Synthesis';
      case personalizedJournalPrompts:
        return 'Personalized Journal Prompts';
      case contextualPrompts:
        return 'Contextual Reflection Questions';
      case followUpPrompts:
        return 'Follow-up Prompts';
      case thematicPrompts:
        return 'Thematic Prompts';
      case archetypePrompts:
        return 'Archetype-based Prompts';
      case premiumThemes:
        return 'Premium Themes';
      case customCardBacks:
        return 'Custom Card Backs';
      case accentColors:
        return 'Accent Colors';
      case animationStyles:
        return 'Animation Styles';
      case customThemeCreation:
        return 'Custom Theme Creation';
      case particleEffects:
        return 'Particle Effects';
      case earlyAccess:
        return 'Early Access Program';
      case betaGuides:
        return 'Beta Guides';
      case experimentalSpreads:
        return 'Experimental Spreads';
      case betaFeatures:
        return 'Beta Features';
      case featureFeedback:
        return 'Feature Feedback';
      case earlyAnnouncements:
        return 'Early Announcements';
      case advancedSpreads:
        return 'Advanced Spreads';
      case specializedSpreads:
        return 'Specialized Spreads';
      case customSpreadCreation:
        return 'Custom Spread Creation';
      case aiJournalAnalysis:
        return 'AI Journal Analysis';
      case patternRecognition:
        return 'Pattern Recognition';
      case personalizedInsights:
        return 'Personalized Insights';
      case advancedAiInterpretations:
        return 'Advanced AI Interpretations';
      default:
        return featureKey.split('.').last.replaceAll('_', ' ').toUpperCase();
    }
  }

  /// Get feature description for a feature key
  static String getDescription(String featureKey) {
    switch (featureKey) {
      case audioReadings:
        return 'AI-generated audio interpretations of your tarot readings';
      case personalizedJournalPrompts:
        return 'Contextual reflection questions based on your specific cards';
      case premiumThemes:
        return 'Exclusive app themes and visual customizations';
      case earlyAccess:
        return 'Early access to new features, guides, and experimental content';
      case advancedSpreads:
        return 'Specialized tarot spreads for advanced practitioners';
      case aiJournalAnalysis:
        return 'AI-powered analysis of your journal entries to identify patterns';
      default:
        return 'Premium Oracle tier feature';
    }
  }
}
