import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:path/path.dart' as p;

class Diary {
  final DateTime writtenAt;
  final String content;
  final List<DiaryMedia> media;
  final String location;
  final Set<String> tags;
  final String mood;

  Diary({
    required this.writtenAt,
    required this.content,
    this.media = const [],
    this.location = '',
    this.tags = const {},
    this.mood = '',
  });

  @override
  String toString() {
    return 'Diary{writtenAt: $writtenAt, content: $content, mediaIds: $media, location: $location, tags: $tags, mood: $mood}';
  }

  factory Diary.fromMarkdown(String markdown, String basePath) {
    String? extract(String label) {
      final reg = RegExp('## $label\\n([\\s\\S]*?)(\\n##|\\n\\n|\\\$)', multiLine: true);
      final match = reg.firstMatch('$markdown\n\$');
      return match?.group(1)?.trim();
    }

    final DateTime? writtenAt = DateTime.tryParse(extract('Written At') ?? '');
    if (writtenAt == null) {
      throw FormatException('Invalid or missing "Written At" date in markdown');
    }

    final mediaHtml = extract('Media');
    final media = <DiaryMedia>[];
    if (mediaHtml != null) {
      final mediaReg = RegExp(r"src='([^']+)'", multiLine: true);
      final mediaMatches = mediaReg.allMatches(mediaHtml);
      for (final match in mediaMatches) {
        final mediaPath = match.group(1);
        if (mediaPath != null) {
          media.add(DiaryMedia.fromPath(p.join(basePath, mediaPath)));
        }
      }
    }

    final content = extract('Content') ?? '';

    return Diary(
      writtenAt: writtenAt,
      content: content,
      location: extract('Location') ?? '',
      tags: extract('Tags')?.split(',').toSet() ?? {},
      mood: extract('Mood') ?? '',
      media: media,
    );
  }

  String toMarkdown() {
    final b = StringBuffer();

    b.writeln("## Written At\n${writtenAt.toString()}");

    if (mood.isNotEmpty) {
      b.writeln("## Mood\n$mood");
    }

    if (location.isNotEmpty) {
      b.writeln("## Location\n$location");
    }

    if (tags.isNotEmpty) {
      b.writeln("## Tags\n${tags.join(', ')}");
    }

    b.writeln("## Content\n$content");

    if (media.isNotEmpty) {
      b.writeln(
        "## Media\n<div style=\"display: flex; gap: 10px; height: 300px; max-width: 1024px; overflow-x: auto\">",
      );
      for (final m in media) {
        if (m.type == MediaType.image) {
          b.writeln("  <img src='${m.basename}'>");
        } else if (m.type == MediaType.video) {
          b.writeln("  <video src='${m.basename}' controls></video>");
        } else {
          b.writeln("  <p>Unsupported media: ${m.basename}</p>");
        }
      }
      b.writeln("</div>");
    }

    return b.toString();
  }
}

class DiaryMedia {
  final File file;
  late MediaType type;
  DiaryMedia(this.file) {
    if (!file.existsSync()) {
      type = MediaType.notFound;
    } else {
      final ext = p.extension(file.path).toLowerCase();
      if (['.jpg', '.jpeg', '.png', '.heic'].contains(ext)) {
        type = MediaType.image;
      } else if (['.mp4', '.mov'].contains(ext)) {
        type = MediaType.video;
      } else {
        type = MediaType.unsupported;
      }
    }
  }

  factory DiaryMedia.fromPath(String path) {
    return DiaryMedia(File(path));
  }

  factory DiaryMedia.fromXFile(XFile file) {
    return DiaryMedia.fromPath(file.path);
  }

  String get ext {
    return p.extension(file.path).toLowerCase();
  }

  String get basename {
    return p.basename(file.path);
  }

  String get path {
    return file.path;
  }
}

enum MediaType { image, video, unsupported, notFound }
