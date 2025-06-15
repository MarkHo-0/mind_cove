import 'package:flutter/material.dart';

Future<List<String>?> showTagMaker(BuildContext parentContext, TagsEditingController inputController) async {
  TagsEditingController previousTagsController = TagsEditingController();

  return showModalBottomSheet<List<String>>(
    context: parentContext,
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Manage Tags', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16.0),

            const SizedBox(height: 16.0),
            FutureBuilder(
              future: () async {
                // Simulate fetching tags from a database or API
                await Future.delayed(Duration(milliseconds: 300));
                return ['Work', 'Personal', 'Health', 'Travel', 'Family', 'Friends'];
              }(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (snapshot.connectionState != ConnectionState.done || !snapshot.hasData) {
                  return SizedBox.shrink();
                }

                return Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: snapshot.data!.map((tag) {
                    return AnimatedBuilder(
                      animation: inputController,
                      builder: (context, _) {
                        return InputChip(
                          selected: inputController.tags.contains(tag),
                          label: Text(tag),
                          onPressed: () {
                            if (inputController.contains(tag)) {
                              inputController.remove(tag);
                            } else {
                              inputController.add(tag);
                            }
                          },
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}

class TagsEditingController extends ChangeNotifier {
  late Set<String> _tags;

  TagsEditingController({Set<String>? initialTags}) {
    _tags = initialTags ?? {};
  }

  Set<String> get tags => _tags;

  void add(String tag) {
    _tags.add(tag);
    notifyListeners();
  }

  void remove(String tag) {
    _tags.remove(tag);
    notifyListeners();
  }

  bool contains(String tag) {
    return _tags.contains(tag);
  }

  void clear() {
    _tags.clear();
    notifyListeners();
  }
}
