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
              :final selectedTableResult,
              :final selectedTable,
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
                            label: Text("Table: "),
                          ),
                          items: [...tables, ...views].map((e) {
                            return DropdownMenuItem(value: e, child: Text(e));
                          }).toList(),
                          onChanged: (value) async {
                            if (value != null) {
                              await context
                                  .read<DataBrowserCubit>()
                                  .showDataOfTableOrView(tableName: value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  if (selectedTableResult != null &&
                      selectedTableResult.columnNames.isNotEmpty)
                    Expanded(
                      child: TrinaGrid(
                        key: Key(selectedTable ?? "Empty"),
                        columns: selectedTableResult.columnNames.map((col) {
                          return TrinaColumn(
                            title: col,
                            field: col,
                            type: TrinaColumnType.text(),
                          );
                        }).toList(),
                        noRowsWidget: Center(child: Text("Empty table")),
                        rows: selectedTableResult.rows.map((row) {
                          return TrinaRow(
                            cells: Map.fromEntries(
                              List.generate(row.rowData.length, (index) {
                                return MapEntry(
                                  selectedTableResult.columnNames[index],
                                  TrinaCell(value: row.rowData[index]),
                                );
                              }),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  if (selectedTableResult == null)
                    Center(child: Text("No table selected")),
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
