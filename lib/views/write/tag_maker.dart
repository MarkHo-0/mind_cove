import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../constants.dart' show savingFolderName, tagsFileName;

Future<List<String>?> showTagMaker(BuildContext parentContext, TagsEditingController inputController) async {
  return showModalBottomSheet<List<String>>(
    context: parentContext,
    builder: (BuildContext context) => _TagMakerSheet(inputController: inputController),
  );
}

class _TagMakerSheet extends StatefulWidget {
  final TagsEditingController inputController;

  const _TagMakerSheet({required this.inputController});

  @override
  State<_TagMakerSheet> createState() => _TagMakerSheetState();
}

class _TagMakerSheetState extends State<_TagMakerSheet> {
  List<String> _tags = [];
  List<String> _editingTags = [];
  Object? _loadError;
  bool _isLoading = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<File> _tagsFile() async {
    final applicationDirectory = await getApplicationDocumentsDirectory();
    final tagsDirectory = Directory(p.join(applicationDirectory.path, savingFolderName));
    await tagsDirectory.create(recursive: true);
    return File(p.join(tagsDirectory.path, tagsFileName));
  }

  Future<void> _loadTags() async {
    try {
      final file = await _tagsFile();
      if (await file.exists()) {
        final savedTags = (await file.readAsLines()).map((tag) => tag.trim()).where((tag) => tag.isNotEmpty);
        _tags = savedTags.toSet().toList();
      }
    } on IOException catch (error) {
      _loadError = 'Failed to load tags: $error';
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addTag() async {
    final controller = TextEditingController();
    final tag = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.add_tag),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(hintText: AppLocalizations.of(context)!.tag_name),
          onSubmitted: (_) => Navigator.of(context).pop(controller.text),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(AppLocalizations.of(context)!.cancel)),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(AppLocalizations.of(context)!.add),
          ),
        ],
      ),
    );
    controller.dispose();
    final normalizedTag = tag?.trim();
    if (normalizedTag == null || normalizedTag.isEmpty || _editingTags.contains(normalizedTag)) return;
    setState(() => _editingTags.add(normalizedTag));
  }

  void _startEditing() {
    setState(() {
      _editingTags = List.of(_tags);
      _isEditing = true;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingTags = [];
      _isEditing = false;
    });
  }

  Future<void> _saveEditing() async {
    try {
      final file = await _tagsFile();
      await file.writeAsString(_editingTags.isEmpty ? '' : '${_editingTags.join('\n')}\n');
      if (mounted) {
        setState(() {
          _tags = List.of(_editingTags);
          _editingTags = [];
          _isEditing = false;
        });
      }
    } on IOException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.tag_save_failed(error))));
      }
    }
  }

  Widget _buildEditingMode() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(AppLocalizations.of(context)!.select_tags, style: Theme.of(context).textTheme.titleMedium),
            ),
            IconButton(color: Colors.red, icon: const Icon(Icons.close), onPressed: _cancelEditing),
            IconButton(color: Colors.green, icon: const Icon(Icons.check), onPressed: _saveEditing),
          ],
        ),
        const SizedBox(height: 16.0),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            ..._editingTags.map(
              (tag) => InputChip(label: Text(tag), onDeleted: () => setState(() => _editingTags.remove(tag))),
            ),
            ActionChip(
              avatar: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context)!.add),
              onPressed: _addTag,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectionMode() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(AppLocalizations.of(context)!.manage_tags, style: Theme.of(context).textTheme.titleMedium),
            ),
            IconButton(icon: const Icon(Icons.edit), onPressed: _isLoading ? null : _startEditing),
          ],
        ),
        const SizedBox(height: 16.0),
        if (_isLoading)
          const CircularProgressIndicator()
        else if (_loadError != null)
          Text(AppLocalizations.of(context)!.tag_load_failed(_loadError!))
        else if (_tags.isEmpty)
          Text(AppLocalizations.of(context)!.no_tags_hint)
        else
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _tags.map((tag) {
              return AnimatedBuilder(
                animation: widget.inputController,
                builder: (context, _) {
                  return InputChip(
                    selected: widget.inputController.tags.contains(tag),
                    label: Text(tag),
                    onPressed: () {
                      if (widget.inputController.contains(tag)) {
                        widget.inputController.remove(tag);
                      } else {
                        widget.inputController.add(tag);
                      }
                    },
                  );
                },
              );
            }).toList(),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [_isEditing ? _buildEditingMode() : _buildSelectionMode()],
      ),
    );
  }
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

  void replace(Set<String> tags) {
    _tags = Set<String>.from(tags);
    notifyListeners();
  }
}
