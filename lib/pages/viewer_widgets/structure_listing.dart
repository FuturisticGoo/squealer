import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:squealer/core/entities/database_data_entities.dart';
import 'package:squealer/cubit/structure_listing_cubit.dart';
import 'package:squealer/pages/viewer_widgets/index_expansion_tile.dart';
import 'package:squealer/pages/viewer_widgets/sql_tile.dart';
import 'package:squealer/pages/viewer_widgets/table_column_info_tile.dart';
import 'package:squealer/pages/viewer_widgets/trigger_expansion_tile.dart';

class StructureListing extends StatefulWidget {
  const StructureListing({super.key});

  @override
  State<StructureListing> createState() => _StructureListingState();
}

class _StructureListingState extends State<StructureListing>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<StructureListingCubit, StructureListingState>(
      builder: (context, state) {
        switch (state) {
          case StructureListingInitial():
          case StructureListingLoading(structureLoadingPart: null):
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text("Loading structure"),
                ],
              ),
            );
          case StructureListingLoading(
            structureLoadingPart: StructureLoadingPart(
              previousState: StructureListingLoaded(
                :final tables,
                :final tablesExpanded,
                :final views,
                :final viewsExpanded,
                :final indices,
                :final indicesExpanded,
                :final triggers,
                :final triggersExpanded,
              ),
            ),
          ):
          case StructureListingLoaded(
            :final tables,
            :final tablesExpanded,
            :final views,
            :final viewsExpanded,
            :final indices,
            :final indicesExpanded,
            :final triggers,
            :final triggersExpanded,
          ):
            return SingleChildScrollView(
              primary: true,
              child: Column(
                children: [
                  TablesExpansionTile(
                    tables: tables,
                    tablesExpanded: tablesExpanded,
                    state: state,
                  ),
                  Divider(),
                  ViewExpansionTile(
                    views: views,
                    viewsExpanded: viewsExpanded,
                    state: state,
                  ),
                  Divider(),
                  IndexExpansionTile(
                    indices: indices,
                    indicesExpanded: indicesExpanded,
                    state: state,
                  ),
                  Divider(),
                  TriggerExpansionTile(
                    triggers: triggers,
                    triggersExpanded: triggersExpanded,
                    state: state,
                  ),
                ],
              ),
            );

          case StructureListingError(:final error):
            return Center(child: ErrorWidget(error));
        }
      },
    );
  }
}

class TablesExpansionTile extends StatelessWidget {
  final List<String> tables;
  final Map<String, DatabaseTable> tablesExpanded;
  final StructureListingState state;
  const TablesExpansionTile({
    super.key,
    required this.tables,
    required this.tablesExpanded,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        "Tables (${tables.length})",
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
        else if (tables.isEmpty)
          Padding(padding: const EdgeInsets.all(8.0), child: Text("No tables"))
        else
          ListView.builder(
            primary: false,
            shrinkWrap: true,
            itemCount: tables.length,
            itemBuilder: (context, index) {
              final currentTableName = tables[index];
              return ExpansionTile(
                title: Text(currentTableName),
                childrenPadding: EdgeInsets.fromLTRB(20, 10, 0, 10),
                shape: const Border(),
                onExpansionChanged: (isExpanding) async {
                  if (isExpanding) {
                    await context.read<StructureListingCubit>().getTableDetails(
                      tableName: currentTableName,
                    );
                  } else {
                    await context
                        .read<StructureListingCubit>()
                        .hideTableDetails(tableName: currentTableName);
                  }
                },
                children: switch (state) {
                  StructureListingLoading(
                    structureLoadingPart: LoadingTableDetails(:final tableName),
                  )
                      when currentTableName == tableName =>
                    [Center(child: CircularProgressIndicator())],
                  _ => switch (tablesExpanded[currentTableName]) {
                    null => [],
                    DatabaseTable(:final columns, :final sql) => [
                      SQLTile(sql: sql),
                      Divider(),
                      ...columns.map((col) {
                        return TableColumnInfoTile(column: col);
                      }),
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

class ViewExpansionTile extends StatelessWidget {
  final List<String> views;
  final Map<String, DatabaseView> viewsExpanded;
  final StructureListingState state;
  const ViewExpansionTile({
    super.key,
    required this.views,
    required this.viewsExpanded,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        "Views (${views.length})",
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
        else if (views.isEmpty)
          Padding(padding: const EdgeInsets.all(8.0), child: Text("No views"))
        else
          ListView.builder(
            primary: false,
            shrinkWrap: true,
            itemCount: views.length,
            itemBuilder: (context, index) {
              final currentViewName = views[index];
              return ExpansionTile(
                title: Text(currentViewName),
                childrenPadding: EdgeInsets.only(left: 20),
                shape: const Border(),
                onExpansionChanged: (isExpanding) async {
                  if (isExpanding) {
                    await context.read<StructureListingCubit>().getViewDetails(
                      viewName: currentViewName,
                    );
                  } else {
                    await context.read<StructureListingCubit>().hideViewDetails(
                      viewName: currentViewName,
                    );
                  }
                },
                children: switch (state) {
                  StructureListingLoading(
                    structureLoadingPart: LoadingViewDetails(:final viewName),
                  )
                      when viewName == currentViewName =>
                    [Center(child: CircularProgressIndicator())],
                  _ => switch (viewsExpanded[currentViewName]) {
                    null => [],
                    DatabaseView(:final sql, :final columns) => [
                      SQLTile(sql: sql),
                      Divider(),
                      ...columns.map((col) {
                        return TableColumnInfoTile(column: col);
                      }),
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
