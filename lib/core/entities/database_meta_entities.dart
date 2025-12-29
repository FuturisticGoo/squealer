import 'package:equatable/equatable.dart';
import 'package:sqlite_async/sqlite_async.dart';

sealed class DatabaseInfo extends Equatable {
  final Uri databaseUri;
  const DatabaseInfo({required this.databaseUri});
  @override
  List<Object?> get props => [databaseUri];
}

class SQLiteDatabaseInfo extends DatabaseInfo {
  const SQLiteDatabaseInfo({required super.databaseUri});
}

sealed class DatabaseObject with EquatableMixin {
  const DatabaseObject();
}

class SQLite3AsyncDatabaseObject extends DatabaseObject {
  final SqliteDatabase db;
  const SQLite3AsyncDatabaseObject({required this.db});
  @override
  List<Object?> get props => [db];
}
