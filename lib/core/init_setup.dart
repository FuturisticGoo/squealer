import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:squealer/core/cipher_sqlite_factory.dart';
import 'package:squealer/core/constants.dart';
import 'package:futuristicgoo_utils/futuristicgoo_utils.dart';
import 'package:squealer/data/app_data_repo.dart';
import 'package:squealer/data/app_data_source.dart';
import 'package:squealer/data/exporter_repo.dart';
import 'package:squealer/data/exporter_source.dart';
import 'package:squealer/data/file_picker_repo.dart';
import 'package:squealer/data/file_picker_source.dart';
import 'package:squealer/data/settings_repo.dart';
import 'package:squealer/data/settings_source.dart';
import 'package:squealer/data/viewer_repo.dart';
import 'package:squealer/data/viewer_source.dart';
import 'package:path/path.dart' as p;
import 'package:uri_content/uri_content.dart';

final sl = GetIt.instance;

Future<void> initSetup() async {
  Loggify.init(loggerName: "${appName}Logger");
  Loggify.getLogger?.level = Level.ALL;

  final appDir = await getAppPrivateDataDir(appName: appName);
  final dbPath = p.join(appDir, appDatabase);
  Loggify.getLogger?.fine("Opening database at $dbPath");
  final db = SqliteDatabase.withFactory(CipherSqliteFactory(path: dbPath));

  sl.registerSingleton<FilePickerSource>(NativeFilePicker());
  final uriContent = UriContent();
  sl.registerSingleton<CustomFilePicker>(
    CustomFilePicker(uriContent: uriContent),
  );

  sl.registerSingleton<FilePickerRepository>(
    FilePickerRepository(nativeFilePicker: sl(), customFilePicker: sl()),
  );

  sl.registerSingleton<ExporterSource>(ExporterSource());
  sl.registerSingleton<ExporterRepo>(ExporterRepoImpl(exporterSource: sl()));

  sl.registerSingleton(SQLite3AsyncSQLiteSource());
  sl.registerSingleton<ViewerRepo>(
    SQLiteViewerRepo(sqLite3AsyncSQLiteSource: sl()),
  );

  sl.registerSingleton(SqliteSettingsSource(db: db));
  await sl<SqliteSettingsSource>().ensureTables();
  sl.registerSingleton<SettingsRepo>(
    SettingsRepoImpl(sqliteSettingsSource: sl()),
  );

  sl.registerSingleton(AppDataSourceSQLite(db: db));
  await sl<AppDataSourceSQLite>().ensureTables();
  sl.registerSingleton<AppDataRepo>(AppDataRepoImpl(appDataSourceSQLite: sl()));
}
