import 'dart:io';
import 'package:flutter/material.dart';

import '../../diary/model.dart';

class FullScreenMediaViewer extends StatelessWidget {
  final List<DiaryMedia> mediaItems;
  final int initialIndex;

  const FullScreenMediaViewer({super.key, required this.mediaItems, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
      ),
      body: PageView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: mediaItems.length,
        controller: PageController(initialPage: initialIndex),
        itemBuilder: (context, index) {
          final media = mediaItems[index];
          return Hero(
            tag: media.file.path,
            child: Image.file(
              media.file,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Text('Error loading image');
              },
            ),
          );
        },
      ),
    );
  }
}
