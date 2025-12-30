import 'package:get_it/get_it.dart';
import 'package:squealer/core/constants.dart';
import 'package:squealer/core/logging.dart';
import 'package:squealer/data/file_picker_repo.dart';
import 'package:squealer/data/file_picker_source.dart';
import 'package:squealer/data/viewer_repo.dart';
import 'package:squealer/data/viewer_source.dart';

final sl = GetIt.instance;

Future<void> initSetup() async {
  await initLogger();
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

  sl.registerSingleton(SQLite3AsyncSQLiteSource());
  sl.registerSingleton<ViewerRepo>(
    SQLiteViewerRepo(sqLite3AsyncSQLiteSource: sl()),
  );
}
