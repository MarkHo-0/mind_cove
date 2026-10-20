import 'package:material_ui/material_ui.dart';

import '../../constants.dart' show locationsFileName;
import '../../l10n/generated/app_localizations.dart';
import '../../services/maker_storage.dart';

const _locationsStorage = MakerStorage(locationsFileName);

Future<void> showLocationMaker(BuildContext parentContext, TextEditingController inputController) {
  return showModalBottomSheet<void>(
    context: parentContext,
    builder: (context) => _LocationMakerSheet(inputController: inputController),
  );
}

class _LocationMakerSheet extends StatefulWidget {
  final TextEditingController inputController;

  const _LocationMakerSheet({required this.inputController});

  @override
  State<_LocationMakerSheet> createState() => _LocationMakerSheetState();
}

class _LocationMakerSheetState extends State<_LocationMakerSheet> {
  List<String> _locations = [];
  List<String> _editingLocations = [];
  Object? _loadError;
  bool _isLoading = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    try {
      _locations = await _locationsStorage.load();
    } on Exception catch (error) {
      _loadError = error;
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _addLocation() async {
    final controller = TextEditingController();
    final location = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.add_location),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(hintText: AppLocalizations.of(context)!.location_name),
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

    final normalizedLocation = location?.trim();
    if (normalizedLocation == null || normalizedLocation.isEmpty || _editingLocations.contains(normalizedLocation)) {
      return;
    }
    setState(() => _editingLocations.add(normalizedLocation));
  }

  void _startEditing() {
    setState(() {
      _editingLocations = List.of(_locations);
      _isEditing = true;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingLocations = [];
      _isEditing = false;
    });
  }

  Future<void> _saveEditing() async {
    try {
      final deletedLocations = _locations.toSet().difference(_editingLocations.toSet());
      await _locationsStorage.save(_editingLocations);
      if (mounted) {
        setState(() {
          _locations = List.of(_editingLocations);
          _editingLocations = [];
          _isEditing = false;
        });
        if (deletedLocations.contains(widget.inputController.text)) {
          widget.inputController.clear();
        }
      }
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.location_save_failed(error))));
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
              child: Text(
                AppLocalizations.of(context)!.manage_locations,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(color: Colors.red, icon: const Icon(Icons.close), onPressed: _cancelEditing),
            IconButton(color: Colors.green, icon: const Icon(Icons.check), onPressed: _saveEditing),
          ],
        ),
        const SizedBox(height: 8.0),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.45),
          child: ListView(
            shrinkWrap: true,
            children: [
              ..._editingLocations.map(
                (location) => ListTile(
                  title: Text(location),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _editingLocations.remove(location)),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: Text(AppLocalizations.of(context)!.add),
                onTap: _addLocation,
              ),
            ],
          ),
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
              child: Text(
                AppLocalizations.of(context)!.select_location,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(icon: const Icon(Icons.edit), onPressed: _isLoading ? null : _startEditing),
          ],
        ),
        const SizedBox(height: 8.0),
        if (_isLoading)
          const CircularProgressIndicator()
        else if (_loadError != null)
          Text(AppLocalizations.of(context)!.location_load_failed(_loadError!))
        else if (_locations.isEmpty)
          Text(AppLocalizations.of(context)!.no_locations_hint)
        else
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.45),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _locations.length,
              itemBuilder: (context, index) {
                final location = _locations[index];
                final selected = widget.inputController.text == location;
                return ListTile(
                  title: Text(location),
                  trailing: selected ? const Icon(Icons.check) : null,
                  onTap: () {
                    widget.inputController.text = location;
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _isEditing ? _buildEditingMode() : _buildSelectionMode(),
    );
  }
}
