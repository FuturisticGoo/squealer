import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:squealer/cubit/query_result_cubit.dart';
import 'package:squealer/pages/viewer_widgets/error_info_widget.dart';
import 'package:squealer/pages/viewer_widgets/loading_widget.dart';
import 'package:trina_grid/trina_grid.dart';

class QueryResult extends StatefulWidget {
  final TextEditingController queryTextEditingController;
  const QueryResult({super.key, required this.queryTextEditingController});

  @override
  State<QueryResult> createState() => _QueryResultState();
}

class _QueryResultState extends State<QueryResult>
    with AutomaticKeepAliveClientMixin {
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
            case QueryResultDatabaseLoaded(:final savedStatements):
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownMenu(
                    controller: widget.queryTextEditingController,
                    maxLines: null,
                    enableFilter: true,
                    menuHeight: MediaQuery.heightOf(context) * 0.7,
                    requestFocusOnTap: true,
                    expandedInsets: EdgeInsets.zero,
                    decorationBuilder: (context, controller) => InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Query"),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          onPressed: () async {
                            if (widget.queryTextEditingController.text
                                .trim()
                                .isNotEmpty) {
                              await context
                                  .read<QueryResultCubit>()
                                  .executeQuery(
                                    sqlQuery:
                                        widget.queryTextEditingController.text,
                                  );
                            }
                          },
                          icon: Icon(Icons.send),
                        ),
                      ),
                    ),
                    dropdownMenuEntries: savedStatements.map((statement) {
                      return DropdownMenuEntry(
                        value: statement,
                        label: "${statement.name}: ${statement.statement}",
                        labelWidget: Text(statement.statement),
                        leadingIcon: Text(statement.name),
                        trailingIcon: IconButton(
                          onPressed: () async {
                            await context
                                .read<QueryResultCubit>()
                                .removeSQLStatement(statement: statement);
                          },
                          icon: Icon(Icons.close),
                        ),
                      );
                    }).toList(),

                    onSelected: (value) async {
                      if (value != null) {
                        widget.queryTextEditingController.text =
                            value.statement;
                      }
                    },
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
