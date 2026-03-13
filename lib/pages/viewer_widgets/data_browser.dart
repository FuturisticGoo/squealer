import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:squealer/cubit/data_browser_cubit.dart';
import 'package:squealer/cubit/global_settings_cubit.dart';
import 'package:squealer/pages/viewer_widgets/loading_widget.dart';
import 'package:trina_grid/trina_grid.dart';

class DataBrowser extends StatefulWidget {
  const DataBrowser({super.key, required this.getForceUpdateSeed});
  final int Function() getForceUpdateSeed;
  @override
  State<DataBrowser> createState() => _DataBrowserState();
}

class _DataBrowserState extends State<DataBrowser>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    context.read<DataBrowserCubit>().loadTableAndViewNames();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<GlobalSettingsCubit, GlobalSettingsState>(
      builder: (context, state) {
        switch (state) {
          case GlobalSettingsLoaded(:final settings):
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: BlocBuilder<DataBrowserCubit, DataBrowserState>(
                builder: (context, state) {
                  switch (state) {
                    case DataBrowserInitial():
                    case DataBrowserLoading():
                      return LoadingWidget();
                    case DataBrowserLoaded(:final tables, :final views):
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DropdownMenu(
                            enableFilter: true,
                            leadingIcon: const Icon(Icons.search),
                            menuHeight: MediaQuery.heightOf(context) * 0.7,
                            requestFocusOnTap: true,
                            expandedInsets: EdgeInsets.zero,
                            label: Text("Relation: "),
                            dropdownMenuEntries: [
                              ...tables.map((e) {
                                return DropdownMenuEntry(
                                  value: e,
                                  label: e,
                                  leadingIcon: Text("Table"),
                                );
                              }),
                              ...views.map(
                                (e) => DropdownMenuEntry(
                                  value: e,
                                  label: e,
                                  leadingIcon: Text("View"),
                                ),
                              ),
                            ],

                            onSelected: (value) async {
                              if (value != null) {
                                await context
                                    .read<DataBrowserCubit>()
                                    .showDataOfRelation(
                                      relationName: value,
                                      fromRowNumber: 1,
                                      fetchCount: settings.rowFetchCount,
                                    );
                              }
                            },
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
                                    final String? sortColumn =
                                        request.sortColumn?.field;
                                    final bool? isDescending =
                                        switch (request.sortColumn?.sort) {
                                          TrinaColumnSort.ascending => false,
                                          TrinaColumnSort.descending => true,
                                          TrinaColumnSort.none || null => null,
                                        };
                                    final lastRow =
                                        request.lastRow?.data as int?;
                                    await context
                                        .read<DataBrowserCubit>()
                                        .showDataOfRelation(
                                          relationName: selectedRelation,
                                          fromRowNumber: lastRow,
                                          orderBy: sortColumn,
                                          isDescendingOrder: isDescending,
                                          fetchCount: settings.rowFetchCount,
                                        );
                                    //TODO: is there a better way?? :(
                                    if (context.mounted) {
                                      final latestState = context
                                          .read<DataBrowserCubit>()
                                          .state;
                                      if (latestState
                                          case DataBrowserLoadedRelation(
                                            :final selectedRelationResult,
                                          )) {
                                        return TrinaInfinityScrollRowsResponse(
                                          isLast: isLast,
                                          rows: selectedRelationResult.rows.map(
                                            (row) {
                                              return TrinaRow(
                                                data: row.rowNumber,
                                                cells: Map.fromEntries(
                                                  List.generate(
                                                    row.rowData.length,
                                                    (index) {
                                                      return MapEntry(
                                                        selectedRelationResult
                                                            .columnNames[index],
                                                        TrinaCell(
                                                          value: row
                                                              .rowData[index],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                          ).toList(),
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
                                    Theme.brightnessOf(context) ==
                                        Brightness.dark
                                    ? const TrinaGridConfiguration.dark()
                                    : const TrinaGridConfiguration(),
                                key: Key(
                                  "$selectedRelation-${widget.getForceUpdateSeed()}",
                                ), // Required for TrinaGrid to
                                // update on change
                                // Added the force update seed to force it to 
                                // fetch new ones when refresh button is clicked
                                // but ong this is such a bad hack but I cant
                                // find a better way with trina grid
                                // :(
                                columns: selectedRelationResult.columnNames.map(
                                  (col) {
                                    return TrinaColumn(
                                      title: col,
                                      field: col,
                                      type: TrinaColumnType.text(),
                                    );
                                  },
                                ).toList(),

                                noRowsWidget: Center(
                                  child: Text("Empty relation"),
                                ),
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
          default:
            return Center(child: Text("Settings not loaded"));
        }
      },
    );
  }
}
