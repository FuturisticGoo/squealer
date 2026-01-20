import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:squealer/core/entities/database_data_entities.dart';
import 'package:squealer/cubit/structure_listing_cubit.dart';
import 'package:futuristicgoo_utils/futuristicgoo_utils.dart';

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
              ),
            ),
          ):
          case StructureListingLoaded(
            :final tables,
            :final tablesExpanded,
            :final views,
            :final viewsExpanded,
          ):
            return SingleChildScrollView(
              primary: true,
              child: Column(
                children: [
                  ExpansionTile(
                    title: Text(
                      "Tables",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    shape: const Border(),
                    childrenPadding: EdgeInsets.only(left: 20),
                    children: [
                      if (state is StructureListingLoading &&
                          state.structureLoadingPart is LoadingRelationNames)
                        Center(child: CircularProgressIndicator())
                      else if (tables.isEmpty)
                        Text("No tables")
                      else
                        ListView.builder(
                          primary: false,
                          shrinkWrap: true,
                          itemCount: tables.length,
                          itemBuilder: (context, index) {
                            final currentTableName = tables[index];
                            return ExpansionTile(
                              title: Text(currentTableName),
                              childrenPadding: EdgeInsets.fromLTRB(
                                20,
                                10,
                                0,
                                10,
                              ),
                              shape: const Border(),
                              onExpansionChanged: (isExpanding) async {
                                if (isExpanding) {
                                  await context
                                      .read<StructureListingCubit>()
                                      .getTableDetails(
                                        tableName: currentTableName,
                                      );
                                } else {
                                  await context
                                      .read<StructureListingCubit>()
                                      .hideTableDetails(
                                        tableName: currentTableName,
                                      );
                                }
                              },
                              children: switch (state) {
                                StructureListingLoading(
                                  structureLoadingPart: LoadingTableDetails(
                                    :final tableName,
                                  ),
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
                  ),
                  Divider(),
                  ExpansionTile(
                    title: Text(
                      "Views",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    shape: const Border(),
                    childrenPadding: EdgeInsets.only(left: 20),
                    children: [
                      if (state is StructureListingLoading &&
                          state.structureLoadingPart is LoadingRelationNames)
                        Center(child: CircularProgressIndicator())
                      else if (views.isEmpty)
                        Text("No views")
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
                                  await context
                                      .read<StructureListingCubit>()
                                      .getViewDetails(
                                        viewName: currentViewName,
                                      );
                                } else {
                                  await context
                                      .read<StructureListingCubit>()
                                      .hideViewDetails(
                                        viewName: currentViewName,
                                      );
                                }
                              },
                              children: switch (state) {
                                StructureListingLoading(
                                  structureLoadingPart: LoadingViewDetails(
                                    :final viewName,
                                  ),
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
