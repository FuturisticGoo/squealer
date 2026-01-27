import 'package:flutter/material.dart';

class TableNameTile extends StatelessWidget {
  const TableNameTile({super.key, required this.tableName});

  final String tableName;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        "Table",
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(tableName),
    );
  }
}
