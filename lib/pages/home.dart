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
import 'package:squealer/pages/viewer_widgets/connection_button_state.dart';
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
  final dbConnectionTextController = TextEditingController();
  final dbConnectionScrollController = ScrollController();
  final recentDbsExpansionController = ExpansibleController();
  final encryptionTextController = TextEditingController();


  bool shouldUseCustomFilePicker = false;
  EncryptionType encryptionType = EncryptionType.unencrypted;
  ButtonState currentButtonState = PickState();

  @override
  void dispose() {
    dbConnectionTextController.dispose();
    dbConnectionScrollController.dispose();
    recentDbsExpansionController.dispose();
    encryptionTextController.dispose();

    super.dispose();
  }

  Future<void> setDatabase({
    required BuildContext buildContext,
    required DatabaseInfo databaseInfo,
  }) async {
    dbConnectionTextController.text = databaseInfo.databaseUri.toString();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // Doing this because the scroll max offset may not have been updated
      // yet
      dbConnectionScrollController.jumpTo(
        dbConnectionScrollController.position.maxScrollExtent,
      );
    });
    setState(() {
      //TODO: it actually saves the password and secret type but doesnt restore
      //it correctly when selected from recent databases, fix that
      currentButtonState = ConnectState(dbInfo: databaseInfo);
    });
  }

  Future<void> connectDatabase({
    required BuildContext buildContext,
    required DatabaseInfo databaseInfo,
  }) async {
    // TODO: move this logic to cubit
    switch (encryptionType) {
      case EncryptionType.unencrypted:
        break;
      case EncryptionType.passphrase:
        final key = encryptionTextController.text.trim();
        if (key.isEmpty) {
          showSnackBar(context, text: "Invalid passphrase");
          return;
        } else {
          databaseInfo = SQLiteCipherDatabaseInfo(
            databaseUri: databaseInfo.databaseUri,
            secret: encryptionTextController.text.trim(),
            secretType: SecretType.passphrase,
          );
        }
      case EncryptionType.keyHexdigest:
        final key = encryptionTextController.text.trim();
        // Key has to be either 64 or 96 length hexdigest, according to
        // https://www.zetetic.net/sqlcipher/sqlcipher-api/
        if (key.isNotEmpty && [64, 96].contains(key.length)) {
          databaseInfo = SQLiteCipherDatabaseInfo(
            databaseUri: databaseInfo.databaseUri,
            secret: encryptionTextController.text.trim(),
            secretType: SecretType.keyHexDigest,
          );
        } else {
          showSnackBar(context, text: "Invalid Key hexdigest length");
          return;
        }
    }
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
          // TODO: this doesnt work, fix it
          Loggify.getLogger?.config(
            "Handling ${widget.databaseContentUri} while creating HomeCubit",
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
                          await setDatabase(
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
                              child: SingleChildScrollView(
                                child: SizedBox(
                                  height:
                                      MediaQuery.sizeOf(context).height * 0.9,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Spacer(flex: 4),
                                      Spacer(flex: 1),
                                      Row(
                                        spacing: 16,
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              readOnly: true,
                                              controller:
                                                  dbConnectionTextController,
                                              scrollController:
                                                  dbConnectionScrollController,
                                              decoration: InputDecoration(
                                                hintText: "Database path",
                                                label:
                                                    switch (currentButtonState) {
                                                      ConnectState(
                                                        dbInfo: DatabaseInfo(
                                                          :final databaseUri,
                                                        ),
                                                      ) =>
                                                        Text(
                                                          databaseUri
                                                              .pathSegments
                                                              .last,
                                                        ),
                                                      _ => null,
                                                    },
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                          ),
                                          FilledButton.icon(
                                            style: FilledButton.styleFrom(
                                              padding: EdgeInsets.fromLTRB(
                                                8,
                                                0,
                                                0,
                                                0,
                                              ),
                                            ),
                                            onPressed: switch (currentButtonState) {
                                              PickState() => () async {
                                                if (shouldUseCustomFilePicker) {
                                                  final databaseFileResult =
                                                      await showIoFilePicker(
                                                        context,
                                                        pickerConfig:
                                                            SingleFilePickerConfig(
                                                              allowedExtensions:
                                                                  allowedExtension
                                                                      .map(
                                                                        (e) =>
                                                                            ".$e",
                                                                      )
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
                                              ConnectState(dbInfo: null) =>
                                                null,
                                              ConnectState(:final dbInfo) =>
                                                () async {
                                                  await connectDatabase(
                                                    buildContext: context,
                                                    databaseInfo: dbInfo!,
                                                  );
                                                },
                                              CreateState() => null,
                                            },
                                            icon: currentButtonState.icon,
                                            label: Row(
                                              children: [
                                                Text(currentButtonState.text),
                                                SizedBox(width: 5),
                                                InkWell(
                                                  splashColor: Theme.of(context)
                                                      .buttonTheme
                                                      .colorScheme!
                                                      .inversePrimary,
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                  onTapUp: (details) async {
                                                    final offset =
                                                        details.globalPosition;
                                                    final picked =
                                                        await showMenu<
                                                          ButtonState?
                                                        >(
                                                          context: context,

                                                          position:
                                                              RelativeRect.fromLTRB(
                                                                offset.dx,
                                                                offset.dy,
                                                                MediaQuery.of(
                                                                      context,
                                                                    ).size.width -
                                                                    offset.dx,
                                                                MediaQuery.of(
                                                                      context,
                                                                    ).size.height -
                                                                    offset.dy,
                                                              ),
                                                          items: ButtonState
                                                              .values
                                                              .map((e) {
                                                                return PopupMenuItem(
                                                                  value: e,
                                                                  child: Text(
                                                                    e.text,
                                                                  ),
                                                                );
                                                              })
                                                              .toList(),
                                                        );
                                                    if (picked != null &&
                                                        picked.runtimeType !=
                                                            currentButtonState
                                                                .runtimeType) {
                                                      dbConnectionTextController
                                                              .text =
                                                          "";
                                                      setState(() {
                                                        currentButtonState =
                                                            picked;
                                                      });
                                                    }
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          8.0,
                                                        ),
                                                    child: Icon(
                                                      Icons.arrow_drop_down,
                                                      size: 30,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 10),
                                      ExpansionTile(
                                        title: Text("Configuration"),
                                        shape: const Border(),
                                        childrenPadding: EdgeInsets.only(
                                          left: 16,
                                          right: 16,
                                        ),
                                        children: [
                                          if (Platform.isAndroid) ...[
                                            SwitchListTile(
                                              title: Text(
                                                "Use direct file access (Android)",
                                              ),
                                              value: shouldUseCustomFilePicker,
                                              contentPadding: EdgeInsets.all(8),
                                              onChanged: (value) async {
                                                final storagePermision =
                                                    await Permission
                                                        .manageExternalStorage
                                                        .request();
                                                if (storagePermision
                                                    .isGranted) {
                                                  setState(() {
                                                    shouldUseCustomFilePicker =
                                                        value;
                                                  });
                                                }
                                              },
                                            ),
                                            SizedBox(height: 10),
                                          ],

                                          Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              spacing: 16,
                                              children: [
                                                Text("Encryption:"),
                                                Expanded(
                                                  child: DropdownMenu(
                                                    requestFocusOnTap: true,
                                                    controller:
                                                        encryptionTextController,
                                                    label: Text(
                                                      encryptionType.text,
                                                    ),
                                                    selectOnly:
                                                        encryptionType ==
                                                        EncryptionType
                                                            .unencrypted,
                                                    hintText:
                                                        switch (encryptionType) {
                                                          EncryptionType
                                                              .unencrypted =>
                                                            "",
                                                          EncryptionType
                                                              .passphrase =>
                                                            "Type passphrase",
                                                          EncryptionType
                                                              .keyHexdigest =>
                                                            "Type key hexdigest",
                                                        },
                                                    expandedInsets:
                                                        EdgeInsets.zero,
                                                    onSelected: (value) {
                                                      if (value != null) {
                                                        setState(() {
                                                          encryptionType =
                                                              value;
                                                        });
                                                      }
                                                    },
                                                    dropdownMenuEntries: [
                                                      DropdownMenuEntry(
                                                        value: EncryptionType
                                                            .unencrypted,
                                                        labelWidget: Text(
                                                          EncryptionType
                                                              .unencrypted
                                                              .text,
                                                        ),
                                                        label: "",
                                                      ),
                                                      DropdownMenuEntry(
                                                        value: EncryptionType
                                                            .passphrase,
                                                        labelWidget: Text(
                                                          EncryptionType
                                                              .passphrase
                                                              .text,
                                                        ),
                                                        label: "",
                                                      ),
                                                      DropdownMenuEntry(
                                                        value: EncryptionType
                                                            .keyHexdigest,
                                                        labelWidget: Text(
                                                          EncryptionType
                                                              .keyHexdigest
                                                              .text,
                                                        ),
                                                        label: "",
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Spacer(flex: 1),
                                      SizedBox(height: 10),
                                      ExpansionTile(
                                        controller:
                                            recentDbsExpansionController,
                                        title: Text("Recent databases"),
                                        childrenPadding: EdgeInsets.only(
                                          left: 16,
                                          right: 16,
                                        ),
                                        children: [
                                          SizedBox(
                                            height:
                                                MediaQuery.sizeOf(
                                                  context,
                                                ).height *
                                                0.4,
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              itemBuilder: (context, index) {
                                                final dbInfo =
                                                    recentDatabases[index];
                                                return ListTile(
                                                  onTap: () async {
                                                    recentDbsExpansionController
                                                        .collapse();
                                                    await setDatabase(
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
                                                            databaseInfo:
                                                                dbInfo,
                                                          );
                                                    },
                                                    icon: Icon(Icons.close),
                                                  ),
                                                );
                                              },
                                              itemCount: recentDatabases.length,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                      // Visibility.maintain(
                                      //   visible: recentDatabases.isNotEmpty,
                                      //   child: SizedBox(
                                      //     height:
                                      //         MediaQuery.sizeOf(context).height *
                                      //         0.3,
                                      //     child: Badge(
                                      //       backgroundColor: Theme.of(
                                      //         context,
                                      //       ).buttonTheme.colorScheme?.secondary,
                                      //       textColor: Theme.of(
                                      //         context,
                                      //       ).buttonTheme.colorScheme?.onSecondary,
                                      //       alignment: Alignment.topLeft,
                                      //       label: Text("Recent databases"),
                                      //       child: Card.outlined(
                                      //         clipBehavior: Clip.hardEdge,
                                      //         margin: EdgeInsets.all(8),
                                      //         child: ListView.builder(
                                      //           // shrinkWrap: true,
                                      //           itemCount: recentDatabases.length,
                                      //           itemBuilder: (context, index) {
                                      //             final dbInfo =
                                      //                 recentDatabases[index];
                                      //             return ListTile(
                                      //               onTap: () async {
                                      //                 await useTable(
                                      //                   buildContext: context,
                                      //                   databaseInfo: dbInfo,
                                      //                 );
                                      //               },
                                      //               title: Text(
                                      //                 dbInfo
                                      //                     .databaseUri
                                      //                     .pathSegments
                                      //                     .last,
                                      //               ),
                                      //               subtitle: Text(
                                      //                 dbInfo.databaseUri.path,
                                      //               ),
                                      //               trailing: IconButton(
                                      //                 onPressed: () async {
                                      //                   context
                                      //                       .read<HomeCubit>()
                                      //                       .removeDatabaseFromRecent(
                                      //                         databaseInfo: dbInfo,
                                      //                       );
                                      //                 },
                                      //                 icon: Icon(Icons.close),
                                      //               ),
                                      //             );
                                      //           },
                                      //         ),
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                      // Spacer(flex: 1),
                                    ],
                                  ),
                                ),
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

enum EncryptionType {
  unencrypted(text: "Unencrypted"),
  passphrase(text: "Passphrase"),
  keyHexdigest(text: "Key Hexdigest");

  final String text;
  const EncryptionType({required this.text});
}
