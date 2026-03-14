import 'package:flutter/material.dart';

Future<(String, String)?> showNewStatementDialog(
  BuildContext context, {
  required String initialStatement,
}) {
  return showAdaptiveDialog<(String, String)?>(
    context: context,
    builder: (context) {
      return SaveStatementDialog(initialStatement: initialStatement);
    },
  );
}

class SaveStatementDialog extends StatefulWidget {
  final String initialStatement;
  const SaveStatementDialog({super.key, required this.initialStatement});

  @override
  State<SaveStatementDialog> createState() => _SaveStatementDialogState();
}

class _SaveStatementDialogState extends State<SaveStatementDialog> {
  late final TextEditingController nameTextEditor;
  late final TextEditingController statementTextEditor;
  final formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    nameTextEditor = TextEditingController();
    statementTextEditor = TextEditingController(text: widget.initialStatement);
  }

  @override
  void dispose() {
    nameTextEditor.dispose();
    statementTextEditor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SimpleDialog(
        title: Text("Save statement"),
        contentPadding: EdgeInsetsGeometry.all(16),

        children: [
          TextFormField(
            controller: nameTextEditor,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              label: Text("Name (optional)"),
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: statementTextEditor,
            minLines: 1,
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Cannot be empty";
              }
              return null;
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              label: Text("Statement"),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
              SizedBox(width: 10),
              FilledButton(
                onPressed: () async {
                  if (formKey.currentState?.validate() == true) {
                    Navigator.of(context).pop((
                      nameTextEditor.text.trim(),
                      statementTextEditor.text.trim(),
                    ));
                  }
                },
                child: Text("Save"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
