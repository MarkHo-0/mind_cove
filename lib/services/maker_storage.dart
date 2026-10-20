import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../constants.dart' show savingFolderName;

class MakerStorage {
  final String fileName;

  const MakerStorage(this.fileName);

  Future<File> _file() async {
    final applicationDirectory = await getApplicationDocumentsDirectory();
    final makersDirectory = Directory(p.join(applicationDirectory.path, savingFolderName));
    await makersDirectory.create(recursive: true);
    return File(p.join(makersDirectory.path, fileName));
  }

  Future<List<String>> load() async {
    final file = await _file();
    if (!await file.exists()) return [];

    final values = await file.readAsLines();
    return values.map((value) => value.trim()).where((value) => value.isNotEmpty).toSet().toList();
  }

  Future<void> save(Iterable<String> values) async {
    final file = await _file();
    final normalizedValues = values.map((value) => value.trim()).where((value) => value.isNotEmpty).toSet();
    await file.writeAsString(normalizedValues.isEmpty ? '' : '${normalizedValues.join('\n')}\n');
  }
}
