import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

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
    Locale('it'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Don\'t Let My Plants Die'**
  String get appTitle;

  /// Weather tab label
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get home;

  /// Map tab label
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// Alarms tab label
  ///
  /// In en, this message translates to:
  /// **'Alarms'**
  String get alarms;

  /// Settings tab label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Onboarding title
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get locationSetupTitle;

  /// Onboarding subtitle
  ///
  /// In en, this message translates to:
  /// **'What is your main location? You can change it later in Settings.'**
  String get locationSetupSubtitle;

  /// Location search hint
  ///
  /// In en, this message translates to:
  /// **'Search city...'**
  String get searchLocation;

  /// Location not found error
  ///
  /// In en, this message translates to:
  /// **'City not found. Please check the spelling.'**
  String get locationNotFound;

  /// Prompt to select a city
  ///
  /// In en, this message translates to:
  /// **'Select a city from the list'**
  String get selectLocation;

  /// Save action
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit action
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Add action
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Temperature label
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// Wind label
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get wind;

  /// Wind speed label
  ///
  /// In en, this message translates to:
  /// **'Wind speed'**
  String get windSpeed;

  /// Humidity label
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidity;

  /// Weather condition label
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get weatherCondition;

  /// Today label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Now label
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// Alarm notice period label
  ///
  /// In en, this message translates to:
  /// **'Notice period'**
  String get noticePeriod;

  /// Description label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Title label
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// Enable action
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// Disable action
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// Alarm label
  ///
  /// In en, this message translates to:
  /// **'Alarm'**
  String get alarm;

  /// Hours unit
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// Celsius unit
  ///
  /// In en, this message translates to:
  /// **'°C'**
  String get celsius;

  /// Location label
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// Area label
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get area;

  /// Predefined areas label
  ///
  /// In en, this message translates to:
  /// **'Saved areas'**
  String get predefinedAreas;

  /// Draw area instruction
  ///
  /// In en, this message translates to:
  /// **'Draw an area on the map'**
  String get drawArea;

  /// Close area instruction
  ///
  /// In en, this message translates to:
  /// **'Tap the first dot to close the area'**
  String get closeArea;

  /// Weather label
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get weather;

  /// Forecast label
  ///
  /// In en, this message translates to:
  /// **'Forecast'**
  String get forecast;

  /// Theme label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Light theme
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Dark theme
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// System theme
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// Language label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Italian language
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get italian;

  /// Check for updates button
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get checkForUpdates;

  /// Update available dialog title
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateAvailable;

  /// No updates message
  ///
  /// In en, this message translates to:
  /// **'No updates available'**
  String get noUpdates;

  /// Download button
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// Later button
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// Update check error message
  ///
  /// In en, this message translates to:
  /// **'Could not check for updates'**
  String get updateError;

  /// Reset alarm after label
  ///
  /// In en, this message translates to:
  /// **'Reset alarm after'**
  String get resetAlarmAfter;

  /// No connection warning
  ///
  /// In en, this message translates to:
  /// **'No connection. Showing cached data.'**
  String get noConnectionWarning;

  /// Stale data warning
  ///
  /// In en, this message translates to:
  /// **'Weather data may be outdated.'**
  String get staleDataWarning;

  /// Loading indicator
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Generic error
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Retry action
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Empty alarms list
  ///
  /// In en, this message translates to:
  /// **'No alarms yet. Tap + to add one.'**
  String get noAlarmsYet;

  /// Empty areas list
  ///
  /// In en, this message translates to:
  /// **'No saved areas yet.'**
  String get noAreasYet;

  /// Sunny weather
  ///
  /// In en, this message translates to:
  /// **'Sunny'**
  String get sunny;

  /// Rainy weather
  ///
  /// In en, this message translates to:
  /// **'Rainy'**
  String get rainy;

  /// Cloudy weather
  ///
  /// In en, this message translates to:
  /// **'Cloudy'**
  String get cloudy;

  /// Snowy weather
  ///
  /// In en, this message translates to:
  /// **'Snowy'**
  String get snowy;

  /// Stormy weather
  ///
  /// In en, this message translates to:
  /// **'Stormy'**
  String get stormy;

  /// Foggy weather
  ///
  /// In en, this message translates to:
  /// **'Foggy'**
  String get foggy;

  /// Windy weather
  ///
  /// In en, this message translates to:
  /// **'Windy'**
  String get windy;

  /// Partly cloudy weather
  ///
  /// In en, this message translates to:
  /// **'Partly cloudy'**
  String get partlyCloudy;

  /// Hail weather
  ///
  /// In en, this message translates to:
  /// **'Hail'**
  String get hail;

  /// Thunderstorm weather
  ///
  /// In en, this message translates to:
  /// **'Thunderstorm'**
  String get thunderstorm;

  /// Weather condition picker
  ///
  /// In en, this message translates to:
  /// **'Pick weather condition'**
  String get pickWeatherCondition;

  /// Location picker
  ///
  /// In en, this message translates to:
  /// **'Pick location'**
  String get pickLocation;

  /// New alarm title
  ///
  /// In en, this message translates to:
  /// **'New alarm'**
  String get newAlarm;

  /// Edit alarm title
  ///
  /// In en, this message translates to:
  /// **'Edit alarm'**
  String get editAlarm;

  /// Alarm details title
  ///
  /// In en, this message translates to:
  /// **'Alarm details'**
  String get alarmDetails;

  /// Condition label
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get condition;

  /// When to notify label
  ///
  /// In en, this message translates to:
  /// **'When to notify'**
  String get whenToNotify;

  /// Before the event label
  ///
  /// In en, this message translates to:
  /// **'before the event'**
  String get beforeTheEvent;

  /// And at the event time label
  ///
  /// In en, this message translates to:
  /// **'and at the event time'**
  String get andAtTheEvent;

  /// Delete area confirmation
  ///
  /// In en, this message translates to:
  /// **'Delete this area?'**
  String get deleteAreaConfirm;

  /// Delete alarm confirmation
  ///
  /// In en, this message translates to:
  /// **'Delete this alarm?'**
  String get deleteAlarmConfirm;

  /// Kilometers per hour
  ///
  /// In en, this message translates to:
  /// **'km/h'**
  String get kmH;

  /// Percent symbol
  ///
  /// In en, this message translates to:
  /// **'%'**
  String get percent;

  /// Installed app version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Wind gusts label
  ///
  /// In en, this message translates to:
  /// **'Wind gusts'**
  String get windGusts;

  /// Precipitation label
  ///
  /// In en, this message translates to:
  /// **'Precipitation'**
  String get precipitation;

  /// Precipitation probability label
  ///
  /// In en, this message translates to:
  /// **'Rain probability'**
  String get precipitationProbability;

  /// Cloud cover label
  ///
  /// In en, this message translates to:
  /// **'Cloud cover'**
  String get cloudCover;

  /// UV index label
  ///
  /// In en, this message translates to:
  /// **'UV index'**
  String get uvIndex;

  /// Minimum temperature label
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get tempMin;

  /// Maximum temperature label
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get tempMax;

  /// Elevation label
  ///
  /// In en, this message translates to:
  /// **'Elevation'**
  String get elevation;

  /// Rain probability info dialog title
  ///
  /// In en, this message translates to:
  /// **'About rain probability'**
  String get rainProbabilityInfoTitle;

  /// Rain probability info dialog body
  ///
  /// In en, this message translates to:
  /// **'The precipitation amount comes from a high-resolution weather model, while the probability is calculated from 30 ensemble simulations. These models can sometimes disagree, which is why you may see rain with 0% probability or dry conditions with high probability.'**
  String get rainProbabilityInfoBody;
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
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
