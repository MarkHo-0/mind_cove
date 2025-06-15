import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

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
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('zh')];

  /// No description provided for @add_location.
  ///
  /// In en, this message translates to:
  /// **'Add Location'**
  String get add_location;

  /// No description provided for @add_media.
  ///
  /// In en, this message translates to:
  /// **'Add Media'**
  String get add_media;

  /// No description provided for @add_tags.
  ///
  /// In en, this message translates to:
  /// **'Add Tags'**
  String get add_tags;

  /// No description provided for @added_n_tags.
  ///
  /// In en, this message translates to:
  /// **'Added {count} tags'**
  String added_n_tags(Object count);

  /// No description provided for @app_name.
  ///
  /// In en, this message translates to:
  /// **'Mind Cove'**
  String get app_name;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @default_username.
  ///
  /// In en, this message translates to:
  /// **'Unknown User'**
  String get default_username;

  /// No description provided for @detail.
  ///
  /// In en, this message translates to:
  /// **'Detail'**
  String get detail;

  /// No description provided for @diary_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get diary_delete;

  /// No description provided for @diary_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get diary_edit;

  /// No description provided for @error_detail.
  ///
  /// In en, this message translates to:
  /// **'Error Detail'**
  String get error_detail;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @notify_me.
  ///
  /// In en, this message translates to:
  /// **'Notify me to write'**
  String get notify_me;

  /// No description provided for @page_calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get page_calendar;

  /// No description provided for @page_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get page_settings;

  /// No description provided for @page_timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get page_timeline;

  /// No description provided for @page_write.
  ///
  /// In en, this message translates to:
  /// **'Wrtie'**
  String get page_write;

  /// No description provided for @selected_n_media.
  ///
  /// In en, this message translates to:
  /// **'Selected {count} media'**
  String selected_n_media(Object count);

  /// No description provided for @start_writing.
  ///
  /// In en, this message translates to:
  /// **'Starting writing'**
  String get start_writing;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @theme_black.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get theme_black;

  /// No description provided for @theme_light.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get theme_light;

  /// No description provided for @theme_system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get theme_system;

  /// No description provided for @timeline_empty.
  ///
  /// In en, this message translates to:
  /// **'Here is your mind cove. Write down some words that belong only to you.'**
  String get timeline_empty;

  /// No description provided for @timeline_load_failed.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading'**
  String get timeline_load_failed;

  /// No description provided for @timeline_reach_end.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the shore of memery'**
  String get timeline_reach_end;

  /// No description provided for @write_hint.
  ///
  /// In en, this message translates to:
  /// **'Write your thoughts here...'**
  String get write_hint;

  /// No description provided for @write_title.
  ///
  /// In en, this message translates to:
  /// **'Write'**
  String get write_title;

  /// No description provided for @write_to_diary.
  ///
  /// In en, this message translates to:
  /// **'Write on my diary!'**
  String get write_to_diary;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
