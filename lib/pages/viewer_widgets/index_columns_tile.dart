import 'package:flutter/material.dart';

class IndexColumnsTile extends StatelessWidget {
  const IndexColumnsTile({super.key, required this.columns});

  final List<String> columns;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        "Column(s)",
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(columns.reduce((value, element) => "$value, $element")),
    );
  }
}
