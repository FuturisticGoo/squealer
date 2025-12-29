import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:squealer/core/routes.dart';
import 'package:squealer/cubit/data_browser_cubit.dart';
import 'package:trina_grid/trina_grid.dart';

class DataBrowser extends StatefulWidget {
  const DataBrowser({super.key});

  @override
  State<DataBrowser> createState() => _DataBrowserState();
}

class _DataBrowserState extends State<DataBrowser> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: BlocBuilder<DataBrowserCubit, DataBrowserState>(
        builder: (context, state) {
          switch (state) {
            case DataBrowserInitial():
            case DataBrowserLoading():
              return Center(
                child: Column(
                  children: [CircularProgressIndicator(), Text("Loading data")],
                ),
              );
            case DataBrowserLoaded(
              :final tables,
              :final views,
            ):
              return Column(
                key: PageStorageKey(
                  "${SquealerRouter.viewerPage}/data_browser",
                ),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            label: Text("Relation: "),
                          ),
                          items: [...tables, ...views].map((e) {
                            return DropdownMenuItem(value: e, child: Text(e));
                          }).toList(),
                          onChanged: (value) async {
                            if (value != null) {
                              await context
                                  .read<DataBrowserCubit>()
                                  .showDataOfRelation(
                                    relationName: value,
                                    fromRowNumber: 1,
                                  );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  if (state case DataBrowserLoadedRelation(
                    :final selectedRelationResult,
                    :final selectedRelation,
                    :final isLast,
                  ))
                    Expanded(
                      child: TrinaGrid(
                        createFooter: (s) => TrinaInfinityScrollRows(
                          initialFetch: true,
                          fetchWithSorting: true,
                          fetchWithFiltering: true,
                          fetch: (request) async {
                            await context
                                .read<DataBrowserCubit>()
                                .showDataOfRelation(
                                  relationName: selectedRelation,
                                  fromRowNumber:
                                      (request.lastRow?.data as int? ?? 0) + 1,
                                );
                            //TODO: is there a better way?? :(
                            if (context.mounted) {
                              final latestState = context
                                  .read<DataBrowserCubit>()
                                  .state;
                              if (latestState case DataBrowserLoadedRelation(
                                :final selectedRelationResult,
                              )) {
                                return TrinaInfinityScrollRowsResponse(
                                  isLast: isLast,
                                  rows: selectedRelationResult.rows.map((row) {
                                    return TrinaRow(
                                      data: row.rowNumber,
                                      cells: Map.fromEntries(
                                        List.generate(row.rowData.length, (
                                          index,
                                        ) {
                                          return MapEntry(
                                            selectedRelationResult
                                                .columnNames[index],
                                            TrinaCell(
                                              value: row.rowData[index],
                                            ),
                                          );
                                        }),
                                      ),
                                    );
                                  }).toList(),
                                );
                              }
                            }
                            return TrinaInfinityScrollRowsResponse(
                              isLast: true,
                              rows: [],
                            );
                          },
                          stateManager: s,
                        ),
                        rows: [],
                        configuration:
                            Theme.brightnessOf(context) == Brightness.dark
                            ? const TrinaGridConfiguration.dark()
                            : const TrinaGridConfiguration(),
                        key: Key(selectedRelation),
                        columns: selectedRelationResult.columnNames.map((col) {
                          return TrinaColumn(
                            title: col,
                            field: col,
                            type: TrinaColumnType.text(),
                          );
                        }).toList(),
                        noRowsWidget: Center(child: Text("Empty relation")),
                        // rows: [],
                      ),
                    ),
                  if (state is! DataBrowserLoadedRelation)
                    Center(child: Text("No relation selected")),
                ],
              );
            case DataBrowserError(:final error):
              return Center(child: ErrorWidget(error));
          }
        },
      ),
    );
  }
}
