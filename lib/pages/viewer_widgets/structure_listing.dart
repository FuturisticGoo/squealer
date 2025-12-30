import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:squealer/core/entities/database_data_entities.dart';
import 'package:squealer/cubit/structure_listing_cubit.dart';

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
          case StructureListingLoading():
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
                      if (tables.isEmpty)
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
                              childrenPadding: EdgeInsets.only(left: 20),
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
                              children:
                                  switch (tablesExpanded[currentTableName]) {
                                    null => [],
                                    DatabaseTable(:final columns, :final sql) =>
                                      [
                                        SQLTile(sql: sql),
                                        Divider(),
                                        ...columns.map((col) {
                                          return ExpansionTile(
                                            title: Text(col.columnName),
                                            childrenPadding: EdgeInsets.only(
                                              left: 20,
                                            ),
                                            shape: const Border(),
                                            children: [
                                              ListTile(
                                                title: Text(col.dataType),
                                              ),
                                            if (col.notNullable)
                                                ListTile(
                                                  title: Text("NOT NULL"),
                                                ),
                                            if (col.unique)
                                                ListTile(title: Text("UNIQUE")),
                                            if (col.isPrimaryKey)
                                                ListTile(
                                                  title: Text("PRIMARY KEY"),
                                                ),
                                            if (col.defaultValue != null)
                                              ListTile(
                                                title: Text(
                                                  "DEFAULT ${col.defaultValue}",
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                      ],
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
                      if (views.isEmpty)
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
                              children:
                                  switch (viewsExpanded[currentViewName]) {
                                    null => [],
                                    DatabaseView(:final sql) => [
                                      SQLTile(sql: sql),
                                    ],
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
      },
    );
  }
}
