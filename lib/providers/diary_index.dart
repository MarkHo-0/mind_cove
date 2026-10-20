import 'package:flutter/foundation.dart';
import 'package:mind_cove/diary/service.dart' as diary_service;
import 'package:mind_cove/diary/model.dart';

class DiaryIndexProvider extends ChangeNotifier {
  List<DiaryIndexEntry> _diaryEntries = const [];
  Future<List<DiaryIndexEntry>>? _loadFuture;
  String? _selectedTag;
  String? _selectedLocation;

  List<DiaryIndexEntry> get diaryEntries => _diaryEntries;
  String? get selectedTag => _selectedTag;
  String? get selectedLocation => _selectedLocation;

  Future<List<DiaryIndexEntry>> getDiaryEntries({bool forceRefresh = false}) {
    if (!forceRefresh && _loadFuture != null) return _loadFuture!;

    final future = _loadDiaryIds();
    _loadFuture = future;
    return future;
  }

  Future<List<DiaryIndexEntry>> _loadDiaryIds() async {
    try {
      final diaryEntries = await diary_service.readDiaryIds();
      _diaryEntries = List.unmodifiable(diaryEntries);
      notifyListeners();
      return _diaryEntries;
    } catch (_) {
      _loadFuture = null;
      rethrow;
    }
  }

  Future<String> saveDiary({
    required DateTime writtenAt,
    required String content,
    required Mood? mood,
    required String location,
    required Set<String> tags,
    required List<DiaryMedia> mediaFiles,
  }) async {
    final savedPath = await diary_service.saveDiary(
      writtenAt: writtenAt,
      content: content,
      mood: mood,
      location: location,
      tags: tags,
      mediaFiles: mediaFiles,
    );
    addDiary(writtenAt);
    return savedPath;
  }

  Future<void> deleteDiary(Diary diary) async {
    await diary_service.deleteDiary(diary);
    removeDiary(diary.writtenAt);
  }

  Future<void> updateDiary({
    required Diary original,
    required String content,
    required Mood? mood,
    required String location,
    required Set<String> tags,
  }) async {
    await diary_service.updateDiary(original: original, content: content, mood: mood, location: location, tags: tags);
    notifyListeners();
  }

  void setTagFilter(String? tag) {
    if (_selectedTag == tag) return;
    _selectedTag = tag;
    notifyListeners();
  }

  void setLocationFilter(String? location) {
    if (_selectedLocation == location) return;
    _selectedLocation = location;
    notifyListeners();
  }

  void clearTagFilter() => setTagFilter(null);

  void clearLocationFilter() => setLocationFilter(null);

  void addDiary(DateTime writtenAt) {
    final entry = DiaryIndexEntry.fromDate(writtenAt);
    if (_diaryEntries.any((item) => item.id == entry.id)) return;

    _diaryEntries = List.unmodifiable([entry, ..._diaryEntries]..sort((a, b) => b.id.compareTo(a.id)));
    notifyListeners();
  }

  void removeDiary(DateTime writtenAt) {
    final diaryId = DiaryIndexEntry.fromDate(writtenAt).id;
    if (!_diaryEntries.any((item) => item.id == diaryId)) return;

    _diaryEntries = List.unmodifiable(_diaryEntries.where((entry) => entry.id != diaryId));
    notifyListeners();
  }

  bool containsDiary(DateTime writtenAt) {
    final diaryId = DiaryIndexEntry.fromDate(writtenAt).id;
    return _diaryEntries.any((entry) => entry.id == diaryId);
  }
}
