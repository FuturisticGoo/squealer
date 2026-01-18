import 'package:flutter/material.dart';
import 'package:squealer/core/entities/export_format.dart';

enum _ExportType { csv, json }

Future<ExportFormat?> showExportDialog(BuildContext context) {
  return showAdaptiveDialog<ExportFormat?>(
    context: context,
    builder: (context) {
      return ExportDialog();
    },
  );
}

class ExportDialog extends StatefulWidget {
  const ExportDialog({super.key});

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  _ExportType exportType = _ExportType.csv;
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text("Export data"),
      contentPadding: const EdgeInsets.all(16.0),
      children: [
        const SizedBox(height: 20),
        Builder(
          builder: (context) {
            return Column(
              children: [
                ListTile(
                  title: Text("Export format"),
                  trailing: DropdownButton<_ExportType>(
                    value: exportType,
                    items: [
                      DropdownMenuItem(
                        value: _ExportType.csv,
                        child: Text("CSV"),
                      ),
                      DropdownMenuItem(
                        value: _ExportType.json,
                        child: Text("JSON"),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        if (value != null) {
                          exportType = value;
                        }
                      });
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: () {
                        ExportFormat exportFormat;
                        switch (exportType) {
                          case _ExportType.csv:
                            exportFormat = CSVFormat();
                          case _ExportType.json:
                            exportFormat = JSONFormat();
                        }
                        Navigator.pop(context, exportFormat);
                      },
                      child: const Text("Export"),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
