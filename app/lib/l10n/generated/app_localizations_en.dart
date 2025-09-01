// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Lunanul';

  @override
  String get homeTitle => 'Home';

  @override
  String get cardOfTheDay => 'Card of the Day';

  @override
  String get tapToReveal => 'Tap the card to reveal your daily guidance';

  @override
  String get recentReadings => 'Recent Readings';

  @override
  String get dailyReflection => 'Daily Reflection';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get welcome => 'Welcome';

  @override
  String get welcomeMessage =>
      'Welcome to your personal sanctuary of reflection and insight.';

  @override
  String get noReadingsYet => 'No readings yet';

  @override
  String get startReading => 'Start Reading';

  @override
  String get newCard => 'New Card';

  @override
  String get journal => 'Journal';

  @override
  String get viewAll => 'View All';

  @override
  String get reflect => 'Reflect';

  @override
  String get newPrompt => 'New prompt';

  @override
  String get drawingCard => 'Drawing your card...';

  @override
  String get loadingReadings => 'Loading readings...';

  @override
  String get unableToLoadCard => 'Unable to load your card';

  @override
  String get unableToLoadReadings => 'Unable to load readings';

  @override
  String get pleaseRetry => 'Please try again';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get startJourney => 'Start your journey with a new reading';

  @override
  String get fullHistoryComingSoon => 'Full history coming soon!';

  @override
  String get journalPageComingSoon => 'Journal page coming soon!';

  @override
  String get navigateToReadingsPage => 'Navigate to readings page';

  @override
  String get manualInterpretations => 'Manual Interpretations';

  @override
  String get inputPhysicalDeck =>
      'Input your physical deck draws for AI-enhanced insights';

  @override
  String get selectReadingContext => 'Select reading context';

  @override
  String get searchCardsHint => 'Search cards by name or keywords...';

  @override
  String get noCardsFound => 'No cards found';

  @override
  String get tryAdjustingSearch => 'Try adjusting your search or filter';

  @override
  String get selectCard => 'Select a Card';

  @override
  String get selectCardOrientation => 'Select Card Orientation';

  @override
  String get chooseCardPosition =>
      'Choose how this card appeared in your reading:';

  @override
  String get upright => 'Upright';

  @override
  String get reversed => 'Reversed';

  @override
  String get allCards => 'All';

  @override
  String get chooseAreaOfLife => 'Choose the area of life you want to explore';

  @override
  String get addYourCards => 'Add your cards';

  @override
  String get selectCardsFromDeck =>
      'Select the cards you drew from your physical deck';

  @override
  String get pleaseSelectContext => 'Please select a reading context first';

  @override
  String get addCardFromDeck => 'Add Card from Deck';

  @override
  String get clearAll => 'Clear All';

  @override
  String get saveReading => 'Save Reading';

  @override
  String get saveInterpretation => 'Save interpretation';

  @override
  String get startOver => 'Start over';

  @override
  String get selectedCards => 'Selected Cards';

  @override
  String get noCardsSelected => 'No cards selected';

  @override
  String get editPositionName => 'Edit Position Name';

  @override
  String get positionName => 'Position Name';

  @override
  String get positionNameHint => 'e.g., Past, Present, Future';

  @override
  String get cardConnections => 'Card Connections';

  @override
  String get recentManualInterpretations => 'Recent Manual Interpretations';

  @override
  String get noManualInterpretations => 'No manual interpretations yet';

  @override
  String get addCardsToGetStarted =>
      'Add cards from your physical deck to get started';

  @override
  String get interpretationDetailsComingSoon =>
      'Interpretation details coming soon';

  @override
  String get failedToLoadInterpretations => 'Failed to load interpretations';

  @override
  String get saveInterpretationDialog => 'Save Interpretation';

  @override
  String get saveInterpretationQuestion =>
      'Save this manual interpretation to your journal?';

  @override
  String get personalNotes => 'Personal notes (optional)';

  @override
  String get addThoughts => 'Add your thoughts about this reading...';

  @override
  String get interpretationSaved => 'Interpretation saved to journal';

  @override
  String get failedToSave => 'Failed to save';

  @override
  String get navigationHome => 'Home';

  @override
  String get navigationReadings => 'Readings';

  @override
  String get navigationManual => 'Manual';

  @override
  String get navigationYourself => 'Yourself';

  @override
  String get navigationFriends => 'Friends';

  @override
  String get readingDetails => 'Reading Details';

  @override
  String get yourReflection => 'Your Reflection';

  @override
  String get readingStatistics => 'Reading Statistics';

  @override
  String get majorArcana => 'Major Arcana';

  @override
  String get suits => 'Suits';

  @override
  String get share => 'Share';

  @override
  String get delete => 'Delete';

  @override
  String get imageUnavailable => 'Image unavailable';

  @override
  String get removeFriend => 'Remove Friend';

  @override
  String removeFriendConfirm(String friendName) {
    return 'Are you sure you want to remove $friendName from your friends?';
  }

  @override
  String get remove => 'Remove';

  @override
  String get activeNow => 'Active now';

  @override
  String activeMinutesAgo(int minutes) {
    return 'Active ${minutes}m ago';
  }

  @override
  String activeHoursAgo(int hours) {
    return 'Active ${hours}h ago';
  }

  @override
  String get activeYesterday => 'Active yesterday';

  @override
  String activeDaysAgo(int days) {
    return 'Active $days days ago';
  }

  @override
  String get today => 'today';

  @override
  String get yesterday => 'yesterday';

  @override
  String daysAgo(int days) {
    return '$days days ago';
  }

  @override
  String get startConversation => 'Start the conversation';

  @override
  String get shareThoughts =>
      'Share your thoughts about this reading with your friend';

  @override
  String get spreadPast => 'Past';

  @override
  String get spreadPresent => 'Present';

  @override
  String get spreadFuture => 'Future';

  @override
  String get spreadYou => 'You';

  @override
  String get spreadThem => 'Them';

  @override
  String get spreadConnection => 'Connection';

  @override
  String get spreadCurrentSituation => 'Current Situation';

  @override
  String get spreadStrengths => 'Strengths';

  @override
  String get spreadChallenges => 'Challenges';

  @override
  String get topicSelf => 'Self';

  @override
  String get topicLove => 'Love';

  @override
  String get topicWork => 'Work';

  @override
  String get topicSocial => 'Social';

  @override
  String get topicSelfDescription => 'Personal growth and self-discovery';

  @override
  String get topicLoveDescription => 'Relationships and emotional connections';

  @override
  String get topicWorkDescription => 'Career and professional life';

  @override
  String get topicSocialDescription => 'Community and social interactions';

  @override
  String get readingJournal => 'Reading Journal';

  @override
  String get searchReadings => 'Search readings...';

  @override
  String get all => 'All';

  @override
  String get noReadingsFound => 'No readings found';

  @override
  String get tryAdjustingFilters => 'Try adjusting your search or filters';

  @override
  String get noJournalEntries => 'No journal entries yet';

  @override
  String get saveReadingsToStart =>
      'Save readings to start building your journal';

  @override
  String get createReading => 'Create Reading';

  @override
  String get unableToLoadJournal => 'Unable to load journal';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get deleteReading => 'Delete Reading';

  @override
  String deleteReadingConfirm(String title) {
    return 'Are you sure you want to delete \"$title\"? This action cannot be undone.';
  }

  @override
  String get readingDeletedSuccess => 'Reading deleted successfully';

  @override
  String get failedToDeleteReading => 'Failed to delete reading';

  @override
  String get friends => 'Friends';

  @override
  String get addFriend => 'Add Friend';

  @override
  String get shareYourJourney => 'Share your journey';

  @override
  String get connectWithFriends =>
      'Connect with trusted friends and share meaningful readings';

  @override
  String get yourFriends => 'Your Friends';

  @override
  String get noFriendsYet => 'No friends yet';

  @override
  String get addFriendsToShare =>
      'Add friends to share your tarot journey privately';

  @override
  String get addYourFirstFriend => 'Add Your First Friend';

  @override
  String get errorLoadingFriends => 'Error loading friends';

  @override
  String get sharedReadings => 'Shared Readings';

  @override
  String get noSharedReadings => 'No shared readings';

  @override
  String get shareReadingsFromJournal =>
      'Share readings from your journal to start conversations';

  @override
  String get errorLoadingSharedReadings => 'Error loading shared readings';

  @override
  String get errorLoadingUserData => 'Error loading user data';

  @override
  String get privacySafety => 'Privacy & Safety';

  @override
  String get privacyInfo =>
      '• Friends can only be added through private invitation codes\n• You control what readings to share\n• All conversations are private between you and your friend\n• You can remove friends at any time';

  @override
  String get chooseHowToConnect => 'Choose how to connect with your friend:';

  @override
  String get shareInvitationCode => 'Share Invitation Code';

  @override
  String get enterFriendsCode => 'Enter Friend\'s Code';

  @override
  String get yourInvitationCode => 'Your Invitation Code';

  @override
  String get shareThisCode => 'Share this code with your friend:';

  @override
  String get copyCode => 'Copy Code';

  @override
  String get codeCopiedToClipboard => 'Code copied to clipboard';

  @override
  String errorGeneratingCode(String error) {
    return 'Error generating code: $error';
  }

  @override
  String get done => 'Done';

  @override
  String get codeUniqueToYou =>
      'This code is unique to you and can be used multiple times';

  @override
  String get enterFriendsCodeDialog => 'Enter Friend\'s Code';

  @override
  String get enterInvitationCode =>
      'Enter the invitation code your friend shared:';

  @override
  String get invitationCode => 'Invitation Code';

  @override
  String get invitationCodeHint => 'LUNA-1234-ABC567';

  @override
  String get sendRequest => 'Send Request';

  @override
  String get pleaseEnterCode => 'Please enter an invitation code';

  @override
  String get sendingFriendRequest => 'Sending friend request...';

  @override
  String get friendRequestSentSuccess => 'Friend request sent successfully!';

  @override
  String failedToSendFriendRequest(String error) {
    return 'Failed to send friend request: $error';
  }

  @override
  String friendRemovedSuccess(String name) {
    return '$name removed from friends';
  }

  @override
  String failedToRemoveFriend(String error) {
    return 'Failed to remove friend: $error';
  }

  @override
  String get readings => 'Readings';

  @override
  String get chooseTopicForReading => 'Choose a topic for your reading';

  @override
  String get aiPoweredInsights =>
      'Let the cards guide you with AI-powered insights';

  @override
  String get recentSavedReadings => 'Recent Saved Readings';

  @override
  String get navigateToYourselfPage =>
      'Navigate to Yourself page to see all readings';

  @override
  String get noSavedReadingsYet => 'No saved readings yet';

  @override
  String get completeReadingToSee =>
      'Complete a reading above and save it to see it here';

  @override
  String get saveReadingDialog => 'Save Reading';

  @override
  String get addThoughtsOptional =>
      'Add your thoughts about this reading (optional)...';

  @override
  String get saving => 'Saving...';

  @override
  String get readingSavedToJournal => 'Reading saved to your journal';

  @override
  String get failedToSaveReading => 'Failed to save reading';

  @override
  String get saved => 'Saved';

  @override
  String get alreadySaved => 'Already saved';

  @override
  String get readingSaved => 'Reading saved';

  @override
  String get shareReading => 'Share Reading';

  @override
  String cardsSpread(int count, String spread) {
    return '$count cards • $spread';
  }

  @override
  String get chooseFriendToShare => 'Choose a friend to share with:';

  @override
  String get noFriendsToShareWith => 'No friends to share with';

  @override
  String get addFriendsToStartSharing =>
      'Add friends to start sharing readings';

  @override
  String get sharingReading => 'Sharing reading...';

  @override
  String readingSharedWith(String name) {
    return 'Reading shared with $name';
  }

  @override
  String failedToShareReading(String error) {
    return 'Failed to share reading: $error';
  }

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageSelection => 'Language Selection';

  @override
  String get chooseLanguage => 'Choose your preferred language';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Español';

  @override
  String currentLanguage(String language) {
    return 'Current language: $language';
  }

  @override
  String languageChanged(String language) {
    return 'Language changed to $language';
  }

  @override
  String get yourTarotJourney => 'Your tarot journey';

  @override
  String get reflectOnReadings =>
      'Reflect on your readings and explore the cards';

  @override
  String get yourJourney => 'Your Journey';

  @override
  String get totalReadings => 'Total Readings';

  @override
  String get thisWeek => 'This Week';

  @override
  String get favoriteTopic => 'Favorite Topic';

  @override
  String get none => 'None';

  @override
  String get readingJournalDescription =>
      'View and reflect on your saved readings';

  @override
  String get cardEncyclopedia => 'Card Encyclopedia';

  @override
  String get cardEncyclopediaDescription => 'Learn about all 78 tarot cards';

  @override
  String get readingPatterns => 'Reading Patterns';

  @override
  String get readingPatternsDescription =>
      'Discover recurring themes and cards';

  @override
  String get settingsDescription => 'Language preferences and app settings';

  @override
  String get recentJournalEntries => 'Recent Journal Entries';

  @override
  String get noJournalEntriesYet => 'No journal entries yet';

  @override
  String get saveReadingsToBuildJournal =>
      'Save readings to start building your journal';

  @override
  String cardsCount(int count) {
    return '$count cards';
  }

  @override
  String get unableToLoadStats => 'Unable to load stats';

  @override
  String get unableToLoadJournalEntries => 'Unable to load journal entries';

  @override
  String get chooseYourSpread => 'Choose Your Spread';

  @override
  String get selectSpreadType =>
      'Select the type of reading that resonates with your question';

  @override
  String get selectASpread => 'Select a Spread';

  @override
  String startSpreadReading(String spreadName) {
    return 'Start $spreadName Reading';
  }

  @override
  String get shufflingCards => 'Shuffling the cards...';

  @override
  String get universePreparingReading =>
      'The universe is preparing your reading';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get unableToCreateReading =>
      'Unable to create your reading. Please try again.';

  @override
  String get goBack => 'Go Back';

  @override
  String get cardsBeingDealt => 'Cards are being dealt...';

  @override
  String get watchCardsPlaced =>
      'Watch as your cards are placed in their positions';

  @override
  String get tapToRevealCards => 'Tap to reveal your cards';

  @override
  String get touchCardWhenReady =>
      'Touch each card when you\'re ready to see its message';

  @override
  String get yourReading => 'Your Reading';

  @override
  String get saveToJournal => 'Save to Journal';

  @override
  String get newReading => 'New Reading';
}
