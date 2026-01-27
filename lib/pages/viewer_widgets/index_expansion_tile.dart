import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:squealer/core/entities/database_data_entities.dart';
import 'package:squealer/cubit/structure_listing_cubit.dart';
import 'package:squealer/pages/viewer_widgets/index_columns_tile.dart';
import 'package:squealer/pages/viewer_widgets/sql_tile.dart';
import 'package:squealer/pages/viewer_widgets/table_name_tile.dart';

class IndexExpansionTile extends StatelessWidget {
  final List<String> indices;
  final Map<String, DatabaseIndex> indicesExpanded;
  final StructureListingState state;
  const IndexExpansionTile({
    super.key,
    required this.indices,
    required this.indicesExpanded,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        "Indices (${indices.length})",
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
        else if (indices.isEmpty)
          Padding(padding: const EdgeInsets.all(8.0), child: Text("No indices"))
        else
          ListView.builder(
            primary: false,
            shrinkWrap: true,
            itemCount: indices.length,
            itemBuilder: (context, index) {
              final currentIndexName = indices[index];
              return ExpansionTile(
                title: Text(currentIndexName),
                childrenPadding: EdgeInsets.only(left: 20),
                shape: const Border(),
                onExpansionChanged: (isExpanding) async {
                  if (isExpanding) {
                    await context.read<StructureListingCubit>().getIndexDetails(
                      indexName: currentIndexName,
                    );
                  } else {
                    await context
                        .read<StructureListingCubit>()
                        .hideIndexDetails(indexName: currentIndexName);
                  }
                },
                children: switch (state) {
                  StructureListingLoading(
                    structureLoadingPart: LoadingIndexDetails(:final indexName),
                  )
                      when indexName == currentIndexName =>
                    [Center(child: CircularProgressIndicator())],
                  _ => switch (indicesExpanded[currentIndexName]) {
                    null => [],
                    DatabaseIndex(
                      :final sql,
                      :final onTable,
                      :final onColumns,
                    ) =>
                      [
                        SQLTile(sql: sql ?? "Autoindex"),
                        Divider(),
                        TableNameTile(tableName: onTable),
                        IndexColumnsTile(columns: onColumns),
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
