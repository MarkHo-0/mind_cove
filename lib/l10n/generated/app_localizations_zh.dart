// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get add_location => '添加位置';

  @override
  String get add_media => '添加媒體';

  @override
  String get add_tags => '添加標籤';

  @override
  String added_n_tags(Object count) {
    return '已添加 $count 個標籤';
  }

  @override
  String get app_name => '心靈小海灣';

  @override
  String get close => '關閉';

  @override
  String get default_username => '無名氏';

  @override
  String get detail => '詳情';

  @override
  String get diary_delete => '刪除';

  @override
  String get diary_edit => '編輯';

  @override
  String get error_detail => '錯誤詳情';

  @override
  String get language => '語言';

  @override
  String get notify_me => '提醒我寫日誌';

  @override
  String get page_calendar => '日曆';

  @override
  String get page_settings => '設定';

  @override
  String get page_timeline => '時間軸';

  @override
  String get page_write => '隨手記下';

  @override
  String selected_n_media(Object count) {
    return '已選 $count 份媒體檔案';
  }

  @override
  String get start_writing => '開始撰寫';

  @override
  String get theme => '主題';

  @override
  String get theme_black => '暗黑';

  @override
  String get theme_light => '明亮';

  @override
  String get theme_system => '跟隨系統';

  @override
  String get timeline_empty => '這裡是你的心靈小灣～寫下一些話，只屬於你自己。';

  @override
  String get timeline_load_failed => '加載時發生錯誤';

  @override
  String get timeline_reach_end => '你已抵達記憶的岸邊';

  @override
  String get write_hint => '在這裡寫下你的想法...';

  @override
  String get write_title => '撰寫';

  @override
  String get write_to_diary => '寫在我的日誌上！';
}
