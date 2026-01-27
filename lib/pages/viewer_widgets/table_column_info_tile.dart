import 'package:flutter/material.dart';
import 'package:squealer/core/entities/database_data_entities.dart';

class TableColumnInfoTile extends StatelessWidget {
  final TableColumn column;
  const TableColumnInfoTile({super.key, required this.column});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(column.columnName),
      childrenPadding: EdgeInsets.only(left: 20),
      shape: const Border(),
      children: [
        ListTile(title: Text(column.dataType)),
        if (column.notNullable) ListTile(title: Text("NOT NULL")),
        if (column.unique) ListTile(title: Text("UNIQUE")),
        if (column.isPrimaryKey) ListTile(title: Text("PRIMARY KEY")),
        if (column.defaultValue != null)
          ListTile(title: Text("DEFAULT ${column.defaultValue}")),
      ],
    );
  }
}
