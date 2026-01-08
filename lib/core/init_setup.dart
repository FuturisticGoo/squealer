import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:squealer/core/constants.dart';
import 'package:futuristicgoo_utils/futuristicgoo_utils.dart';
import 'package:squealer/data/file_picker_repo.dart';
import 'package:squealer/data/file_picker_source.dart';
import 'package:squealer/data/settings_repo.dart';
import 'package:squealer/data/settings_source.dart';
import 'package:squealer/data/viewer_repo.dart';
import 'package:squealer/data/viewer_source.dart';
import 'package:path/path.dart' as p;

final sl = GetIt.instance;

Future<void> initSetup() async {
  Loggify.init(loggerName: "${appName}Logger");
  Loggify.getLogger?.level = Level.ALL;

  final appDir = await getAppPrivateDataDir(appName: appName);
  final dbPath = p.join(appDir, appDatabase);
  Loggify.getLogger?.fine("Opening database at $dbPath");
  final db = SqliteDatabase(path: dbPath);

  sl.registerSingleton<FilePickerSource>(NativeFilePicker());
  sl.registerSingleton<CustomFilePicker>(CustomFilePicker());

  sl.registerSingleton<FilePickerRepository>(
    FilePickerRepository(nativeFilePicker: sl(), customFilePicker: sl()),
  );

  sl.registerSingleton(SQLite3AsyncSQLiteSource());
  sl.registerSingleton<ViewerRepo>(
    SQLiteViewerRepo(sqLite3AsyncSQLiteSource: sl()),
  );

  sl.registerSingleton(SqliteSettingsSource(db: db));
  sl.registerSingleton<SettingsRepo>(
    SettingsRepoImpl(sqliteSettingsSource: sl()),
  );
}
