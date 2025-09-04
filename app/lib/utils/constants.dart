/// App-wide constants for Lunanul
class AppConstants {
  // App Information
  static const String appName = 'Lunanul';
  static const String appDescription = 'Your gentle tarot companion';

  // Navigation
  static const String homeRoute = '/';
  static const String readingsRoute = '/readings';
  static const String guideSelectionRoute = '/guide-selection';
  static const String spreadSelectionRoute = '/spread-selection';
  static const String interpretationsRoute = '/interpretations';
  static const String yourselfRoute = '/yourself';
  static const String friendsRoute = '/friends';
  static const String settingsRoute = '/settings';
  static const String subscriptionManagementRoute = '/subscription-management';

  // Storage Keys
  static const String userPrefsKey = 'user_preferences';
  static const String savedReadingsKey = 'saved_readings';
  static const String cardOfTheDayKey = 'card_of_the_day';

  // API Configuration (for future backend integration)
  static const String baseApiUrl = 'https://api.lunanul.com';
  static const String cardsImageBaseUrl = 'https://api.lunanul.com/cards';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double cardAspectRatio =
      0.6; // Width/Height ratio for tarot cards
  static const int animationDurationMs = 300;

  // Tarot Deck
  static const int totalCards = 78;
  static const int majorArcanaCount = 22;
  static const int minorArcanaCount = 56;
}
