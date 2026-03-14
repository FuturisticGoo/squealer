import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite_async/sqlite3_common.dart';
import 'package:sqlite_async/sqlite3_open.dart';
import 'package:sqlite_async/sqlite_async.dart';
class CipherSqliteFactory extends DefaultSqliteOpenFactory {
  final String? pragmaToExecute;
  const CipherSqliteFactory({
    required super.path,
    super.sqliteOptions = const SqliteOptions.defaults(),
    this.pragmaToExecute,
  });
  @override
  CommonDatabase openDB(SqliteOpenOptions options) {
    // Do this before using any sqlite3 api
    open.overrideFor(OperatingSystem.android, openCipherOnAndroid);

    final cdb = super.openDB(options);
    if (pragmaToExecute != null) {
      // Any sqlcipher pragmas should be executed before everything else
      cdb.execute(pragmaToExecute!);
    }
    return cdb;
  }
}
