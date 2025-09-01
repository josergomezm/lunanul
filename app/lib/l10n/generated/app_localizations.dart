import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'Lunanul'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @cardOfTheDay.
  ///
  /// In en, this message translates to:
  /// **'Card of the Day'**
  String get cardOfTheDay;

  /// No description provided for @tapToReveal.
  ///
  /// In en, this message translates to:
  /// **'Tap the card to reveal your daily guidance'**
  String get tapToReveal;

  /// No description provided for @recentReadings.
  ///
  /// In en, this message translates to:
  /// **'Recent Readings'**
  String get recentReadings;

  /// No description provided for @dailyReflection.
  ///
  /// In en, this message translates to:
  /// **'Daily Reflection'**
  String get dailyReflection;

  /// Morning greeting
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// Afternoon greeting
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// Evening greeting
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome to your personal sanctuary of reflection and insight.'**
  String get welcomeMessage;

  /// No description provided for @noReadingsYet.
  ///
  /// In en, this message translates to:
  /// **'No readings yet'**
  String get noReadingsYet;

  /// No description provided for @startReading.
  ///
  /// In en, this message translates to:
  /// **'Start Reading'**
  String get startReading;

  /// No description provided for @newCard.
  ///
  /// In en, this message translates to:
  /// **'New Card'**
  String get newCard;

  /// No description provided for @journal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get journal;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @reflect.
  ///
  /// In en, this message translates to:
  /// **'Reflect'**
  String get reflect;

  /// No description provided for @newPrompt.
  ///
  /// In en, this message translates to:
  /// **'New prompt'**
  String get newPrompt;

  /// No description provided for @drawingCard.
  ///
  /// In en, this message translates to:
  /// **'Drawing your card...'**
  String get drawingCard;

  /// No description provided for @loadingReadings.
  ///
  /// In en, this message translates to:
  /// **'Loading readings...'**
  String get loadingReadings;

  /// No description provided for @unableToLoadCard.
  ///
  /// In en, this message translates to:
  /// **'Unable to load your card'**
  String get unableToLoadCard;

  /// No description provided for @unableToLoadReadings.
  ///
  /// In en, this message translates to:
  /// **'Unable to load readings'**
  String get unableToLoadReadings;

  /// No description provided for @pleaseRetry.
  ///
  /// In en, this message translates to:
  /// **'Please try again'**
  String get pleaseRetry;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @startJourney.
  ///
  /// In en, this message translates to:
  /// **'Start your journey with a new reading'**
  String get startJourney;

  /// No description provided for @fullHistoryComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Full history coming soon!'**
  String get fullHistoryComingSoon;

  /// No description provided for @journalPageComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Journal page coming soon!'**
  String get journalPageComingSoon;

  /// No description provided for @navigateToReadingsPage.
  ///
  /// In en, this message translates to:
  /// **'Navigate to readings page'**
  String get navigateToReadingsPage;

  /// No description provided for @manualInterpretations.
  ///
  /// In en, this message translates to:
  /// **'Manual Interpretations'**
  String get manualInterpretations;

  /// No description provided for @inputPhysicalDeck.
  ///
  /// In en, this message translates to:
  /// **'Input your physical deck draws for AI-enhanced insights'**
  String get inputPhysicalDeck;

  /// No description provided for @selectReadingContext.
  ///
  /// In en, this message translates to:
  /// **'Select reading context'**
  String get selectReadingContext;

  /// No description provided for @searchCardsHint.
  ///
  /// In en, this message translates to:
  /// **'Search cards by name or keywords...'**
  String get searchCardsHint;

  /// No description provided for @noCardsFound.
  ///
  /// In en, this message translates to:
  /// **'No cards found'**
  String get noCardsFound;

  /// No description provided for @tryAdjustingSearch.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filter'**
  String get tryAdjustingSearch;

  /// No description provided for @selectCard.
  ///
  /// In en, this message translates to:
  /// **'Select a Card'**
  String get selectCard;

  /// No description provided for @selectCardOrientation.
  ///
  /// In en, this message translates to:
  /// **'Select Card Orientation'**
  String get selectCardOrientation;

  /// No description provided for @chooseCardPosition.
  ///
  /// In en, this message translates to:
  /// **'Choose how this card appeared in your reading:'**
  String get chooseCardPosition;

  /// No description provided for @upright.
  ///
  /// In en, this message translates to:
  /// **'Upright'**
  String get upright;

  /// No description provided for @reversed.
  ///
  /// In en, this message translates to:
  /// **'Reversed'**
  String get reversed;

  /// No description provided for @allCards.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allCards;

  /// No description provided for @chooseAreaOfLife.
  ///
  /// In en, this message translates to:
  /// **'Choose the area of life you want to explore'**
  String get chooseAreaOfLife;

  /// No description provided for @addYourCards.
  ///
  /// In en, this message translates to:
  /// **'Add your cards'**
  String get addYourCards;

  /// No description provided for @selectCardsFromDeck.
  ///
  /// In en, this message translates to:
  /// **'Select the cards you drew from your physical deck'**
  String get selectCardsFromDeck;

  /// No description provided for @pleaseSelectContext.
  ///
  /// In en, this message translates to:
  /// **'Please select a reading context first'**
  String get pleaseSelectContext;

  /// No description provided for @addCardFromDeck.
  ///
  /// In en, this message translates to:
  /// **'Add Card from Deck'**
  String get addCardFromDeck;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @saveReading.
  ///
  /// In en, this message translates to:
  /// **'Save Reading'**
  String get saveReading;

  /// No description provided for @saveInterpretation.
  ///
  /// In en, this message translates to:
  /// **'Save interpretation'**
  String get saveInterpretation;

  /// No description provided for @startOver.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get startOver;

  /// No description provided for @selectedCards.
  ///
  /// In en, this message translates to:
  /// **'Selected Cards'**
  String get selectedCards;

  /// No description provided for @noCardsSelected.
  ///
  /// In en, this message translates to:
  /// **'No cards selected'**
  String get noCardsSelected;

  /// No description provided for @editPositionName.
  ///
  /// In en, this message translates to:
  /// **'Edit Position Name'**
  String get editPositionName;

  /// No description provided for @positionName.
  ///
  /// In en, this message translates to:
  /// **'Position Name'**
  String get positionName;

  /// No description provided for @positionNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Past, Present, Future'**
  String get positionNameHint;

  /// No description provided for @cardConnections.
  ///
  /// In en, this message translates to:
  /// **'Card Connections'**
  String get cardConnections;

  /// No description provided for @recentManualInterpretations.
  ///
  /// In en, this message translates to:
  /// **'Recent Manual Interpretations'**
  String get recentManualInterpretations;

  /// No description provided for @noManualInterpretations.
  ///
  /// In en, this message translates to:
  /// **'No manual interpretations yet'**
  String get noManualInterpretations;

  /// No description provided for @addCardsToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Add cards from your physical deck to get started'**
  String get addCardsToGetStarted;

  /// No description provided for @interpretationDetailsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Interpretation details coming soon'**
  String get interpretationDetailsComingSoon;

  /// No description provided for @failedToLoadInterpretations.
  ///
  /// In en, this message translates to:
  /// **'Failed to load interpretations'**
  String get failedToLoadInterpretations;

  /// No description provided for @saveInterpretationDialog.
  ///
  /// In en, this message translates to:
  /// **'Save Interpretation'**
  String get saveInterpretationDialog;

  /// No description provided for @saveInterpretationQuestion.
  ///
  /// In en, this message translates to:
  /// **'Save this manual interpretation to your journal?'**
  String get saveInterpretationQuestion;

  /// No description provided for @personalNotes.
  ///
  /// In en, this message translates to:
  /// **'Personal notes (optional)'**
  String get personalNotes;

  /// No description provided for @addThoughts.
  ///
  /// In en, this message translates to:
  /// **'Add your thoughts about this reading...'**
  String get addThoughts;

  /// No description provided for @interpretationSaved.
  ///
  /// In en, this message translates to:
  /// **'Interpretation saved to journal'**
  String get interpretationSaved;

  /// No description provided for @failedToSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save'**
  String get failedToSave;

  /// No description provided for @navigationHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navigationHome;

  /// No description provided for @navigationReadings.
  ///
  /// In en, this message translates to:
  /// **'Readings'**
  String get navigationReadings;

  /// No description provided for @navigationManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get navigationManual;

  /// No description provided for @navigationYourself.
  ///
  /// In en, this message translates to:
  /// **'Yourself'**
  String get navigationYourself;

  /// No description provided for @navigationFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get navigationFriends;

  /// No description provided for @readingDetails.
  ///
  /// In en, this message translates to:
  /// **'Reading Details'**
  String get readingDetails;

  /// No description provided for @yourReflection.
  ///
  /// In en, this message translates to:
  /// **'Your Reflection'**
  String get yourReflection;

  /// No description provided for @readingStatistics.
  ///
  /// In en, this message translates to:
  /// **'Reading Statistics'**
  String get readingStatistics;

  /// No description provided for @majorArcana.
  ///
  /// In en, this message translates to:
  /// **'Major Arcana'**
  String get majorArcana;

  /// No description provided for @suits.
  ///
  /// In en, this message translates to:
  /// **'Suits'**
  String get suits;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @imageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Image unavailable'**
  String get imageUnavailable;

  /// No description provided for @removeFriend.
  ///
  /// In en, this message translates to:
  /// **'Remove Friend'**
  String get removeFriend;

  /// Confirmation message for removing a friend
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {friendName} from your friends?'**
  String removeFriendConfirm(String friendName);

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @activeNow.
  ///
  /// In en, this message translates to:
  /// **'Active now'**
  String get activeNow;

  /// Shows when user was active minutes ago
  ///
  /// In en, this message translates to:
  /// **'Active {minutes}m ago'**
  String activeMinutesAgo(int minutes);

  /// Shows when user was active hours ago
  ///
  /// In en, this message translates to:
  /// **'Active {hours}h ago'**
  String activeHoursAgo(int hours);

  /// No description provided for @activeYesterday.
  ///
  /// In en, this message translates to:
  /// **'Active yesterday'**
  String get activeYesterday;

  /// Shows when user was active days ago
  ///
  /// In en, this message translates to:
  /// **'Active {days} days ago'**
  String activeDaysAgo(int days);

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get yesterday;

  /// Shows how many days ago something happened
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(int days);

  /// No description provided for @startConversation.
  ///
  /// In en, this message translates to:
  /// **'Start the conversation'**
  String get startConversation;

  /// No description provided for @shareThoughts.
  ///
  /// In en, this message translates to:
  /// **'Share your thoughts about this reading with your friend'**
  String get shareThoughts;

  /// No description provided for @spreadPast.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get spreadPast;

  /// No description provided for @spreadPresent.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get spreadPresent;

  /// No description provided for @spreadFuture.
  ///
  /// In en, this message translates to:
  /// **'Future'**
  String get spreadFuture;

  /// No description provided for @spreadYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get spreadYou;

  /// No description provided for @spreadThem.
  ///
  /// In en, this message translates to:
  /// **'Them'**
  String get spreadThem;

  /// No description provided for @spreadConnection.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get spreadConnection;

  /// No description provided for @spreadCurrentSituation.
  ///
  /// In en, this message translates to:
  /// **'Current Situation'**
  String get spreadCurrentSituation;

  /// No description provided for @spreadStrengths.
  ///
  /// In en, this message translates to:
  /// **'Strengths'**
  String get spreadStrengths;

  /// No description provided for @spreadChallenges.
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get spreadChallenges;

  /// No description provided for @topicSelf.
  ///
  /// In en, this message translates to:
  /// **'Self'**
  String get topicSelf;

  /// No description provided for @topicLove.
  ///
  /// In en, this message translates to:
  /// **'Love'**
  String get topicLove;

  /// No description provided for @topicWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get topicWork;

  /// No description provided for @topicSocial.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get topicSocial;

  /// No description provided for @topicSelfDescription.
  ///
  /// In en, this message translates to:
  /// **'Personal growth and self-discovery'**
  String get topicSelfDescription;

  /// No description provided for @topicLoveDescription.
  ///
  /// In en, this message translates to:
  /// **'Relationships and emotional connections'**
  String get topicLoveDescription;

  /// No description provided for @topicWorkDescription.
  ///
  /// In en, this message translates to:
  /// **'Career and professional life'**
  String get topicWorkDescription;

  /// No description provided for @topicSocialDescription.
  ///
  /// In en, this message translates to:
  /// **'Community and social interactions'**
  String get topicSocialDescription;

  /// No description provided for @readingJournal.
  ///
  /// In en, this message translates to:
  /// **'Reading Journal'**
  String get readingJournal;

  /// No description provided for @searchReadings.
  ///
  /// In en, this message translates to:
  /// **'Search readings...'**
  String get searchReadings;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @noReadingsFound.
  ///
  /// In en, this message translates to:
  /// **'No readings found'**
  String get noReadingsFound;

  /// No description provided for @tryAdjustingFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters'**
  String get tryAdjustingFilters;

  /// No description provided for @noJournalEntries.
  ///
  /// In en, this message translates to:
  /// **'No journal entries yet'**
  String get noJournalEntries;

  /// No description provided for @saveReadingsToStart.
  ///
  /// In en, this message translates to:
  /// **'Save readings to start building your journal'**
  String get saveReadingsToStart;

  /// No description provided for @createReading.
  ///
  /// In en, this message translates to:
  /// **'Create Reading'**
  String get createReading;

  /// No description provided for @unableToLoadJournal.
  ///
  /// In en, this message translates to:
  /// **'Unable to load journal'**
  String get unableToLoadJournal;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @deleteReading.
  ///
  /// In en, this message translates to:
  /// **'Delete Reading'**
  String get deleteReading;

  /// Confirmation message for deleting a reading
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"? This action cannot be undone.'**
  String deleteReadingConfirm(String title);

  /// No description provided for @readingDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Reading deleted successfully'**
  String get readingDeletedSuccess;

  /// No description provided for @failedToDeleteReading.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete reading'**
  String get failedToDeleteReading;

  /// No description provided for @friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// No description provided for @addFriend.
  ///
  /// In en, this message translates to:
  /// **'Add Friend'**
  String get addFriend;

  /// No description provided for @shareYourJourney.
  ///
  /// In en, this message translates to:
  /// **'Share your journey'**
  String get shareYourJourney;

  /// No description provided for @connectWithFriends.
  ///
  /// In en, this message translates to:
  /// **'Connect with trusted friends and share meaningful readings'**
  String get connectWithFriends;

  /// No description provided for @yourFriends.
  ///
  /// In en, this message translates to:
  /// **'Your Friends'**
  String get yourFriends;

  /// No description provided for @noFriendsYet.
  ///
  /// In en, this message translates to:
  /// **'No friends yet'**
  String get noFriendsYet;

  /// No description provided for @addFriendsToShare.
  ///
  /// In en, this message translates to:
  /// **'Add friends to share your tarot journey privately'**
  String get addFriendsToShare;

  /// No description provided for @addYourFirstFriend.
  ///
  /// In en, this message translates to:
  /// **'Add Your First Friend'**
  String get addYourFirstFriend;

  /// No description provided for @errorLoadingFriends.
  ///
  /// In en, this message translates to:
  /// **'Error loading friends'**
  String get errorLoadingFriends;

  /// No description provided for @sharedReadings.
  ///
  /// In en, this message translates to:
  /// **'Shared Readings'**
  String get sharedReadings;

  /// No description provided for @noSharedReadings.
  ///
  /// In en, this message translates to:
  /// **'No shared readings'**
  String get noSharedReadings;

  /// No description provided for @shareReadingsFromJournal.
  ///
  /// In en, this message translates to:
  /// **'Share readings from your journal to start conversations'**
  String get shareReadingsFromJournal;

  /// No description provided for @errorLoadingSharedReadings.
  ///
  /// In en, this message translates to:
  /// **'Error loading shared readings'**
  String get errorLoadingSharedReadings;

  /// No description provided for @errorLoadingUserData.
  ///
  /// In en, this message translates to:
  /// **'Error loading user data'**
  String get errorLoadingUserData;

  /// No description provided for @privacySafety.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Safety'**
  String get privacySafety;

  /// No description provided for @privacyInfo.
  ///
  /// In en, this message translates to:
  /// **'• Friends can only be added through private invitation codes\n• You control what readings to share\n• All conversations are private between you and your friend\n• You can remove friends at any time'**
  String get privacyInfo;

  /// No description provided for @chooseHowToConnect.
  ///
  /// In en, this message translates to:
  /// **'Choose how to connect with your friend:'**
  String get chooseHowToConnect;

  /// No description provided for @shareInvitationCode.
  ///
  /// In en, this message translates to:
  /// **'Share Invitation Code'**
  String get shareInvitationCode;

  /// No description provided for @enterFriendsCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Friend\'s Code'**
  String get enterFriendsCode;

  /// No description provided for @yourInvitationCode.
  ///
  /// In en, this message translates to:
  /// **'Your Invitation Code'**
  String get yourInvitationCode;

  /// No description provided for @shareThisCode.
  ///
  /// In en, this message translates to:
  /// **'Share this code with your friend:'**
  String get shareThisCode;

  /// No description provided for @copyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy Code'**
  String get copyCode;

  /// No description provided for @codeCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard'**
  String get codeCopiedToClipboard;

  /// Error message when generating invitation code fails
  ///
  /// In en, this message translates to:
  /// **'Error generating code: {error}'**
  String errorGeneratingCode(String error);

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @codeUniqueToYou.
  ///
  /// In en, this message translates to:
  /// **'This code is unique to you and can be used multiple times'**
  String get codeUniqueToYou;

  /// No description provided for @enterFriendsCodeDialog.
  ///
  /// In en, this message translates to:
  /// **'Enter Friend\'s Code'**
  String get enterFriendsCodeDialog;

  /// No description provided for @enterInvitationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the invitation code your friend shared:'**
  String get enterInvitationCode;

  /// No description provided for @invitationCode.
  ///
  /// In en, this message translates to:
  /// **'Invitation Code'**
  String get invitationCode;

  /// No description provided for @invitationCodeHint.
  ///
  /// In en, this message translates to:
  /// **'LUNA-1234-ABC567'**
  String get invitationCodeHint;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Request'**
  String get sendRequest;

  /// No description provided for @pleaseEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter an invitation code'**
  String get pleaseEnterCode;

  /// No description provided for @sendingFriendRequest.
  ///
  /// In en, this message translates to:
  /// **'Sending friend request...'**
  String get sendingFriendRequest;

  /// No description provided for @friendRequestSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Friend request sent successfully!'**
  String get friendRequestSentSuccess;

  /// Error message when sending friend request fails
  ///
  /// In en, this message translates to:
  /// **'Failed to send friend request: {error}'**
  String failedToSendFriendRequest(String error);

  /// Success message when friend is removed
  ///
  /// In en, this message translates to:
  /// **'{name} removed from friends'**
  String friendRemovedSuccess(String name);

  /// Error message when removing friend fails
  ///
  /// In en, this message translates to:
  /// **'Failed to remove friend: {error}'**
  String failedToRemoveFriend(String error);

  /// No description provided for @readings.
  ///
  /// In en, this message translates to:
  /// **'Readings'**
  String get readings;

  /// No description provided for @chooseTopicForReading.
  ///
  /// In en, this message translates to:
  /// **'Choose a topic for your reading'**
  String get chooseTopicForReading;

  /// No description provided for @aiPoweredInsights.
  ///
  /// In en, this message translates to:
  /// **'Let the cards guide you with AI-powered insights'**
  String get aiPoweredInsights;

  /// No description provided for @recentSavedReadings.
  ///
  /// In en, this message translates to:
  /// **'Recent Saved Readings'**
  String get recentSavedReadings;

  /// No description provided for @navigateToYourselfPage.
  ///
  /// In en, this message translates to:
  /// **'Navigate to Yourself page to see all readings'**
  String get navigateToYourselfPage;

  /// No description provided for @noSavedReadingsYet.
  ///
  /// In en, this message translates to:
  /// **'No saved readings yet'**
  String get noSavedReadingsYet;

  /// No description provided for @completeReadingToSee.
  ///
  /// In en, this message translates to:
  /// **'Complete a reading above and save it to see it here'**
  String get completeReadingToSee;

  /// No description provided for @saveReadingDialog.
  ///
  /// In en, this message translates to:
  /// **'Save Reading'**
  String get saveReadingDialog;

  /// No description provided for @addThoughtsOptional.
  ///
  /// In en, this message translates to:
  /// **'Add your thoughts about this reading (optional)...'**
  String get addThoughtsOptional;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @readingSavedToJournal.
  ///
  /// In en, this message translates to:
  /// **'Reading saved to your journal'**
  String get readingSavedToJournal;

  /// No description provided for @failedToSaveReading.
  ///
  /// In en, this message translates to:
  /// **'Failed to save reading'**
  String get failedToSaveReading;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @alreadySaved.
  ///
  /// In en, this message translates to:
  /// **'Already saved'**
  String get alreadySaved;

  /// No description provided for @readingSaved.
  ///
  /// In en, this message translates to:
  /// **'Reading saved'**
  String get readingSaved;

  /// No description provided for @shareReading.
  ///
  /// In en, this message translates to:
  /// **'Share Reading'**
  String get shareReading;

  /// Shows number of cards and spread type
  ///
  /// In en, this message translates to:
  /// **'{count} cards • {spread}'**
  String cardsSpread(int count, String spread);

  /// No description provided for @chooseFriendToShare.
  ///
  /// In en, this message translates to:
  /// **'Choose a friend to share with:'**
  String get chooseFriendToShare;

  /// No description provided for @noFriendsToShareWith.
  ///
  /// In en, this message translates to:
  /// **'No friends to share with'**
  String get noFriendsToShareWith;

  /// No description provided for @addFriendsToStartSharing.
  ///
  /// In en, this message translates to:
  /// **'Add friends to start sharing readings'**
  String get addFriendsToStartSharing;

  /// No description provided for @sharingReading.
  ///
  /// In en, this message translates to:
  /// **'Sharing reading...'**
  String get sharingReading;

  /// Success message when reading is shared
  ///
  /// In en, this message translates to:
  /// **'Reading shared with {name}'**
  String readingSharedWith(String name);

  /// Error message when sharing reading fails
  ///
  /// In en, this message translates to:
  /// **'Failed to share reading: {error}'**
  String failedToShareReading(String error);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSelection.
  ///
  /// In en, this message translates to:
  /// **'Language Selection'**
  String get languageSelection;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get chooseLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get spanish;

  /// Shows the currently selected language
  ///
  /// In en, this message translates to:
  /// **'Current language: {language}'**
  String currentLanguage(String language);

  /// Confirmation message when language is changed
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}'**
  String languageChanged(String language);

  /// No description provided for @yourTarotJourney.
  ///
  /// In en, this message translates to:
  /// **'Your tarot journey'**
  String get yourTarotJourney;

  /// No description provided for @reflectOnReadings.
  ///
  /// In en, this message translates to:
  /// **'Reflect on your readings and explore the cards'**
  String get reflectOnReadings;

  /// No description provided for @yourJourney.
  ///
  /// In en, this message translates to:
  /// **'Your Journey'**
  String get yourJourney;

  /// No description provided for @totalReadings.
  ///
  /// In en, this message translates to:
  /// **'Total Readings'**
  String get totalReadings;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @favoriteTopic.
  ///
  /// In en, this message translates to:
  /// **'Favorite Topic'**
  String get favoriteTopic;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @readingJournalDescription.
  ///
  /// In en, this message translates to:
  /// **'View and reflect on your saved readings'**
  String get readingJournalDescription;

  /// No description provided for @cardEncyclopedia.
  ///
  /// In en, this message translates to:
  /// **'Card Encyclopedia'**
  String get cardEncyclopedia;

  /// No description provided for @cardEncyclopediaDescription.
  ///
  /// In en, this message translates to:
  /// **'Learn about all 78 tarot cards'**
  String get cardEncyclopediaDescription;

  /// No description provided for @readingPatterns.
  ///
  /// In en, this message translates to:
  /// **'Reading Patterns'**
  String get readingPatterns;

  /// No description provided for @readingPatternsDescription.
  ///
  /// In en, this message translates to:
  /// **'Discover recurring themes and cards'**
  String get readingPatternsDescription;

  /// No description provided for @settingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Language preferences and app settings'**
  String get settingsDescription;

  /// No description provided for @recentJournalEntries.
  ///
  /// In en, this message translates to:
  /// **'Recent Journal Entries'**
  String get recentJournalEntries;

  /// No description provided for @noJournalEntriesYet.
  ///
  /// In en, this message translates to:
  /// **'No journal entries yet'**
  String get noJournalEntriesYet;

  /// No description provided for @saveReadingsToBuildJournal.
  ///
  /// In en, this message translates to:
  /// **'Save readings to start building your journal'**
  String get saveReadingsToBuildJournal;

  /// Shows number of cards in a reading
  ///
  /// In en, this message translates to:
  /// **'{count} cards'**
  String cardsCount(int count);

  /// No description provided for @unableToLoadStats.
  ///
  /// In en, this message translates to:
  /// **'Unable to load stats'**
  String get unableToLoadStats;

  /// No description provided for @unableToLoadJournalEntries.
  ///
  /// In en, this message translates to:
  /// **'Unable to load journal entries'**
  String get unableToLoadJournalEntries;

  /// No description provided for @chooseYourSpread.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Spread'**
  String get chooseYourSpread;

  /// No description provided for @selectSpreadType.
  ///
  /// In en, this message translates to:
  /// **'Select the type of reading that resonates with your question'**
  String get selectSpreadType;

  /// No description provided for @selectASpread.
  ///
  /// In en, this message translates to:
  /// **'Select a Spread'**
  String get selectASpread;

  /// Button text to start a specific spread reading
  ///
  /// In en, this message translates to:
  /// **'Start {spreadName} Reading'**
  String startSpreadReading(String spreadName);

  /// No description provided for @shufflingCards.
  ///
  /// In en, this message translates to:
  /// **'Shuffling the cards...'**
  String get shufflingCards;

  /// No description provided for @universePreparingReading.
  ///
  /// In en, this message translates to:
  /// **'The universe is preparing your reading'**
  String get universePreparingReading;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @unableToCreateReading.
  ///
  /// In en, this message translates to:
  /// **'Unable to create your reading. Please try again.'**
  String get unableToCreateReading;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @cardsBeingDealt.
  ///
  /// In en, this message translates to:
  /// **'Cards are being dealt...'**
  String get cardsBeingDealt;

  /// No description provided for @watchCardsPlaced.
  ///
  /// In en, this message translates to:
  /// **'Watch as your cards are placed in their positions'**
  String get watchCardsPlaced;

  /// No description provided for @tapToRevealCards.
  ///
  /// In en, this message translates to:
  /// **'Tap to reveal your cards'**
  String get tapToRevealCards;

  /// No description provided for @touchCardWhenReady.
  ///
  /// In en, this message translates to:
  /// **'Touch each card when you\'re ready to see its message'**
  String get touchCardWhenReady;

  /// No description provided for @yourReading.
  ///
  /// In en, this message translates to:
  /// **'Your Reading'**
  String get yourReading;

  /// No description provided for @saveToJournal.
  ///
  /// In en, this message translates to:
  /// **'Save to Journal'**
  String get saveToJournal;

  /// No description provided for @newReading.
  ///
  /// In en, this message translates to:
  /// **'New Reading'**
  String get newReading;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
