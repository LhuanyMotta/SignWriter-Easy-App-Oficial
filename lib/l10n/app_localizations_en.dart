// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SignWriter Easy';

  @override
  String get authSubtitle => 'Sign in to get started';

  @override
  String get loginTab => 'Sign In';

  @override
  String get signupTab => 'Sign Up';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get forgotPassword => 'Forgot password';

  @override
  String get loginButton => 'Sign In';

  @override
  String get signupButton => 'Sign Up';

  @override
  String get orLabel => 'or';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get enterEmailError => 'Please enter your email';

  @override
  String get invalidEmailError => 'Please enter a valid email';

  @override
  String get enterPasswordError => 'Please enter your password';

  @override
  String get passwordLengthError => 'Password must be at least 6 characters';

  @override
  String get enterNameError => 'Please enter your name';

  @override
  String get nameLengthError => 'Name must be at least 2 characters';

  @override
  String get confirmPasswordError => 'Please confirm your password';

  @override
  String get passwordMismatchError => 'Passwords do not match';

  @override
  String get passwordRecoverySoon => 'Password recovery will be available soon';

  @override
  String get homeWelcome => 'Welcome!';

  @override
  String get homeQuestion => 'What would you like to do today?';

  @override
  String get featureLearnPractice => 'Learn and Practice';

  @override
  String get featureWriteSigns => 'Write Signs';

  @override
  String get featureTranslateSigns => 'Translate Signs';

  @override
  String get featureChat => 'Chat';

  @override
  String get featureDictionary => 'Dictionary';

  @override
  String get featureProgress => 'Progress';

  @override
  String get bottomHome => 'Home';

  @override
  String get bottomFavorites => 'Favorites';

  @override
  String get bottomProfile => 'Profile';

  @override
  String get profileTitle => 'My Profile';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get personalInfoTitle => 'Personal Information';

  @override
  String get nameLabel => 'Name';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get profileUpdatedSuccess => 'Profile updated successfully!';

  @override
  String get profileUpdatedError => 'Error updating profile. Please try again.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsSubtitle => 'Receive alerts about updates and news';

  @override
  String get darkThemeTitle => 'Dark Theme';

  @override
  String get darkThemeSubtitle => 'Use the app with darker colors';

  @override
  String get accessibilityTitle => 'Accessibility';

  @override
  String get accessibilitySubtitle => 'Customize the interface to your needs';

  @override
  String get fontSizeTitle => 'Font Size';

  @override
  String get contrastTitle => 'Contrast';

  @override
  String get contrastNormal => 'Normal';

  @override
  String get contrastHigh => 'High';

  @override
  String get contrastVeryHigh => 'Very High';

  @override
  String get spacingTitle => 'Spacing';

  @override
  String get themeTitle => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';


  @override
  String get languageTitle => 'Language';

  @override
  String get languagePortuguese => 'Portuguese';

  @override
  String get languageEnglish => 'English';

  @override
  String get accountDataTitle => 'Account Data';

  @override
  String get exportDataTitle => 'Export My Data';

  @override
  String get exportDataSubtitle => 'Download a copy of your personal data';

  @override
  String get deleteAccountTitle => 'Delete My Account';

  @override
  String get deleteAccountSubtitle => 'This action is irreversible';

  @override
  String get logoutTitle => 'Sign out';

  @override
  String get logoutConfirm => 'Are you sure you want to sign out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get logout => 'Sign Out';

  @override
  String get deleteAccountDialogTitle => 'Delete Account';

  @override
  String get deleteAccountDialogContent => 'Are you sure you want to delete your account? This action is irreversible and all your data will be lost.';

  @override
  String get delete => 'Delete';

  @override
  String get accountDeletedSuccess => 'Account deleted successfully';

  @override
  String memberSince(Object date) {
    return 'Member since $date';
  }

  @override
  String get photoChangeSoon => 'Profile picture change will be available soon';

  @override
  String get exportSoon => 'Data export will be available soon';

  @override
  String get logoutError => 'Error signing out. Please try again.';

  @override
  String get translateSignsTitle => 'Translate Signs';

  @override
  String get tabTextToLibras => 'Text → Libras';

  @override
  String get tabLibrasToText => 'Libras → Text';

  @override
  String get typeText => 'Type text';

  @override
  String get recordOrDrawSign => 'Record or draw the sign';

  @override
  String get inputHintTextToLibras => 'Enter text to translate to Libras';

  @override
  String get inputHintLibrasSoon => 'This feature will be available soon';

  @override
  String get voiceSoon => 'Voice recognition coming soon';

  @override
  String get captureSoon => 'Sign capture coming soon';

  @override
  String get translateToLibras => 'Translate to Libras';

  @override
  String get translateToText => 'Translate to Text';

  @override
  String get resultTitle => 'Result';

  @override
  String get textTranslationPlaceholder => 'Text translation will appear here';

  @override
  String get librasTranslationPlaceholder => 'Libras translation will appear here';

  @override
  String get signNotExists => 'This sign does not exist yet.';

  @override
  String get signWritingSequence => 'SignWriting sequence';

  @override
  String get foundSigns => 'Signs found';

  @override
  String get notFoundWords => 'Words not found';

  @override
  String get save => 'Save';

  @override
  String get translationSaved => 'Translation saved in history';

  @override
  String get recentTranslations => 'Recent Translations';

  @override
  String get progressTitle => 'Your Progress';

  @override
  String get summaryTab => 'Summary';

  @override
  String get categoriesTab => 'Categories';

  @override
  String get overallProgress => 'Overall Progress';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get streakDays => 'Streak Days';

  @override
  String get studyHours => 'Study Hours';

  @override
  String get exercises => 'Exercises';

  @override
  String get learnedSigns => 'Learned Signs';

  @override
  String get weeklyStudyTime => 'Weekly Study Time';

  @override
  String bestDayPrefix(Object day) {
    return 'Best day: $day';
  }

  @override
  String get emptyCategories => 'No categories with progress yet.';

  @override
  String get completedLessons => 'Completed lessons';

  @override
  String get totalStudyTime => 'Total study time';

  @override
  String get completedExercises => 'Completed exercises';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get mondayShort => 'Mon';

  @override
  String get tuesdayShort => 'Tue';

  @override
  String get wednesdayShort => 'Wed';

  @override
  String get thursdayShort => 'Thu';

  @override
  String get fridayShort => 'Fri';

  @override
  String get saturdayShort => 'Sat';

  @override
  String get sundayShort => 'Sun';

  @override
  String get noData => 'No data';
}
