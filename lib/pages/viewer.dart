import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:squealer/core/entities/database_meta_entities.dart';
import 'package:squealer/core/init_setup.dart';
import 'package:squealer/cubit/data_browser_cubit.dart';
import 'package:squealer/cubit/structure_listing_cubit.dart';
import 'package:squealer/cubit/viewer_cubit.dart';
import 'package:squealer/pages/viewer_widgets/data_browser.dart';
import 'package:squealer/pages/viewer_widgets/structure_listing.dart';

class Viewer extends StatefulWidget {
  final DatabaseInfo databaseInfo;
  const Viewer({super.key, required this.databaseInfo});

  @override
  State<Viewer> createState() => _ViewerState();
}

class _ViewerState extends State<Viewer> with TickerProviderStateMixin {
  late final TabController tabController;
  bool isTabControllerListenerRegistered = false;
  ViewerCubit? _viewerCubit;
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
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
        BlocProvider(create: (context) => DataBrowserCubit(viewerRepo: sl())),
      ],
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(),
          body: BlocConsumer<ViewerCubit, ViewerState>(
            listener: (context, state) async {
              _viewerCubit = context.read<ViewerCubit>();
              if (state case ViewerDatabaseLoaded(:final databaseObject)) {
                await context.read<StructureListingCubit>().databaseOpened(
                  databaseObject: databaseObject,
                );
                if (context.mounted) {
                  await context
                      .read<StructureListingCubit>()
                      .loadTableAndViewNames();
                }
                if (!isTabControllerListenerRegistered) {
                  isTabControllerListenerRegistered = true;
                  tabController.addListener(() async {
                    switch (tabController.index) {
                      case 0:
                        await context
                            .read<StructureListingCubit>()
                            .databaseOpened(databaseObject: databaseObject);
                        if (context.mounted) {
                          await context
                              .read<StructureListingCubit>()
                              .loadTableAndViewNames();
                        }
                      case 1:
                        await context.read<DataBrowserCubit>().databaseOpened(
                          databaseObject: databaseObject,
                        );
                        if (context.mounted) {
                          await context
                              .read<DataBrowserCubit>()
                              .loadTableAndViewNames();
                        }
                    }
                  });
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
                    case ViewerDatabaseLoaded():
                      return Column(
                        children: [
                          Expanded(
                            child: TabBarView(
                              controller: tabController,
                              children: [
                                StructureListing(),
                                DataBrowser(),
                                // ViewsListing(),
                                Placeholder(
                                  child: Center(child: Text("Query")),
                                ),
                              ],
                            ),
                          ),
                          TabBar(
                            controller: tabController,
                            tabs: [
                              Tab(text: "Structure"),
                              Tab(text: "Data"),
                              Tab(text: "Query"),
                            ],
                          ),
                        ],
                      );
                    case ViewerError(:final error):
                      return Center(child: ErrorWidget(error));
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
