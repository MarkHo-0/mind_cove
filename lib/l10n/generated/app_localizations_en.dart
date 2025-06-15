// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get add_location => 'Add Location';

  @override
  String get add_media => 'Add Media';

  @override
  String get add_tags => 'Add Tags';

  @override
  String added_n_tags(Object count) {
    return 'Added $count tags';
  }

  @override
  String get app_name => 'Mind Cove';

  @override
  String get close => 'Close';

  @override
  String get default_username => 'Unknown User';

  @override
  String get detail => 'Detail';

  @override
  String get diary_delete => 'Delete';

  @override
  String get diary_edit => 'Edit';

  @override
  String get error_detail => 'Error Detail';

  @override
  String get language => 'Language';

  @override
  String get notify_me => 'Notify me to write';

  @override
  String get page_calendar => 'Calendar';

  @override
  String get page_settings => 'Settings';

  @override
  String get page_timeline => 'Timeline';

  @override
  String get page_write => 'Wrtie';

  @override
  String selected_n_media(Object count) {
    return 'Selected $count media';
  }

  @override
  String get start_writing => 'Starting writing';

  @override
  String get theme => 'Theme';

  @override
  String get theme_black => 'Black';

  @override
  String get theme_light => 'White';

  @override
  String get theme_system => 'System';

  @override
  String get timeline_empty => 'Here is your mind cove. Write down some words that belong only to you.';

  @override
  String get timeline_load_failed => 'An error occurred while loading';

  @override
  String get timeline_reach_end => 'You\'ve reached the shore of memery';

  @override
  String get write_hint => 'Write your thoughts here...';

  @override
  String get write_title => 'Write';

  @override
  String get write_to_diary => 'Write on my diary!';
}
