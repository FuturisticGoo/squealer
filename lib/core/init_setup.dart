import 'package:get_it/get_it.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlparser/sqlparser.dart';
import 'package:squealer/core/constants.dart';
import 'package:squealer/data/file_picker_repo.dart';
import 'dart:io';

import 'package:squealer/data/file_picker_source.dart';
import 'package:squealer/data/viewer_repo.dart';
import 'package:squealer/data/viewer_source.dart';

final sl = GetIt.instance;

Future<void> initSetup() async {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  sl.registerSingleton<FilePickerSource>(
    NativeFilePicker(),
    instanceName: nativeFilePickerInstance,
  );
  sl.registerSingleton<FilePickerSource>(
    CustomFilePicker(),
    instanceName: customFilePickerInstance,
  );

  sl.registerSingleton<FilePickerRepository>(
    FilePickerRepository(
      nativeFilePicker: sl(instanceName: nativeFilePickerInstance),
      customFilePicker: sl(instanceName: customFilePickerInstance),
    ),
  );

  sl.registerSingleton(SqlEngine());
  sl.registerSingleton(SQFliteSQLiteSource(sqlEngine: sl()));
  sl.registerSingleton<ViewerRepo>(SQLiteViewerRepo(sQFliteSQLiteSource: sl()));
}
