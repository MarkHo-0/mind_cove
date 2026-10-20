import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import 'package:mind_cove/views/_share/mood_renderer.dart';
import 'package:provider/provider.dart';

import '../../diary/model.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/diary_index.dart';
import '../write/write.dart';
import 'horizontal_media_list.dart';

class DiaryCard extends StatelessWidget {
  final Diary data;

  const DiaryCard(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Stack(
          children: [
            if (data.mood != null)
              Positioned(
                bottom: 0,
                right: 0,
                child: Opacity(
                  opacity: 0.2,
                  child: Tooltip(
                    message: AppLocalizations.of(context)!.mood(data.mood!.name),
                    child: MoodRenderer(mood: data.mood!, size: 32),
                  ),
                ),
              ),
            Positioned(
              top: 0,
              right: 0,
              child: PopupMenuButton(
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute<void>(builder: (_) => WriteView(editingDiary: data)));
                      },
                      child: Text(AppLocalizations.of(context)!.diary_edit),
                    ),
                    PopupMenuItem(
                      onTap: () => context.read<DiaryIndexProvider>().deleteDiary(data),
                      child: Text(AppLocalizations.of(context)!.diary_delete),
                    ),
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
                  child: InkWell(
                    onTap: () => context.read<DiaryIndexProvider>().setLocationFilter(data.location),
                    child: Text(data.location, style: TextTheme.of(context).labelMedium?.copyWith(color: Colors.grey)),
                  ),
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
                              style: TextTheme.of(context).labelSmall
                                  ?.copyWith(color: Theme.of(context).colorScheme.secondary),
                            ),
                            onTap: () {
                              context.read<DiaryIndexProvider>().setTagFilter(tag);
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
