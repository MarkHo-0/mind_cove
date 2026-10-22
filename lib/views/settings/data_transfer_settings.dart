import 'package:material_ui/material_ui.dart';
import 'package:mind_cove/l10n/generated/app_localizations.dart';

import '../../services/app_restart.dart';
import '../../services/data_transfer.dart';
import 'import_data_popup.dart';

class DataTransferSettings extends StatefulWidget {
  const DataTransferSettings({super.key});

  @override
  State<DataTransferSettings> createState() => _DataTransferSettingsState();
}

class _DataTransferSettingsState extends State<DataTransferSettings> {
  bool _isBusy = false;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.file_upload_outlined),
          title: Text(localizations.export_data),
          trailing: _isBusy ? const CircularProgressIndicator() : null,
          onTap: _isBusy ? null : () => _export(localizations),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.file_download_outlined),
          title: Text(localizations.import_data),
          onTap: _isBusy ? null : () => _import(localizations),
        ),
      ],
    );
  }

  Future<void> _export(AppLocalizations localizations) async {
    await _run(
      localizations,
      () => exportData(dialogTitle: localizations.export_data),
      onSuccess: (data) => _share(data, localizations),
    );
  }

  Future<void> _import(AppLocalizations localizations) async {
    try {
      final inspection = await pickAndInspectImport(dialogTitle: localizations.import_data);
      if (inspection == null || !mounted) return;

      final clearExisting = await showDialog<bool>(
        context: context,
        builder: (_) => ImportDataPopup(inspection: inspection),
      );
      if (clearExisting == null || !mounted) return;

      final imported = await _run(localizations, () async {
        await importData(inspection, clearExisting: clearExisting);
        return true;
      });
      if (imported == true && mounted) AppRestart.restart(context);
    } catch (error) {
      if (mounted) _showMessage(localizations.data_transfer_failed(error.toString()));
    }
  }

  Future<T?> _run<T>(
    AppLocalizations localizations,
    Future<T?> Function() operation, {
    Future<void> Function(T value)? onSuccess,
  }) async {
    setState(() => _isBusy = true);
    try {
      final result = await operation();
      if (result == null) return null;
      if (mounted) {
        _showMessage(
          localizations.data_transfer_success,
          action: onSuccess == null
              ? null
              : SnackBarAction(label: localizations.send, onPressed: () => onSuccess(result)),
        );
      }
      return result;
    } catch (error) {
      if (mounted) _showMessage(localizations.data_transfer_failed(error.toString()));
      return null;
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _share(ExportedData data, AppLocalizations localizations) async {
    try {
      await shareExportedData(data);
    } catch (error) {
      if (mounted) _showMessage(localizations.data_transfer_failed(error.toString()));
    }
  }

  void _showMessage(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), action: action));
  }
}
