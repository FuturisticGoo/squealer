import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite_async/sqlite3_common.dart';
import 'package:sqlite_async/sqlite3_open.dart';
import 'package:sqlite_async/sqlite_async.dart';

class CipherSqliteFactory extends DefaultSqliteOpenFactory {
  const CipherSqliteFactory({
    required super.path,
    super.sqliteOptions = const SqliteOptions.defaults(),
  });
  @override
  CommonDatabase openDB(SqliteOpenOptions options) {
    // Do this before using any sqlite3 api
    open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
    return super.openDB(options);
  }
}
