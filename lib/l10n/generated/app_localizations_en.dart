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
  String get add => 'Add';

  @override
  String get add_tag => 'Add Tag';

  @override
  String get add_tags => 'Add Tags';

  @override
  String added_n_tags(Object count) {
    return 'Added $count tags';
  }

  @override
  String get app_name => 'Mind Cove';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get clear => 'Clear';

  @override
  String get default_username => 'Unknown User';

  @override
  String get edit_username => 'Edit Name';

  @override
  String get export_data => 'Export Data';

  @override
  String get import_data => 'Import Data';

  @override
  String import_confirm(Object count) {
    return 'This archive contains $count diaries. Clear current data before importing, or overwrite matching files?';
  }

  @override
  String get clear_and_import => 'Clear and Import';

  @override
  String get overwrite => 'Overwrite';

  @override
  String get data_transfer_success => 'Data transfer completed';

  @override
  String get send => 'Send';

  @override
  String data_transfer_failed(Object error) {
    return 'Data transfer failed: $error';
  }

  @override
  String get detail => 'Detail';

  @override
  String get diary_delete => 'Delete';

  @override
  String get diary_edit => 'Edit';

  @override
  String get edit_diary_title => 'Edit Diary';

  @override
  String mood(String mood) {
    String _temp0 = intl.Intl.selectLogic(mood, {
      'Angry': 'Angry',
      'Sad': 'Sad',
      'Doubtful': 'Doubtful',
      'Happy': 'Happy',
      'Surprised': 'Surprised',
      'other': 'Doubtful',
    });
    return '$_temp0';
  }

  @override
  String get error_detail => 'Error Detail';

  @override
  String get language => 'Language';

  @override
  String get manage_tags => 'Manage Tags';

  @override
  String get manage_locations => 'Manage Locations';

  @override
  String get no_locations_hint => 'No locations yet. Tap the edit icon to add one.';

  @override
  String get no_tags_hint => 'No tags yet. Tap the pencil to add a tag.';

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
  String get save => 'Save';

  @override
  String get select_tags => 'Select Tags';

  @override
  String get select_location => 'Select Location';

  @override
  String get start_writing => 'Starting writing';

  @override
  String tag_load_failed(Object error) {
    return 'Failed to load tags: $error';
  }

  @override
  String get tag_name => 'Tag name';

  @override
  String tag_save_failed(Object error) {
    return 'Failed to save tags: $error';
  }

  @override
  String location_load_failed(Object error) {
    return 'Failed to load locations: $error';
  }

  @override
  String location_save_failed(Object error) {
    return 'Failed to save locations: $error';
  }

  @override
  String get location_name => 'Location name';

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
  String timeline_filtered_by_tag(Object tag) {
    return 'Filtered by #$tag';
  }

  @override
  String timeline_no_tag_results(Object tag) {
    return 'No diaries found with #$tag.';
  }

  @override
  String get timeline_no_filter_results => 'No diaries match the selected filters.';

  @override
  String timeline_filter_load_failed(Object error) {
    return 'Failed to load filters: $error';
  }

  @override
  String get timeline_load_failed => 'An error occurred while loading';

  @override
  String get timeline_reach_end => 'You\'ve reached the shore of memery';

  @override
  String get username => 'Name';

  @override
  String get write_hint => 'Write your thoughts here...';

  @override
  String get write_title => 'Write';

  @override
  String get write_to_diary => 'Write on my diary!';

  @override
  String get update_diary => 'Save Changes';
}
