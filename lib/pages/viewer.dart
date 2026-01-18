import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:squealer/core/entities/database_meta_entities.dart';
import 'package:squealer/core/init_setup.dart';
import 'package:squealer/core/routes.dart';
import 'package:squealer/cubit/data_browser_cubit.dart';
import 'package:squealer/cubit/query_result_cubit.dart';
import 'package:squealer/cubit/structure_listing_cubit.dart';
import 'package:squealer/cubit/viewer_cubit.dart';
import 'package:squealer/pages/viewer_widgets/data_browser.dart';
import 'package:squealer/pages/viewer_widgets/error_info_widget.dart';
import 'package:squealer/pages/viewer_widgets/export_dialog.dart';
import 'package:squealer/pages/viewer_widgets/query_result.dart';
import 'package:squealer/pages/viewer_widgets/structure_listing.dart';

class Viewer extends StatefulWidget {
  final DatabaseInfo databaseInfo;
  const Viewer({super.key, required this.databaseInfo});

  @override
  State<Viewer> createState() => _ViewerState();
}

class _ViewerState extends State<Viewer> with TickerProviderStateMixin {
  late final TabController _tabController;
  bool isTabControllerListenerRegistered = false;
  ViewerCubit? _viewerCubit;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _viewerCubit?.closeDatabase();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              ViewerCubit(viewerRepo: sl(), databaseInfo: widget.databaseInfo),
        ),
        BlocProvider(
          create: (context) => StructureListingCubit(viewerRepo: sl()),
        ),
        BlocProvider(
          create: (context) =>
              DataBrowserCubit(viewerRepo: sl(), exporterRepo: sl()),
        ),
        BlocProvider(
          create: (context) =>
              QueryResultCubit(viewerRepo: sl(), exporterRepo: sl()),
        ),
      ],
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            actions: [
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
                    if (_tabController.index == 1)
                      PopupMenuItem(
                        onTap: () {
                          context.push(SquealerRouter.settingsPage);
                        },
                        child: ListTile(
                          title: Text("Export relation"),
                          leading: Icon(Icons.ios_share),
                          onTap: () async {
                            final exportFormat = await showExportDialog(
                              context,
                            );
                            if (context.mounted && exportFormat != null) {
                              await context.read<DataBrowserCubit>().exportData(
                                exportFormat: exportFormat,
                              );
                            }
                          },
                        ),
                      ),
                  ];
                },
              ),
            ],
          ),
          body: BlocConsumer<ViewerCubit, ViewerState>(
            listener: (context, state) async {
              _viewerCubit = context.read<ViewerCubit>();
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
                      .loadTableAndViewNames();
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
                                DataBrowser(),
                                QueryResult(),
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
