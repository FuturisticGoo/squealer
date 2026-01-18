import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:squealer/core/entities/export_format.dart';

enum _ExportType { csv, json }

enum _EndOfLine { crlf, lf }

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
  _ExportType _exportType = _ExportType.csv;
  bool _exportColumnNames = true;
  bool _exportQuery = true;
  final _delimiterController = TextEditingController(text: ",");
  final _stringDelimiter = TextEditingController(text: '"');
  _EndOfLine _endOfLine = _EndOfLine.crlf;
  final _indentationController = TextEditingController(text: "4");
  static const _textFieldSize = 100.0;
  @override
  void dispose() {
    _delimiterController.dispose();
    _stringDelimiter.dispose();
    _indentationController.dispose();
    super.dispose();
  }

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
                    value: _exportType,
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
                          _exportType = value;
                        }
                      });
                    },
                  ),
                ),
                ListTile(
                  title: Text("Export column headers"),
                  trailing: DropdownButton<bool>(
                    value: _exportColumnNames,
                    items: [
                      DropdownMenuItem(value: true, child: Text("Yes")),
                      DropdownMenuItem(value: false, child: Text("No")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        if (value != null) {
                          _exportColumnNames = value;
                        }
                      });
                    },
                  ),
                ),
                ...switch (_exportType) {
                  _ExportType.csv => [
                    ListTile(
                      title: Text("Field delimiter"),

                      trailing: SizedBox(
                        width: _textFieldSize,
                        child: TextField(
                          controller: _delimiterController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text("String delimiter"),
                      trailing: SizedBox(
                        width: _textFieldSize,
                        child: TextField(
                          controller: _stringDelimiter,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text("End of line character"),
                      trailing: DropdownButton<_EndOfLine>(
                        value: _endOfLine,
                        items: [
                          DropdownMenuItem(
                            value: _EndOfLine.crlf,
                            child: Text("CRLF"),
                          ),
                          DropdownMenuItem(
                            value: _EndOfLine.lf,
                            child: Text("LF"),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            if (value != null) {
                              _endOfLine = value;
                            }
                          });
                        },
                      ),
                    ),
                  ],
                  _ExportType.json => [
                    ListTile(
                      title: Text("Export sql query"),
                      trailing: DropdownButton<bool>(
                        value: _exportQuery,
                        items: [
                          DropdownMenuItem(value: true, child: Text("Yes")),
                          DropdownMenuItem(value: false, child: Text("No")),
                        ],
                        onChanged: (value) {
                          setState(() {
                            if (value != null) {
                              _exportQuery = value;
                            }
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: Text("Indentation"),
                      trailing: SizedBox(
                        width: _textFieldSize,
                        child: TextField(
                          controller: _indentationController,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                  ],
                },
                SizedBox(height: 10),
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
                        switch (_exportType) {
                          case _ExportType.csv:
                            exportFormat = CSVFormat(
                              delimiter: _delimiterController.text,
                              endOfLine: switch (_endOfLine) {
                                _EndOfLine.crlf => "\r\n",
                                _EndOfLine.lf => "\n",
                              },
                              stringDelimiter: _stringDelimiter.text,
                              storeColumnNames: _exportColumnNames,
                            );
                          case _ExportType.json:
                            exportFormat = JSONFormat(
                              storeQuery: _exportQuery,
                              indentation:
                                  int.tryParse(_indentationController.text) ??
                                  4,
                              storeColumnNames: _exportColumnNames,
                            );
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
