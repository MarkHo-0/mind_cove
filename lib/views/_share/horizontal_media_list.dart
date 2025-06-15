import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mind_cove/views/_share/full_screen_media_viewer.dart';

import '../../diary/model.dart';

const double mediaSize = 100.0;

class HorizontalMediaList extends StatelessWidget {
  final List<DiaryMedia> mediaItems;
  final bool videoAutoPlay;
  final Function(DiaryMedia)? onMediaDelete;

  const HorizontalMediaList(this.mediaItems, {super.key, this.videoAutoPlay = false, this.onMediaDelete});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ScrollConfiguration(
        behavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.stylus,
            PointerDeviceKind.unknown,
          },
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: mediaItems.map((file) {
              return Padding(
                key: ValueKey(file),
                padding: const EdgeInsets.only(right: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Stack(
                    children: [
                      // 媒體容器
                      buildSingleMediaContainer(file),

                      // 一般點擊事件
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              final index = mediaItems.indexOf(file);
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) {
                                    return FullScreenMediaViewer(mediaItems: mediaItems, initialIndex: index);
                                  },
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return FadeTransition(opacity: animation, child: child);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // 刪除按鈕
                      Visibility(
                        visible: onMediaDelete != null,
                        child: Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(icon: const Icon(Icons.close), onPressed: () => onMediaDelete!(file)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget buildSingleMediaContainer(DiaryMedia media) {
    if (media.type == MediaType.image) {
      return Hero(
        tag: media.file.path,
        child: Image.file(media.file, width: mediaSize, height: mediaSize, fit: BoxFit.cover, scale: 0.3),
      );
    }

    return SizedBox(
      width: mediaSize,
      height: mediaSize,
      child: const Center(child: Text('Unsupported Media')),
    );
  }
}
