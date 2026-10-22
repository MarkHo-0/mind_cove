import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../constants.dart';
import '../diary/model.dart';

class ImportInspection {
  final Archive archive;
  final int diaryCount;

  const ImportInspection(this.archive, this.diaryCount);
}

class ExportedData {
  final Uint8List bytes;
  final String fileName;

  const ExportedData({required this.bytes, required this.fileName});
}

Future<String?> pickImportSource({required String dialogTitle}) async {
  final result = await FilePicker.pickFile(dialogTitle: dialogTitle, type: FileType.custom, allowedExtensions: ['zip']);
  return result?.path;
}

Future<Directory> get _savingFolder async {
  final documents = await getApplicationDocumentsDirectory();
  return Directory(p.join(documents.path, savingFolderName));
}

Future<ExportedData?> exportData({required String dialogTitle}) async {
  final source = await _savingFolder;
  final archive = Archive();
  if (await source.exists()) {
    await for (final entity in source.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        final relativePath = p.relative(entity.path, from: source.path).replaceAll('\\', '/');
        archive.addFile(ArchiveFile(relativePath, await entity.length(), await entity.readAsBytes()));
      }
    }
  }

  final encoded = ZipEncoder().encode(archive);
  final exportedData = ExportedData(bytes: Uint8List.fromList(encoded), fileName: 'mind_cove_backup.zip');
  final savedUri = await FilePicker.saveFile(
    fileName: 'mind_cove_backup.zip',
    bytes: exportedData.bytes,
    mimeType: 'application/zip',
    dialogTitle: dialogTitle,
    type: FileType.custom,
    allowedExtensions: ['zip'],
  );
  return savedUri == null ? null : exportedData;
}

Future<ShareResult> shareExportedData(ExportedData data) {
  return SharePlus.instance.share(
    ShareParams(
      files: [XFile.fromData(data.bytes, mimeType: 'application/zip')],
      fileNameOverrides: [data.fileName],
      title: data.fileName,
    ),
  );
}

Future<ImportInspection> inspectImport(String zipPath) async {
  final bytes = await File(zipPath).readAsBytes();
  final archive = ZipDecoder().decodeBytes(bytes);
  var diaryCount = 0;
  var hasRecognizedContent = false;

  for (final entry in archive) {
    final name = _safeArchivePath(entry.name);
    if (name == null) throw const FormatException('Archive contains an unsafe path');
    if (entry.isFile && (name == settingsFileName || name.startsWith('$diaryFolderName/'))) {
      hasRecognizedContent = true;
    }

    if (entry.isFile && p.basename(name) == diaryFileName && name.startsWith('$diaryFolderName/')) {
      try {
        Diary.fromMarkdown(String.fromCharCodes(entry.content), '');
        diaryCount++;
      } on FormatException catch (error) {
        throw FormatException('Invalid diary file "$name": $error');
      }
    }
  }

  if (!hasRecognizedContent) {
    throw const FormatException('This ZIP does not contain Mind Cove data');
  }
  return ImportInspection(archive, diaryCount);
}

Future<ImportInspection?> pickAndInspectImport({required String dialogTitle}) async {
  final source = await pickImportSource(dialogTitle: dialogTitle);
  if (source == null) return null;
  return inspectImport(source);
}

Future<void> importData(ImportInspection inspection, {required bool clearExisting}) async {
  final destination = await _savingFolder;
  if (clearExisting && await destination.exists()) {
    await destination.delete(recursive: true);
  }
  await destination.create(recursive: true);

  for (final entry in inspection.archive) {
    final relativePath = _safeArchivePath(entry.name);
    if (relativePath == null || !entry.isFile) continue;
    final output = File(p.joinAll([destination.path, ...p.posix.split(relativePath)]));
    await output.parent.create(recursive: true);
    await output.writeAsBytes(entry.content, flush: true);
  }
}

String? _safeArchivePath(String path) {
  final normalized = path.replaceAll('\\', '/');
  if (normalized.isEmpty || normalized.startsWith('/') || normalized.contains(':')) return null;
  final segments = p.posix.split(normalized);
  if (segments.any((segment) => segment.isEmpty || segment == '..' || segment == '.')) return null;
  return segments.join('/');
}
