import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:squealer/core/entities/database_data_entities.dart';
import 'package:squealer/cubit/structure_listing_cubit.dart';
import 'package:squealer/pages/viewer_widgets/sql_tile.dart';
import 'package:squealer/pages/viewer_widgets/table_name_tile.dart';

class TriggerExpansionTile extends StatelessWidget {
  final List<String> triggers;
  final Map<String, DatabaseTrigger> triggersExpanded;
  final StructureListingState state;
  const TriggerExpansionTile({
    super.key,
    required this.triggers,
    required this.triggersExpanded,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        "Triggers (${triggers.length})",
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      shape: const Border(),
      childrenPadding: EdgeInsets.only(left: 20),
      children: [
        if (state is StructureListingLoading &&
            (state as StructureListingLoading).structureLoadingPart
                is LoadingRelationNames)
          Center(child: CircularProgressIndicator())
        else if (triggers.isEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("No triggers"),
          )
        else
          ListView.builder(
            primary: false,
            shrinkWrap: true,
            itemCount: triggers.length,
            itemBuilder: (context, index) {
              final currentTriggerName = triggers[index];
              return ExpansionTile(
                title: Text(currentTriggerName),
                childrenPadding: EdgeInsets.only(left: 20),
                shape: const Border(),
                onExpansionChanged: (isExpanding) async {
                  if (isExpanding) {
                    await context
                        .read<StructureListingCubit>()
                        .getTriggerDetails(triggerName: currentTriggerName);
                  } else {
                    await context
                        .read<StructureListingCubit>()
                        .hideTriggerDetails(triggerName: currentTriggerName);
                  }
                },
                children: switch (state) {
                  StructureListingLoading(
                    structureLoadingPart: LoadingTriggerDetails(
                      :final triggerName,
                    ),
                  )
                      when triggerName == currentTriggerName =>
                    [Center(child: CircularProgressIndicator())],
                  _ => switch (triggersExpanded[currentTriggerName]) {
                    null => [],
                    DatabaseTrigger(:final sql, :final onTable) => [
                      SQLTile(sql: sql),
                      Divider(),
                      TableNameTile(tableName: onTable),
                    ],
                  },
                },
              );
            },
          ),
      ],
    );
  }
}
