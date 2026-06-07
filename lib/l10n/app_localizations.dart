import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SignWriter Easy'**
  String get appTitle;

  /// No description provided for @authSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to get started'**
  String get authSubtitle;

  /// No description provided for @loginTab.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginTab;

  /// No description provided for @signupTab.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signupTab;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullNameLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginButton;

  /// No description provided for @signupButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signupButton;

  /// No description provided for @orLabel.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orLabel;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @enterEmailError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get enterEmailError;

  /// No description provided for @invalidEmailError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get invalidEmailError;

  /// No description provided for @enterPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get enterPasswordError;

  /// No description provided for @passwordLengthError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordLengthError;

  /// No description provided for @enterNameError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get enterNameError;

  /// No description provided for @nameLengthError.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameLengthError;

  /// No description provided for @confirmPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordError;

  /// No description provided for @passwordMismatchError.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatchError;

  /// No description provided for @passwordRecoverySoon.
  ///
  /// In en, this message translates to:
  /// **'Password recovery will be available soon'**
  String get passwordRecoverySoon;

  /// No description provided for @homeWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get homeWelcome;

  /// No description provided for @homeQuestion.
  ///
  /// In en, this message translates to:
  /// **'What would you like to do today?'**
  String get homeQuestion;

  /// No description provided for @featureLearnPractice.
  ///
  /// In en, this message translates to:
  /// **'Learn and Practice'**
  String get featureLearnPractice;

  /// No description provided for @featureWriteSigns.
  ///
  /// In en, this message translates to:
  /// **'Write Signs'**
  String get featureWriteSigns;

  /// No description provided for @featureTranslateSigns.
  ///
  /// In en, this message translates to:
  /// **'Translate Signs'**
  String get featureTranslateSigns;

  /// No description provided for @featureChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get featureChat;

  /// No description provided for @featureDictionary.
  ///
  /// In en, this message translates to:
  /// **'Dictionary'**
  String get featureDictionary;

  /// No description provided for @featureProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get featureProgress;

  /// No description provided for @bottomHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get bottomHome;

  /// No description provided for @bottomFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get bottomFavorites;

  /// No description provided for @bottomProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get bottomProfile;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @personalInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfoTitle;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccess;

  /// No description provided for @profileUpdatedError.
  ///
  /// In en, this message translates to:
  /// **'Error updating profile. Please try again.'**
  String get profileUpdatedError;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive alerts about updates and news'**
  String get notificationsSubtitle;

  /// No description provided for @darkThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkThemeTitle;

  /// No description provided for @darkThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use the app with darker colors'**
  String get darkThemeSubtitle;

  /// No description provided for @accessibilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get accessibilityTitle;

  /// No description provided for @accessibilitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customize the interface to your needs'**
  String get accessibilitySubtitle;

  /// No description provided for @fontSizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSizeTitle;

  /// No description provided for @contrastTitle.
  ///
  /// In en, this message translates to:
  /// **'Contrast'**
  String get contrastTitle;

  /// No description provided for @contrastNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get contrastNormal;

  /// No description provided for @contrastHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get contrastHigh;

  /// No description provided for @contrastVeryHigh.
  ///
  /// In en, this message translates to:
  /// **'Very High'**
  String get contrastVeryHigh;

  /// No description provided for @spacingTitle.
  ///
  /// In en, this message translates to:
  /// **'Spacing'**
  String get spacingTitle;


  /// No description provided for @themeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeTitle;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languagePortuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get languagePortuguese;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @accountDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Data'**
  String get accountDataTitle;

  /// No description provided for @exportDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Export My Data'**
  String get exportDataTitle;

  /// No description provided for @exportDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Download a copy of your personal data'**
  String get exportDataSubtitle;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete My Account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This action is irreversible'**
  String get deleteAccountSubtitle;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get logoutTitle;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get logoutConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get logout;

  /// No description provided for @deleteAccountDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountDialogTitle;

  /// No description provided for @deleteAccountDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action is irreversible and all your data will be lost.'**
  String get deleteAccountDialogContent;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @accountDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get accountDeletedSuccess;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since {date}'**
  String memberSince(Object date);

  /// No description provided for @photoChangeSoon.
  ///
  /// In en, this message translates to:
  /// **'Profile picture change will be available soon'**
  String get photoChangeSoon;

  /// No description provided for @exportSoon.
  ///
  /// In en, this message translates to:
  /// **'Data export will be available soon'**
  String get exportSoon;

  /// No description provided for @logoutError.
  ///
  /// In en, this message translates to:
  /// **'Error signing out. Please try again.'**
  String get logoutError;

  /// No description provided for @translateSignsTitle.
  ///
  /// In en, this message translates to:
  /// **'Translate Signs'**
  String get translateSignsTitle;

  /// No description provided for @tabTextToLibras.
  ///
  /// In en, this message translates to:
  /// **'Text → Libras'**
  String get tabTextToLibras;

  /// No description provided for @tabLibrasToText.
  ///
  /// In en, this message translates to:
  /// **'Libras → Text'**
  String get tabLibrasToText;

  /// No description provided for @typeText.
  ///
  /// In en, this message translates to:
  /// **'Type text'**
  String get typeText;

  /// No description provided for @recordOrDrawSign.
  ///
  /// In en, this message translates to:
  /// **'Record or draw the sign'**
  String get recordOrDrawSign;

  /// No description provided for @inputHintTextToLibras.
  ///
  /// In en, this message translates to:
  /// **'Enter text to translate to Libras'**
  String get inputHintTextToLibras;

  /// No description provided for @inputHintLibrasSoon.
  ///
  /// In en, this message translates to:
  /// **'This feature will be available soon'**
  String get inputHintLibrasSoon;

  /// No description provided for @voiceSoon.
  ///
  /// In en, this message translates to:
  /// **'Voice recognition coming soon'**
  String get voiceSoon;

  /// No description provided for @captureSoon.
  ///
  /// In en, this message translates to:
  /// **'Sign capture coming soon'**
  String get captureSoon;

  /// No description provided for @translateToLibras.
  ///
  /// In en, this message translates to:
  /// **'Translate to Libras'**
  String get translateToLibras;

  /// No description provided for @translateToText.
  ///
  /// In en, this message translates to:
  /// **'Translate to Text'**
  String get translateToText;

  /// No description provided for @resultTitle.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get resultTitle;

  /// No description provided for @textTranslationPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Text translation will appear here'**
  String get textTranslationPlaceholder;

  /// No description provided for @librasTranslationPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Libras translation will appear here'**
  String get librasTranslationPlaceholder;

  /// No description provided for @signNotExists.
  ///
  /// In en, this message translates to:
  /// **'This sign does not exist yet.'**
  String get signNotExists;

  /// No description provided for @signWritingSequence.
  ///
  /// In en, this message translates to:
  /// **'SignWriting sequence'**
  String get signWritingSequence;

  /// No description provided for @foundSigns.
  ///
  /// In en, this message translates to:
  /// **'Signs found'**
  String get foundSigns;

  /// No description provided for @notFoundWords.
  ///
  /// In en, this message translates to:
  /// **'Words not found'**
  String get notFoundWords;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @translationSaved.
  ///
  /// In en, this message translates to:
  /// **'Translation saved in history'**
  String get translationSaved;

  /// No description provided for @recentTranslations.
  ///
  /// In en, this message translates to:
  /// **'Recent Translations'**
  String get recentTranslations;

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get progressTitle;

  /// No description provided for @summaryTab.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summaryTab;

  /// No description provided for @categoriesTab.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTab;

  /// No description provided for @overallProgress.
  ///
  /// In en, this message translates to:
  /// **'Overall Progress'**
  String get overallProgress;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'Streak Days'**
  String get streakDays;

  /// No description provided for @studyHours.
  ///
  /// In en, this message translates to:
  /// **'Study Hours'**
  String get studyHours;

  /// No description provided for @exercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exercises;

  /// No description provided for @learnedSigns.
  ///
  /// In en, this message translates to:
  /// **'Learned Signs'**
  String get learnedSigns;

  /// No description provided for @weeklyStudyTime.
  ///
  /// In en, this message translates to:
  /// **'Weekly Study Time'**
  String get weeklyStudyTime;

  /// No description provided for @bestDayPrefix.
  ///
  /// In en, this message translates to:
  /// **'Best day: {day}'**
  String bestDayPrefix(Object day);

  /// No description provided for @emptyCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories with progress yet.'**
  String get emptyCategories;

  /// No description provided for @completedLessons.
  ///
  /// In en, this message translates to:
  /// **'Completed lessons'**
  String get completedLessons;

  /// No description provided for @totalStudyTime.
  ///
  /// In en, this message translates to:
  /// **'Total study time'**
  String get totalStudyTime;

  /// No description provided for @completedExercises.
  ///
  /// In en, this message translates to:
  /// **'Completed exercises'**
  String get completedExercises;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @mondayShort.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mondayShort;

  /// No description provided for @tuesdayShort.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesdayShort;

  /// No description provided for @wednesdayShort.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesdayShort;

  /// No description provided for @thursdayShort.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursdayShort;

  /// No description provided for @fridayShort.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fridayShort;

  /// No description provided for @saturdayShort.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturdayShort;

  /// No description provided for @sundayShort.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sundayShort;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @learningContentUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The content for this learning path could not be loaded right now.'**
  String get learningContentUnavailable;

  /// No description provided for @learningTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get learningTryAgain;

  /// No description provided for @learningCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Study categories'**
  String get learningCategoriesTitle;

  /// No description provided for @learningSummarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete lessons and track your progress in real time.'**
  String get learningSummarySubtitle;

  /// No description provided for @learningCategoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'There are no lessons available in this category yet.'**
  String get learningCategoryEmpty;

  /// No description provided for @learningOpenCategory.
  ///
  /// In en, this message translates to:
  /// **'Open category'**
  String get learningOpenCategory;

  /// No description provided for @learningLessonsTitle.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get learningLessonsTitle;

  /// No description provided for @learningLessonsLower.
  ///
  /// In en, this message translates to:
  /// **'lessons'**
  String get learningLessonsLower;

  /// No description provided for @learningLessonCompletedStatus.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get learningLessonCompletedStatus;

  /// No description provided for @learningLessonNotStartedStatus.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get learningLessonNotStartedStatus;

  /// No description provided for @learningLessonInProgressStatus.
  ///
  /// In en, this message translates to:
  /// **'Ready to practice'**
  String get learningLessonInProgressStatus;

  /// No description provided for @learningMinutesShort.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get learningMinutesShort;

  /// No description provided for @learningObjectives.
  ///
  /// In en, this message translates to:
  /// **'Lesson objectives'**
  String get learningObjectives;

  /// No description provided for @learningReferences.
  ///
  /// In en, this message translates to:
  /// **'References'**
  String get learningReferences;

  /// No description provided for @learningStartPractice.
  ///
  /// In en, this message translates to:
  /// **'Start practice'**
  String get learningStartPractice;

  /// No description provided for @learningRetakePractice.
  ///
  /// In en, this message translates to:
  /// **'Retake practice'**
  String get learningRetakePractice;

  /// No description provided for @learningProgressUpdated.
  ///
  /// In en, this message translates to:
  /// **'Lesson completed and progress updated.'**
  String get learningProgressUpdated;

  /// No description provided for @learningPracticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Lesson practice'**
  String get learningPracticeTitle;

  /// No description provided for @learningMarkLessonComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark lesson as completed'**
  String get learningMarkLessonComplete;

  /// No description provided for @learningQuestionProgress.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String learningQuestionProgress(Object current, Object total);

  /// No description provided for @learningPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get learningPrevious;

  /// No description provided for @learningNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get learningNext;

  /// No description provided for @learningFinishLesson.
  ///
  /// In en, this message translates to:
  /// **'Finish lesson'**
  String get learningFinishLesson;

  /// No description provided for @learningChooseOptionError.
  ///
  /// In en, this message translates to:
  /// **'Choose an answer before continuing.'**
  String get learningChooseOptionError;

  /// No description provided for @learningMatchingIncompleteError.
  ///
  /// In en, this message translates to:
  /// **'Match all items before continuing.'**
  String get learningMatchingIncompleteError;

  /// No description provided for @learningResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice results'**
  String get learningResultsTitle;

  /// No description provided for @learningCorrectAnswersSummary.
  ///
  /// In en, this message translates to:
  /// **'{correct} out of {total} correct answers'**
  String learningCorrectAnswersSummary(Object correct, Object total);

  /// No description provided for @learningReturnToLesson.
  ///
  /// In en, this message translates to:
  /// **'Back to lesson'**
  String get learningReturnToLesson;

  // Auth errors & messages
  String get authErrorInvalidCredentials;
  String get authErrorEmailExists;
  String get authErrorWeakPassword;
  String get authErrorEmailSignupsDisabled;
  String get authErrorEmailLoginsDisabled;
  String get authErrorEmailNotConfirmed;
  String get authErrorOAuthNotEnabled;
  String get authOAuthContinueInBrowser;
  String get authErrorLogin;
  String get authErrorSignup;
  String get authErrorCreateAccount;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'pt': return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
