import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futuristicgoo_utils/futuristicgoo_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:io_file_picker_ui/io_file_picker_ui.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:squealer/core/constants.dart';
import 'package:squealer/core/entities/database_meta_entities.dart';
import 'package:squealer/core/init_setup.dart';
import 'package:squealer/core/routes.dart';
import 'package:squealer/cubit/global_settings_cubit.dart';
import 'package:squealer/cubit/home_cubit.dart';
import 'package:squealer/pages/viewer_widgets/error_info_widget.dart';
import 'package:squealer/pages/viewer_widgets/loading_widget.dart';

class HomePage extends StatefulWidget {
  final Uri? databaseContentUri;
  const HomePage({super.key, this.databaseContentUri});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String filePath = "";
  final controller = TextEditingController();
  bool shouldUseCustomFilePicker = false;

  Future<void> useTable({
    required BuildContext buildContext,
    required DatabaseInfo databaseInfo,
  }) async {
    if (buildContext.mounted) {
      await buildContext.read<HomeCubit>().saveDatabaseToRecent(
        databaseInfo: databaseInfo,
      );
    }
    if (buildContext.mounted) {
      buildContext.push(SquealerRouter.viewerPage, extra: databaseInfo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final homeCubit = HomeCubit(
          filePickerRepository: sl(),
          appDataRepo: sl(),
        );
        if (widget.databaseContentUri != null) {
          Loggify.getLogger?.config(
            "Handling ${widget.databaseContentUri} in while creating HomeCubit",
          );
          homeCubit.getDatabaseFromContentUri(
            contentUri: widget.databaseContentUri!,
          );
        }
        return homeCubit;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text("Squealer"),
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
                  ];
                },
              ),
            ],
          ),
          body: BlocBuilder<GlobalSettingsCubit, GlobalSettingsState>(
            builder: (context, state) {
              switch (state) {
                case GlobalSettingsInitial():
                case GlobalSettingsLoading():
                case GlobalSettingsFirstTime():
                  return LoadingWidget(loadingText: "Loading settings...");
                case GlobalSettingsError(:final failure):
                  return ErrorInfoWidget(
                    errorText: "Error while loading settings",
                    failure: failure,
                  );
                case GlobalSettingsLoaded():
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: BlocConsumer<HomeCubit, HomeState>(
                      listener: (context, state) async {
                        if (state case HomeDatabaseFilePicked(
                          :final databaseInfo,
                        )) {
                          await useTable(
                            buildContext: context,
                            databaseInfo: databaseInfo,
                          );
                        }
                      },
                      builder: (context, state) {
                        switch (state) {
                          case HomeInitial():
                          case HomeLoading():
                            return Center(child: CircularProgressIndicator());
                          case HomeDatabaseFilePicked(:final recentDatabases):
                          case HomeLoaded(:final recentDatabases):
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Spacer(flex: 4),
                                  if (Platform.isAndroid) ...[
                                    SwitchListTile(
                                      title: Text(
                                        "Use direct file access (Android)",
                                      ),
                                      value: shouldUseCustomFilePicker,
                                      onChanged: (value) async {
                                        final storagePermision =
                                            await Permission
                                                .manageExternalStorage
                                                .request();
                                        if (storagePermision.isGranted) {
                                          setState(() {
                                            shouldUseCustomFilePicker = value;
                                          });
                                        }
                                      },
                                    ),
                                    SizedBox(height: 20),
                                  ],
                                  FilledButton.icon(
                                    onPressed: () async {
                                      if (shouldUseCustomFilePicker) {
                                        final databaseFileResult =
                                            await showIoFilePicker(
                                              context,
                                              pickerConfig:
                                                  SingleFilePickerConfig(
                                                    allowedExtensions:
                                                        allowedExtension
                                                            .map((e) => ".$e")
                                                            .toList(),
                                                  ),
                                            );
                                        if (databaseFileResult
                                            case SingleFilePickerResult(
                                              :final filePath,
                                            ) when context.mounted) {
                                          await context
                                              .read<HomeCubit>()
                                              .getDatabaseFromFilePath(
                                                path: filePath,
                                              );
                                        }
                                      } else {
                                        await context
                                            .read<HomeCubit>()
                                            .pickDatabaseFile();
                                      }
                                    },
                                    label: Text("Pick SQLite file"),
                                    icon: Icon(Icons.file_open),
                                  ),
                                  Spacer(flex: 1),
                                  Visibility.maintain(
                                    visible: recentDatabases.isNotEmpty,
                                    child: SizedBox(
                                      height:
                                          MediaQuery.sizeOf(context).height *
                                          0.3,
                                      child: Badge(
                                        backgroundColor: Theme.of(
                                          context,
                                        ).buttonTheme.colorScheme?.secondary,
                                        textColor: Theme.of(
                                          context,
                                        ).buttonTheme.colorScheme?.onSecondary,
                                        alignment: Alignment.topLeft,
                                        label: Text("Recent databases"),
                                        child: Card.outlined(
                                          clipBehavior: Clip.hardEdge,
                                          margin: EdgeInsets.all(8),
                                          child: ListView.builder(
                                            // shrinkWrap: true,
                                            itemCount: recentDatabases.length,
                                            itemBuilder: (context, index) {
                                              final dbInfo =
                                                  recentDatabases[index];
                                              return ListTile(
                                                onTap: () async {
                                                  await useTable(
                                                    buildContext: context,
                                                    databaseInfo: dbInfo,
                                                  );
                                                },
                                                title: Text(
                                                  dbInfo
                                                      .databaseUri
                                                      .pathSegments
                                                      .last,
                                                ),
                                                subtitle: Text(
                                                  dbInfo.databaseUri.path,
                                                ),
                                                trailing: IconButton(
                                                  onPressed: () async {
                                                    context
                                                        .read<HomeCubit>()
                                                        .removeDatabaseFromRecent(
                                                          databaseInfo: dbInfo,
                                                        );
                                                  },
                                                  icon: Icon(Icons.close),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Spacer(flex: 1),
                                ],
                              ),
                            );
                        }
                      },
                    ),
                  );
              }
            },
          ),
        ),
      ),
    );
  }
}
