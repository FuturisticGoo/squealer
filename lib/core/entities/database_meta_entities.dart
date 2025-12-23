import 'package:equatable/equatable.dart';
import 'package:sqflite/sqflite.dart';

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

class SQLiteDatabaseObject extends DatabaseObject {
  final Database db;
  const SQLiteDatabaseObject({required this.db});
  @override
  List<Object?> get props => [db];
}
