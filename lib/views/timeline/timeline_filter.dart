import 'package:material_ui/material_ui.dart';
import 'package:mind_cove/constants.dart' show locationsFileName, tagsFileName;
import 'package:mind_cove/l10n/generated/app_localizations.dart';
import 'package:mind_cove/providers/diary_index.dart';
import 'package:mind_cove/services/maker_storage.dart';
import 'package:provider/provider.dart';

const _diaryCardRadius = 12.0;

class TimelineFilter extends StatefulWidget {
  const TimelineFilter({super.key});

  @override
  State<TimelineFilter> createState() => _TimelineFilterState();
}

class _TimelineFilterState extends State<TimelineFilter> {
  @override
  Widget build(BuildContext context) {
    return _buildFilterShell(
      context,
      child: Row(
        children: [
          Expanded(
            child: _TimelineFilterField(
              label: AppLocalizations.of(context)!.select_location,
              icon: Icons.place_outlined,
              storage: const MakerStorage(locationsFileName),
              value: context.watch<DiaryIndexProvider>().selectedLocation,
              onChanged: context.read<DiaryIndexProvider>().setLocationFilter,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _TimelineFilterField(
              label: AppLocalizations.of(context)!.select_tags,
              icon: Icons.tag,
              storage: const MakerStorage(tagsFileName),
              value: context.watch<DiaryIndexProvider>().selectedTag,
              onChanged: context.read<DiaryIndexProvider>().setTagFilter,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterShell(BuildContext context, {required Widget child}) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(10), child: child),
    );
  }
}

class _TimelineFilterField extends StatefulWidget {
  final String label;
  final IconData icon;
  final MakerStorage storage;
  final String? value;
  final ValueChanged<String?> onChanged;

  const _TimelineFilterField({
    required this.label,
    required this.icon,
    required this.storage,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_TimelineFilterField> createState() => _TimelineFilterFieldState();
}

class _TimelineFilterFieldState extends State<_TimelineFilterField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  Object? _loadError;
  bool _refreshingOnFocus = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(covariant _TimelineFilterField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value ?? '',
        selection: TextSelection.collapsed(offset: (widget.value ?? '').length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_handleFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _submit(String text) {
    final value = text.trim();
    widget.onChanged(value.isEmpty ? null : value);
  }

  void _handleFocusChanged() {
    if (!_focusNode.hasFocus || _refreshingOnFocus) return;
    _refreshingOnFocus = true;
    final currentValue = _controller.value;
    _controller.clear();
    _controller.value = currentValue;
    _refreshingOnFocus = false;
  }

  Future<Iterable<String>> _buildOptions(TextEditingValue value) async {
    try {
      final options = await widget.storage.load();
      if (mounted && _loadError != null) setState(() => _loadError = null);
      final query = value.text.trim().toLowerCase();
      if (query.isEmpty) return options;
      return options.where((option) => option.toLowerCase().contains(query));
    } on Exception catch (error) {
      if (mounted) setState(() => _loadError = error);
      return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      textEditingController: _controller,
      focusNode: _focusNode,
      optionsBuilder: (textEditingValue) {
        return _buildOptions(textEditingValue);
      },
      onSelected: (value) => widget.onChanged(value),
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.label,
            helperText: _loadError == null
                ? null
                : AppLocalizations.of(context)!.timeline_filter_load_failed(_loadError!),
            prefixIcon: Icon(widget.icon, size: 20),
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) => value.text.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                      tooltip: AppLocalizations.of(context)!.clear,
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.clear();
                        widget.onChanged(null);
                      },
                    ),
            ),
          ),
          onChanged: (value) {
            if (!_refreshingOnFocus && value.trim().isEmpty) {
              widget.onChanged(null);
            }
          },
          onSubmitted: (value) {
            _submit(value);
            onFieldSubmitted();
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            color: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_diaryCardRadius)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_diaryCardRadius),
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: options
                      .map(
                        (option) => ListTile(
                          dense: true,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          title: Text(option),
                          onTap: () => onSelected(option),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
