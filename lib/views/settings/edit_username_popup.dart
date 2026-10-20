import 'package:material_ui/material_ui.dart';
import 'package:mind_cove/l10n/generated/app_localizations.dart';

typedef SubmitCallback = void Function(String username);

class EditUsernamePopup extends StatefulWidget {
  const EditUsernamePopup({super.key, required this.currentUsername, required this.onSubmit});

  final String currentUsername;
  final SubmitCallback onSubmit;

  @override
  State<EditUsernamePopup> createState() => _EditUsernamePopupState();
}

class _EditUsernamePopupState extends State<EditUsernamePopup> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentUsername);
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (_controller.text.trim().isEmpty) return;
    widget.onSubmit(_controller.text.trim());
    Navigator.of(context).pop();
  }

  bool get _isSaveEnabled => _controller.text.trim().isNotEmpty && _controller.text != widget.currentUsername;

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
        TextButton(onPressed: _isSaveEnabled ? _save : null, child: Text(localizations.save)),
      ],
    );
  }
}
