import 'package:material_ui/material_ui.dart';
import 'package:mind_cove/l10n/generated/app_localizations.dart';

class EditUsernamePopup extends StatefulWidget {
  const EditUsernamePopup({super.key, required this.initialUsername});

  final String initialUsername;

  @override
  State<EditUsernamePopup> createState() => _EditUsernamePopupState();
}

class _EditUsernamePopupState extends State<EditUsernamePopup> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialUsername);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (_controller.text.trim().isEmpty) return;
    Navigator.of(context).pop(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(localizations.edit_username),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(hintText: localizations.username),
        onSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(localizations.cancel)),
        TextButton(onPressed: _save, child: Text(localizations.save)),
      ],
    );
  }
}
