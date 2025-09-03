import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

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
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('ja'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'TechLingual Quest'**
  String get appTitle;

  /// Welcome message on the home page
  ///
  /// In en, this message translates to:
  /// **'Welcome to TechLingual Quest!'**
  String get welcomeMessage;

  /// Subtitle describing the app's purpose
  ///
  /// In en, this message translates to:
  /// **'Your gamified journey to master technical English'**
  String get gamifiedJourney;

  /// Experience points label
  ///
  /// In en, this message translates to:
  /// **'XP:'**
  String get xpLabel;

  /// Tooltip for the earn XP button
  ///
  /// In en, this message translates to:
  /// **'Earn XP'**
  String get earnXpTooltip;

  /// Title for the features section
  ///
  /// In en, this message translates to:
  /// **'Features:'**
  String get featuresTitle;

  /// First feature description
  ///
  /// In en, this message translates to:
  /// **'• Daily quests and challenges'**
  String get feature1;

  /// Second feature description
  ///
  /// In en, this message translates to:
  /// **'• Vocabulary building with spaced repetition'**
  String get feature2;

  /// Third feature description
  ///
  /// In en, this message translates to:
  /// **'• Technical article summaries'**
  String get feature3;

  /// Fourth feature description
  ///
  /// In en, this message translates to:
  /// **'• Progress tracking and achievements'**
  String get feature4;

  /// Fifth feature description
  ///
  /// In en, this message translates to:
  /// **'• AI-powered conversation practice'**
  String get feature5;

  /// Vocabulary button text
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get vocabulary;

  /// Quests button text
  ///
  /// In en, this message translates to:
  /// **'Quests'**
  String get quests;

  /// Profile button text
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Vocabulary page title
  ///
  /// In en, this message translates to:
  /// **'Vocabulary Learning'**
  String get vocabularyLearning;

  /// Vocabulary page description
  ///
  /// In en, this message translates to:
  /// **'Vocabulary cards and learning features will be implemented here'**
  String get vocabularyDescription;

  /// Quests page title
  ///
  /// In en, this message translates to:
  /// **'Daily Quests'**
  String get dailyQuests;

  /// Quests page description
  ///
  /// In en, this message translates to:
  /// **'Quest system and gamification features will be implemented here'**
  String get questsDescription;

  /// Auth page title
  ///
  /// In en, this message translates to:
  /// **'Authentication'**
  String get authentication;

  /// Auth page description
  ///
  /// In en, this message translates to:
  /// **'User authentication will be implemented here'**
  String get authDescription;

  /// Language selection label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Japanese language option
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get japanese;
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
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
