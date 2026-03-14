import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:squealer/core/entities/database_meta_entities.dart';
import 'package:squealer/core/entities/export_progress_type.dart';
import 'package:squealer/core/init_setup.dart';
import 'package:squealer/core/routes.dart';
import 'package:squealer/cubit/data_browser_cubit.dart';
import 'package:squealer/cubit/query_result_cubit.dart';
import 'package:squealer/cubit/structure_listing_cubit.dart';
import 'package:squealer/cubit/viewer_cubit.dart';
import 'package:squealer/pages/viewer_widgets/data_browser.dart';
import 'package:squealer/pages/viewer_widgets/error_info_widget.dart';
import 'package:squealer/pages/viewer_widgets/export_dialog.dart';
import 'package:squealer/pages/viewer_widgets/new_statement_dialog.dart';
import 'package:squealer/pages/viewer_widgets/progress_dialog.dart';
import 'package:squealer/pages/viewer_widgets/query_result.dart';
import 'package:squealer/pages/viewer_widgets/structure_listing.dart';
import 'package:futuristicgoo_utils/futuristicgoo_utils.dart';

enum _ViewerTabs {
  structure(0),
  data(1),
  query(2);

  const _ViewerTabs(this.tabIndex);
  final int tabIndex;
}

class Viewer extends StatefulWidget {
  final DatabaseInfo databaseInfo;
  const Viewer({super.key, required this.databaseInfo});

  @override
  State<Viewer> createState() => _ViewerState();
}

class _ViewerState extends State<Viewer>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final TabController _tabController;
  final _sqlQueryTextEditingController = TextEditingController();
  _ViewerTabs currentTab = _ViewerTabs.structure;
  ViewerCubit? _viewerCubit;
  int forceUpdateDataBrowserSeed = DateTime.now().millisecondsSinceEpoch;
  @override
  Future<AppExitResponse> didRequestAppExit() async {
    await _viewerCubit?.closeDatabase();
    return super.didRequestAppExit();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _ViewerTabs.values.length,
      vsync: this,
    );
    _tabController.addListener(() {
      setState(() {
        currentTab = _ViewerTabs.values.singleWhere(
          (element) => element.tabIndex == _tabController.index,
        );
      });
    });
  }

  @override
  void dispose() {
    _viewerCubit?.closeDatabase();
    _sqlQueryTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            _viewerCubit = ViewerCubit(
              viewerRepo: sl(),
              databaseInfo: widget.databaseInfo,
            );
            return _viewerCubit!;
          },
        ),
        BlocProvider(
          create: (context) => StructureListingCubit(viewerRepo: sl()),
        ),
        BlocProvider(
          create: (context) =>
              DataBrowserCubit(viewerRepo: sl(), exporterRepo: sl()),
        ),
        BlocProvider(
          create: (context) => QueryResultCubit(
            viewerRepo: sl(),
            exporterRepo: sl(),
            appDataRepo: sl(),
          ),
        ),
      ],
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            actions: [
              if (currentTab == _ViewerTabs.data)
                Builder(
                  builder: (context) {
                    return IconButton(
                      onPressed: () async {
                        forceUpdateDataBrowserSeed =
                            DateTime.now().millisecondsSinceEpoch;
                        // We could just setState and set the above, which will
                        // force a refresh. But if a column is dropped from
                        // a table, it will still be requested, which will
                        // result in a null error. So force a refresh here too.
                        await context.read<DataBrowserCubit>().refresh();
                      },
                      icon: Icon(Icons.refresh),
                    );
                  },
                ),
              PopupMenuButton(
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      onTap: () {
                        context.push(SquealerRouter.settingsPage);
                      },
                      child: ListTile(
                        title: Text("Settings"),
                        leading: Icon(Icons.settings),
                      ),
                    ),
                    if (currentTab == _ViewerTabs.data)
                      PopupMenuItem(
                        enabled:
                            context.read<DataBrowserCubit>().state
                                is DataBrowserLoadedRelation,
                        onTap: () async {
                          final exportFormat = await showExportDialog(context);
                          if (context.mounted && exportFormat != null) {
                            showProgressDialog<
                              ExportingRowsUpdate,
                              ExportingRowsFinished,
                              ExportingRowsError
                            >(context, titleText: "Exporting", subtitle: "");
                            await context.read<DataBrowserCubit>().exportData(
                              exportFormat: exportFormat,
                            );
                          }
                        },
                        child: ListTile(
                          title: Text("Export relation"),
                          leading: Icon(Icons.ios_share),
                        ),
                      ),
                    if (currentTab == _ViewerTabs.query)
                      PopupMenuItem(
                        enabled:
                            context.read<QueryResultCubit>().state
                                is QueryResultExecuteResult,
                        onTap: () async {
                          final exportFormat = await showExportDialog(
                            context,
                            allowedExportTypes: [
                              ExportType.csv,
                              ExportType.json,
                            ],
                          );
                          if (context.mounted && exportFormat != null) {
                            showProgressDialog<
                              ExportingRowsUpdate,
                              ExportingRowsFinished,
                              ExportingRowsError
                            >(context, titleText: "Exporting", subtitle: "");
                            await context.read<QueryResultCubit>().exportData(
                              exportFormat: exportFormat,
                            );
                          }
                        },
                        child: ListTile(
                          title: Text("Export data"),
                          leading: Icon(Icons.ios_share),
                        ),
                      ),
                    if (currentTab == _ViewerTabs.query)
                      PopupMenuItem(
                        enabled:
                            context.read<QueryResultCubit>().state
                                is QueryResultExecuteResult,
                        onTap: () async {
                          await context.read<QueryResultCubit>().exportSql();
                        },
                        child: ListTile(
                          title: Text("Export SQL"),
                          leading: Icon(Icons.ios_share),
                        ),
                      ),
                    if (currentTab == _ViewerTabs.query)
                      PopupMenuItem(
                        enabled:
                            context.read<QueryResultCubit>().state
                                is QueryResultDatabaseLoaded,
                        onTap: () async {
                          final dialogResult = await showNewStatementDialog(
                            context,
                            initialStatement:
                                _sqlQueryTextEditingController.text,
                          );
                          if (context.mounted && dialogResult != null) {

                          await context
                              .read<QueryResultCubit>()
                              .saveSQLStatement(
                                  name: dialogResult.$1,
                                  statement: dialogResult.$2,
                              );
                          if (context.mounted) {
                            showSnackBar(context, text: "Saved statement");
                          }
                          }
                        },
                        child: ListTile(
                          title: Text("Save statement"),
                          leading: Icon(Icons.save),
                        ),
                      ),
                  ];
                },
              ),
            ],
          ),
          body: BlocConsumer<ViewerCubit, ViewerState>(
            listener: (context, state) async {
              if (state case ViewerDatabaseLoaded(:final databaseObject)) {
                await context.read<StructureListingCubit>().databaseOpened(
                  databaseObject: databaseObject,
                );
                if (context.mounted) {
                  await context.read<DataBrowserCubit>().databaseOpened(
                    databaseObject: databaseObject,
                  );
                }
                if (context.mounted) {
                  await context.read<QueryResultCubit>().databaseOpened(
                    databaseObject: databaseObject,
                  );
                }
                if (context.mounted) {
                  await context
                      .read<StructureListingCubit>()
                      .loadAllSchemaNames();
                }
              }
            },
            builder: (context, state) {
              return BlocBuilder<ViewerCubit, ViewerState>(
                builder: (context, state) {
                  switch (state) {
                    case ViewerInitial():
                    case ViewerLoading():
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 10),
                            Text("Connecting to database"),
                          ],
                        ),
                      );
                    case ViewerError(:final failure):
                      return ErrorInfoWidget(
                        errorText: "Error while opening database file",
                        failure: failure,
                      );
                    case ViewerDatabaseLoaded():
                      return Column(
                        children: [
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                StructureListing(),
                                DataBrowser(
                                  getForceUpdateSeed: () =>
                                      forceUpdateDataBrowserSeed,
                                ),
                                QueryResult(
                                  queryTextEditingController:
                                      _sqlQueryTextEditingController,
                                ),
                              ],
                            ),
                          ),
                          TabBar(
                            controller: _tabController,
                            tabs: [
                              Tab(text: "Structure"),
                              Tab(text: "Data"),
                              Tab(text: "Query"),
                            ],
                          ),
                        ],
                      );
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
