import 'package:material_ui/material_ui.dart';
import 'package:mind_cove/l10n/generated/app_localizations.dart';

import '../../services/data_transfer.dart';

class ImportDataPopup extends StatelessWidget {
  final ImportInspection inspection;

  const ImportDataPopup({required this.inspection, super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(localizations.import_data),
      content: Text(localizations.import_confirm(inspection.diaryCount)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(localizations.overwrite)),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(localizations.clear_and_import)),
      ],
    );
  }
}
