import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../diary/model.dart';
import '../../l10n/generated/app_localizations.dart';
import 'horizontal_media_list.dart';

class DiaryCard extends StatelessWidget {
  final Diary data;
  final Function() onDelete;
  final Function() onEdit;

  const DiaryCard(this.data, {super.key, required this.onDelete, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: PopupMenuButton(
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(onTap: onEdit, child: Text(AppLocalizations.of(context)!.diary_edit)),
                    PopupMenuItem(onTap: onDelete, child: Text(AppLocalizations.of(context)!.diary_delete)),
                  ];
                },
                child: Icon(Icons.more_vert),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat.MMMMEEEEd(AppLocalizations.of(context)!.localeName).format(data.writtenAt),
                  style: TextTheme.of(context).titleLarge,
                ),
                Visibility(
                  visible: data.location.isNotEmpty,
                  child: Text(data.location, style: TextTheme.of(context).labelMedium?.copyWith(color: Colors.grey)),
                ),
                Visibility(
                  visible: data.tags.isNotEmpty,
                  child: Wrap(
                    spacing: 15,
                    runSpacing: 5,
                    children: data.tags
                        .map(
                          (tag) => InkWell(
                            child: Text(
                              '#$tag',
                              style: TextTheme.of(
                                context,
                              ).labelSmall?.copyWith(color: Theme.of(context).colorScheme.secondary),
                            ),
                            onTap: () {
                              // TODO: Implement tag filtering
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
                Visibility(
                  visible: data.content.isNotEmpty,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(data.content, style: TextTheme.of(context).bodyMedium),
                  ),
                ),
                Visibility(visible: data.media.isNotEmpty, child: HorizontalMediaList(data.media)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
