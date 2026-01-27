import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:futuristicgoo_utils/futuristicgoo_utils.dart';

class SQLTile extends StatelessWidget {
  const SQLTile({super.key, required this.sql});

  final String sql;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        "SQL",
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(sql),
      onLongPress: () async {
        await Clipboard.setData(ClipboardData(text: sql));
        if (context.mounted) {
          showSnackBar(context, text: "Copied SQL");
        }
      },
    );
  }
}
