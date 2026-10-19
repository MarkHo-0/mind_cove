import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

import '../constants.dart';
import 'model.dart';

Future<Directory>? _diariesFolderFuture;

Future<Directory> getDiariesFolder() {
  return _diariesFolderFuture ??= getApplicationDocumentsDirectory().then((dir) {
    final diaryDir = Directory(p.join(dir.path, savingFolderName, diaryFolderName));
    return diaryDir.create(recursive: true);
  });
}

Future<Directory> _createDiaryFolder(DateTime date) async {
  final safeName = diaryFolderNameFormat.format(date);
  final folder = Directory(p.join((await getDiariesFolder()).path, safeName));
  await folder.create(recursive: true);
  return folder;
}

Future<List<DiaryMedia>> _processAndSaveMedia(List<DiaryMedia> mediaFiles, Directory folder) async {
  List<DiaryMedia> processedMedia = [];
  for (final m in mediaFiles) {
    //Read first 1mb for hashing the file name, if not enough 1mb, read the whole file
    final firstMB = m.file.lengthSync() < 1024 * 1024
        ? await m.file.readAsBytes()
        : await m.file.openRead().take(1024 * 1024).toList();
    final bytes = firstMB is List<int> ? firstMB : (firstMB as List<List<int>>).expand((x) => x).toList();
    final hash = md5.convert(bytes).toString();
    String fileName = '$hash${m.ext}';

    //Copy the file to the folder and rename it
    final newFile = File(p.join(folder.path, fileName));
    await m.file.copy(newFile.path);
    processedMedia.add(DiaryMedia(newFile));
  }

  return processedMedia;
}

Future<String> saveDiary({
  required DateTime writtenAt,
  required String content,
  required Mood? mood,
  required String location,
  required Set<String> tags,
  required List<DiaryMedia> mediaFiles,
}) async {
  final folder = await _createDiaryFolder(writtenAt);
  final savedMedia = await _processAndSaveMedia(mediaFiles, folder);
  final markdown = Diary(
    writtenAt: writtenAt,
    content: content,
    mood: mood,
    location: location,
    tags: tags,
    media: savedMedia,
  ).toMarkdown();
  final fullPath = p.join(folder.path, diaryFileName);
  await File(fullPath).writeAsString(markdown);
  return Future.value(fullPath.toString());
}

Future<void> updateDiary({
  required Diary original,
  required String content,
  required Mood? mood,
  required String location,
  required Set<String> tags,
}) async {
  final baseDir = await getDiariesFolder();
  final diaryDir = Directory(p.join(baseDir.path, diaryFolderNameFormat.format(original.writtenAt)));
  final fullPath = p.join(diaryDir.path, diaryFileName);
  final updated = Diary(
    writtenAt: original.writtenAt,
    editedAt: DateTime.now(),
    content: content,
    mood: mood,
    location: location,
    tags: tags,
    media: original.media,
  );
  await File(fullPath).writeAsString(updated.toMarkdown());
}

Future<List<DiaryIndexEntry>> readDiaryIds() async {
  final baseDir = await getDiariesFolder();
  if (!await baseDir.exists()) return [];

  final entries = await baseDir.list().toList();
  final diaryIds = <DiaryIndexEntry>[];

  for (final entry in entries) {
    if (entry is! Directory) continue;

    final folderName = p.basename(entry.path);
    try {
      final writtenAt = diaryFolderNameFormat.parse(folderName);
      final bool hasMarkdown = await File(p.join(entry.path, diaryFileName)).exists();
      if (!hasMarkdown) continue;
      diaryIds.add(DiaryIndexEntry(id: folderName, writtenAt: writtenAt));
    } catch (e) {
      debugPrint('Failed to parse date from folder name "$folderName": $e');
    }
  }

  diaryIds.sort((a, b) => b.id.compareTo(a.id));
  debugPrint('Found ${diaryIds.length} diaries in $baseDir');

  return diaryIds;
}

Future<Diary> loadDiary(String id) async {
  final baseDir = await getDiariesFolder();
  final diaryDir = Directory(p.join(baseDir.path, id));
  final hasMarkdown = await File(p.join(diaryDir.path, diaryFileName)).exists();
  if (!hasMarkdown) throw Exception("Diary not found");

  final content = await File(p.join(diaryDir.path, diaryFileName)).readAsString();
  return Diary.fromMarkdown(content, diaryDir.path);
}

Future<void> deleteDiary(Diary diary) async {
  final baseDir = await getDiariesFolder();
  final diaryDir = Directory(p.join(baseDir.path, diaryFolderNameFormat.format(diary.writtenAt)));
  if (await diaryDir.exists()) {
    await diaryDir.delete(recursive: true);
  }
}
