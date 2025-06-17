import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mind_cove/diary/model.dart';
import 'package:mind_cove/diary/service.dart';
import 'package:mind_cove/l10n/generated/app_localizations.dart';
import 'package:mind_cove/views/_share/horizontal_media_list.dart';
import 'package:mind_cove/views/_share/styles/padding.dart';
import 'package:mind_cove/views/write/mood_selector.dart';
import 'package:mind_cove/views/write/location_maker.dart';
import 'package:mind_cove/views/write/tag_maker.dart';
import 'package:provider/provider.dart';

import '../../providers/views.dart';

class WriteView extends StatefulWidget {
  const WriteView({super.key});

  @override
  State<WriteView> createState() => _WriteViewState();
}

class _WriteViewState extends State<WriteView> with AutomaticKeepAliveClientMixin<WriteView> {
  final TextEditingController contentController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TagsEditingController tagsController = TagsEditingController();
  final MoodEditingController moodController = MoodEditingController();
  List<DiaryMedia> selectedMedia = [];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: pagePadding,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.write_title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              TextField(
                minLines: 5,
                controller: contentController,
                maxLines: null,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: AppLocalizations.of(context)!.write_hint,
                ),
              ),

              if (selectedMedia.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: HorizontalMediaList(
                    selectedMedia,
                    onMediaDelete: (media) {
                      setState(() => selectedMedia.remove(media));
                    },
                  ),
                ),

              MoodSelector(moodController),

              ListTile(
                contentPadding: EdgeInsets.all(0),
                leading: const Icon(Icons.add_a_photo),
                title: Text(
                  selectedMedia.isEmpty
                      ? AppLocalizations.of(context)!.add_media
                      : AppLocalizations.of(context)!.selected_n_media(selectedMedia.length),
                ),
                onTap: pickMedia,
                trailing: const Icon(Icons.chevron_right),
              ),
              ListTile(
                contentPadding: EdgeInsets.all(0),
                leading: const Icon(Icons.location_on),
                title: Text(
                  locationController.text.isEmpty
                      ? AppLocalizations.of(context)!.add_location
                      : locationController.text,
                ),
                onTap: () => showLocationMaker(context, locationController).then((_) => setState(() {})),
                trailing: const Icon(Icons.chevron_right),
              ),
              ListTile(
                contentPadding: EdgeInsets.all(0),
                leading: const Icon(Icons.tag),
                title: Text(
                  tagsController.tags.isEmpty
                      ? AppLocalizations.of(context)!.add_tags
                      : AppLocalizations.of(context)!.added_n_tags(tagsController.tags.length),
                ),
                subtitle: tagsController.tags.isNotEmpty ? Text(tagsController.tags.join(', ')) : null,
                onTap: () => showTagMaker(context, tagsController).then((_) => setState(() {})),
                trailing: const Icon(Icons.chevron_right),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () => onJotDown(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(AppLocalizations.of(context)!.write_to_diary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void pickMedia() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> media = await picker.pickMultipleMedia();

    if (media.isEmpty) return;
    setState(() => selectedMedia = media.map((file) => DiaryMedia.fromXFile(file)).toList());
  }

  @override
  bool get wantKeepAlive => true;

  void onJotDown(BuildContext context) {
    if (contentController.text.isEmpty && selectedMedia.isEmpty) {
      return;
    }

    final saveAction = saveDiary(
      writtenAt: DateTime.now(),
      content: contentController.text,
      mood: moodController.value,
      location: locationController.text,
      tags: tagsController.tags,
      mediaFiles: selectedMedia,
    );

    saveAction
        .then((savedPath) {
          reset();
          context.read<ViewsProvider>().changeView(ViewType.timeline);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(savedPath)));
        })
        .onError((err, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(err.toString()),
              action: SnackBarAction(
                label: 'detail',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(title: Text(err.toString()), content: Text(stack.toString()));
                    },
                  );
                },
              ),
            ),
          );
        });
  }

  @override
  void dispose() {
    contentController.dispose();
    locationController.dispose();
    tagsController.dispose();
    moodController.dispose();
    super.dispose();
  }

  void reset() {
    contentController.clear();
    locationController.clear();
    tagsController.clear();
    moodController.clear();
    selectedMedia.clear();
    FocusScope.of(context).unfocus();
  }
}
