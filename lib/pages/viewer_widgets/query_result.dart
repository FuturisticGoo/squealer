import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:squealer/cubit/query_result_cubit.dart';
import 'package:squealer/pages/viewer_widgets/error_info_widget.dart';
import 'package:squealer/pages/viewer_widgets/loading_widget.dart';
import 'package:trina_grid/trina_grid.dart';

class QueryResult extends StatefulWidget {
  const QueryResult({super.key});

  @override
  State<QueryResult> createState() => _QueryResultState();
}

class _QueryResultState extends State<QueryResult>
    with AutomaticKeepAliveClientMixin {
  final _queryTextEditingController = TextEditingController();

  @override
  void dispose() {
    _queryTextEditingController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: EdgeInsetsGeometry.all(8.0),
      child: BlocBuilder<QueryResultCubit, QueryResultState>(
        builder: (context, state) {
          switch (state) {
            case QueryResultInitial():
            case QueryResultLoading():
              return LoadingWidget();
            case QueryResultError():
              return Center(child: Text("Unknown error"));
            case QueryResultDatabaseLoaded():
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _queryTextEditingController,
                    minLines: 1,
                    maxLines: 5,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Query"),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          onPressed: () async {
                            await context.read<QueryResultCubit>().executeQuery(
                              sqlQuery: _queryTextEditingController.text,
                            );
                          },
                          icon: Icon(Icons.send),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  switch (state) {
                    QueryResultExecuting() => LoadingWidget(
                      loadingText: "Executing query...",
                    ),
                    QueryResultExecuteError(:final failure) => Expanded(
                      child: SingleChildScrollView(
                        child: ErrorInfoWidget(
                          errorText: "Error while executing query",
                          failure: failure,
                        ),
                      ),
                    ),

                    QueryResultExecuteResult(:final queryResult) => Expanded(
                      child: TrinaGrid(
                        key: Key(queryResult.originalQuery),
                        configuration:
                            Theme.brightnessOf(context) == Brightness.dark
                            ? const TrinaGridConfiguration.dark()
                            : const TrinaGridConfiguration(),
                        columns: queryResult.columnNames.map((col) {
                          return TrinaColumn(
                            title: col,
                            field: col,
                            type: TrinaColumnType.text(),
                          );
                        }).toList(),
                        rows: queryResult.rows.map((row) {
                          return TrinaRow(
                            data: row.rowNumber,
                            cells: Map.fromEntries(
                              List.generate(row.rowData.length, (index) {
                                return MapEntry(
                                  queryResult.columnNames[index],
                                  TrinaCell(value: row.rowData[index]),
                                );
                              }),
                            ),
                          );
                        }).toList(),
                        noRowsWidget: Center(child: Text("Empty result")),
                      ),
                    ),

                    _ => Container(), // Will never reach here
                  },
                ],
              );
          }
        },
      ),
    );
  }
}
