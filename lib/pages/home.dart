import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:squealer/core/init_setup.dart';
import 'package:squealer/core/routes.dart';
import 'package:squealer/cubit/home_cubit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String filePath = "";
  final controller = TextEditingController();
  bool shouldUseCustomFilePicker = false;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(filePickerRepository: sl()),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(title: Text("Squealer")),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: BlocConsumer<HomeCubit, HomeState>(
              listener: (context, state) {
                if (state case HomeDatabaseFilePicked(:final databaseFile)) {
                  context.push(SquealerRouter.viewerPage, extra: databaseFile);
                }
              },
              builder: (context, state) {
                switch (state) {
                  case HomeInitial():
                  case HomeLoading():
                    return Center(child: CircularProgressIndicator());
                  case HomeDatabaseFilePicked():
                  case HomeLoaded():
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (Platform.isAndroid) ...[
                            SwitchListTile(
                              title: Text("Use direct file access (Android)"),
                              value: shouldUseCustomFilePicker,
                              onChanged: (value) {
                                setState(() {
                                  shouldUseCustomFilePicker = value;
                                });
                              },
                            ),
                            SizedBox(height: 20),
                          ],
                          FilledButton.icon(
                            onPressed: () async {
                              await context.read<HomeCubit>().pickDatabaseFile(
                                androidUseCustomPicker:
                                    shouldUseCustomFilePicker,
                              );
                            },
                            label: Text("Pick SQLite file"),
                            icon: Icon(Icons.file_open),
                          ),
                          // OutlinedButton(
                          //   onPressed: () async {
                          //     final result = await FilePicker.platform.pickFiles(
                          //       allowMultiple: false,
                          //       allowedExtensions: ["sqlite", "db"],
                          //       type: FileType.custom,
                          //     );
                          //     if (result != null) {
                          //       setState(() {
                          //         filePath = result.files.first.path ?? "No path";
                          //       });
                          //     }
                          //   },
                          //   child: Text("Open SQLite SAF"),
                          // ),
                          // FilledButton.icon(
                          //   onPressed: () async {
                          //     final status = await Permission.manageExternalStorage
                          //         .request();
                          //     if (status.isGranted) {
                          //       final pickerResult = await PickOrSave().filePicker(
                          //         params: FilePickerParams(
                          //           getCachedFilePath: false,
                          //           enableMultipleSelection: false,
                          //           localOnly: true,
                          //           allowedExtensions: [".sqlite", ".db"],
                          //           pickerType: PickerType.file,
                          //         ),
                          //       );
                          //       if (pickerResult != null && pickerResult.isNotEmpty) {
                          //         final filePathResult = await UriFileReader.instance
                          //             .getFileInfoFromUri(pickerResult.first);

                          //         print(
                          //           "${filePathResult?.fileName} ${filePathResult?.path}",
                          //         );
                          //         if (filePathResult != null &&
                          //             filePathResult.path != null) {
                          //           setState(() {
                          //             filePath = filePathResult.path!;
                          //           });
                          //         }
                          //       }
                          //     }
                          //   },
                          //   label: Text("Open SQLite native"),
                          //   icon: Icon(Icons.file_open),
                          // ),
                          // SizedBox(
                          //   height: 300,
                          //   child: SingleChildScrollView(child: Text(filePath)),
                          // ),
                          // TextField(controller: controller),
                          // OutlinedButton(
                          //   onPressed: () async {
                          //     final command = controller.text.split(" ");

                          //     final pOut = await Process.run(
                          //       command.first,
                          //       command.sublist(1),
                          //       // runInShell: true,
                          //     );
                          //     print(pOut.stderr);
                          //     setState(() {
                          //       filePath = pOut.stdout.toString();
                          //     });
                          //   },
                          //   child: Text("Run command"),
                          // ),
                        ],
                      ),
                    );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
