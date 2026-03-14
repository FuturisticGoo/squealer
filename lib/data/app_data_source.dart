import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:futuristicgoo_utils/futuristicgoo_utils.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:squealer/core/entities/database_meta_entities.dart';
import 'package:squealer/core/entities/failure_success.dart';
import 'package:squealer/core/entities/saved_statements.dart';
import 'package:squealer/data/app_data_repo.dart';

class AppDataRepoImpl implements AppDataRepo {
  final AppDataSourceSQLite appDataSourceSQLite;
  const AppDataRepoImpl({required this.appDataSourceSQLite});

  @override
  Future<Either<Failure, List<DatabaseInfo>>> getRecentDatabases() async {
    try {
      final recentDatabases = await appDataSourceSQLite.getRecentDatabases();
      return Either.right(recentDatabases);
    } catch (error, stackTrace) {
      Loggify.getLogger?.severe(
        "Unknown error in $AppDataRepoImpl while doing $getRecentDatabases",
        error,
        stackTrace,
      );
      return Either.left(GenericFailure(error: error, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, List<SavedStatement>>> getSavedSQLStatements() async {
    try {
      final savedStatements = await appDataSourceSQLite.getSavedSQLStatements();
      return Either.right(savedStatements);
    } catch (error, stackTrace) {
      Loggify.getLogger?.severe(
        "Unknown error in $AppDataRepoImpl while doing $getSavedSQLStatements",
        error,
        stackTrace,
      );
      return Either.left(GenericFailure(error: error, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, Success>> removeDatabaseFromRecent({
    required DatabaseInfo? databaseInfo,
  }) async {
    try {
      await appDataSourceSQLite.deleteDatabaseFromRecent(
        databaseInfo: databaseInfo,
      );
      return Either.right(Success());
    } catch (error, stackTrace) {
      Loggify.getLogger?.severe(
        "Unknown error in $AppDataRepoImpl while doing $removeDatabaseFromRecent",
        error,
        stackTrace,
      );
      return Either.left(GenericFailure(error: error, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, Success>> removeSQLStatement({
    required SavedStatement? savedStatement,
  }) async {
    try {
      await appDataSourceSQLite.deleteStatement(savedStatement: savedStatement);
      return Either.right(Success());
    } catch (error, stackTrace) {
      Loggify.getLogger?.severe(
        "Unknown error in $AppDataRepoImpl while doing $removeSQLStatement",
        error,
        stackTrace,
      );
      return Either.left(GenericFailure(error: error, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, Success>> saveDatabaseToRecent({
    required DatabaseInfo databaseInfo,
  }) async {
    try {
      await appDataSourceSQLite.saveDatabaseToRecent(
        databaseInfo: databaseInfo,
      );
      return Either.right(Success());
    } catch (error, stackTrace) {
      Loggify.getLogger?.severe(
        "Unknown error in $AppDataRepoImpl while doing $saveDatabaseToRecent",
        error,
        stackTrace,
      );
      return Either.left(GenericFailure(error: error, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, Success>> saveSQLStatement({
    required String name,
    required String statement,
  }) async {
    try {
      await appDataSourceSQLite.saveStatement(name: name, statement: statement);
      return Either.right(Success());
    } catch (error, stackTrace) {
      Loggify.getLogger?.severe(
        "Unknown error in $AppDataRepoImpl while doing $saveSQLStatement",
        error,
        stackTrace,
      );
      return Either.left(GenericFailure(error: error, stackTrace: stackTrace));
    }
  }
}

class AppDataSourceSQLite {
  final SqliteDatabase db;
  AppDataSourceSQLite({required this.db});

  Future<void> migrate({
    required SemVer fromVersion,
    required SemVer toVersion,
  }) async {
    Loggify.getLogger?.info(
      "Migrating from $fromVersion to $toVersion in $AppDataSourceSQLite",
    );
    if (fromVersion < SemVer.fromString("0.1.4") &&
        toVersion >= SemVer.fromString("0.1.4")) {
      await _migrateAddNameColumn();
    }
  }

  Future<void> _migrateAddNameColumn() async {
    await db.execute(""" 
ALTER TABLE 
  ${_SQLNames.savedSQLStatementsTable}
ADD COLUMN
  ${_SQLNames.statementNameColumnName} TEXT NOT NULL DEFAULT ''
    """);
  }

  Future<void> ensureTables() async {
    await db.execute("""
CREATE TABLE IF NOT EXISTS 
  ${_SQLNames.recentDatabasesTableName} 
(
  ${_SQLNames.databaseInfoJsonColumnName} TEXT NOT NULL
)
""");
    await db.execute("""
CREATE TABLE IF NOT EXISTS 
  ${_SQLNames.savedSQLStatementsTable} 
(
  ${_SQLNames.statementNameColumnName} TEXT NOT NULL,
  ${_SQLNames.statementColumnName} TEXT NOT NULL
)
""");
  }

  Future<List<DatabaseInfo>> getRecentDatabases() async {
    final recentDatabasesResult = await db.getAll(""" 
SELECT 
  ${_SQLNames.databaseInfoJsonColumnName}
FROM
  ${_SQLNames.recentDatabasesTableName}
    """);
    return recentDatabasesResult.map((row) {
      final jsonString = row[_SQLNames.databaseInfoJsonColumnName] as String;
      return DatabaseInfo.fromJson(
        Map.from(jsonDecode(jsonString) as Map<dynamic, dynamic>),
      );
    }).toList();
  }

  Future<void> saveDatabaseToRecent({
    required DatabaseInfo databaseInfo,
  }) async {
    await db.execute(
      """
INSERT INTO
  ${_SQLNames.recentDatabasesTableName}
  (${_SQLNames.databaseInfoJsonColumnName})
VALUES
  (?)
 """,
      [jsonEncode(databaseInfo.toJson())],
    );
  }

  Future<void> deleteDatabaseFromRecent({
    required DatabaseInfo? databaseInfo,
  }) async {
    if (databaseInfo != null) {
      await db.execute(
        """
DELETE FROM
  ${_SQLNames.recentDatabasesTableName}
WHERE
  ${_SQLNames.databaseInfoJsonColumnName}=?
 """,
        [jsonEncode(databaseInfo.toJson())],
      );
    } else {
      await db.execute("""
DELETE FROM
  ${_SQLNames.recentDatabasesTableName}
  """);
    }
  }

  Future<List<SavedStatement>> getSavedSQLStatements() async {
    final savedSQLStatementsResult = await db.getAll(""" 
SELECT 
  rowid, ${_SQLNames.statementNameColumnName}, ${_SQLNames.statementColumnName}
FROM
  ${_SQLNames.savedSQLStatementsTable}
    """);
    return savedSQLStatementsResult
        .map(
          (row) => SavedStatement(
            id: row["rowid"] as int,
            name: row[_SQLNames.statementNameColumnName] as String,
            statement: row[_SQLNames.statementColumnName] as String,
          ),
        )
        .toList();
  }

  Future<void> saveStatement({
    required String name,
    required String statement,
  }) async {
    await db.execute(
      """ 
INSERT INTO
  ${_SQLNames.savedSQLStatementsTable}
  (${_SQLNames.statementNameColumnName}, ${_SQLNames.statementColumnName})
VALUES
  (?, ?)
    """,
      [name, statement],
    );
  }

  Future<void> deleteStatement({
    required SavedStatement? savedStatement,
  }) async {
    if (savedStatement != null) {
      await db.execute(
        """ 
DELETE FROM
  ${_SQLNames.savedSQLStatementsTable}
WHERE
  rowid=?
    """,
        [savedStatement.id],
      );
    } else {
      await db.execute(""" 
DELETE FROM
  ${_SQLNames.savedSQLStatementsTable}
      """);
    }
  }
}

abstract final class _SQLNames {
  static const recentDatabasesTableName = "recent_databases";
  static const databaseInfoJsonColumnName = "database_info_json";

  static const savedSQLStatementsTable = "saved_sql_statements";
  static const statementNameColumnName = "name";
  static const statementColumnName = "statement";
}
