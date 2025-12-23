import 'package:fpdart/fpdart.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlparser/sqlparser.dart' as sqlparser;
import 'package:squealer/core/entities/database_meta_entities.dart';
import 'package:squealer/core/entities/database_data_entities.dart';
import 'package:squealer/core/entities/failure_success.dart';
import 'package:squealer/data/viewer_repo.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite;

class SQLiteViewerRepo implements ViewerRepo {
  final SQFliteSQLiteSource sQFliteSQLiteSource;
  const SQLiteViewerRepo({required this.sQFliteSQLiteSource});
  @override
  Future<Either<Failure, DatabaseObject>> openDatabase({
    required DatabaseInfo databaseInfo,
  }) async {
    try {
      switch (databaseInfo) {
        case SQLiteDatabaseInfo(:final databaseUri):
          final dbObject = await sQFliteSQLiteSource.openDatabase(
            dbPath: databaseUri.toFilePath(),
          );
          return Either.right(dbObject);
        default:
          throw UnimplementedError("Invalid database for sqlite");
      }
    } catch (error) {
      return Either.left(DatabaseOpenFailure(error: error));
    }
  }

  @override
  Future<Either<Failure, Success>> closeDatabase({
    required DatabaseObject databaseObject,
  }) async {
    try {
      switch (databaseObject) {
        case SQLiteDatabaseObject(:final db):
          await sQFliteSQLiteSource.closeDatabase(db: db);
          return Either.right(Success());
        default:
          throw UnimplementedError("Invalid database for sqlite");
      }
    } catch (error) {
      return Either.left(DatabaseCloseFailure(error: error));
    }
  }

  @override
  Future<Either<Failure, List<String>>> listTableNames({
    required DatabaseObject databaseObject,
  }) async {
    try {
      switch (databaseObject) {
        case SQLiteDatabaseObject(:final db):
          final tableNames = await sQFliteSQLiteSource.listTableNames(db: db);
          return Either.right(tableNames);
        default:
          throw UnimplementedError("Invalid database for sqlite");
      }
    } catch (error) {
      return Either.left(DatabaseOpenFailure(error: error));
    }
  }

  @override
  Future<Either<Failure, DatabaseTable>> getTableInfo({
    required DatabaseObject databaseObject,
    required String tableName,
  }) async {
    try {
      switch (databaseObject) {
        case SQLiteDatabaseObject(:final db):
          final tableInfo = await sQFliteSQLiteSource.getTableInfo(
            db: db,
            tableName: tableName,
          );
          return Either.right(tableInfo);
        default:
          throw UnimplementedError("Invalid database for sqlite");
      }
    } on NotSingleTableError catch (_) {
      return Either.left(NotSingleTableFailure());
    } on InvalidSQLStatementError catch (_) {
      return Either.left(InvalidSQLStatementFailure());
    } catch (error) {
      return Either.left(DatabaseOpenFailure(error: error));
    }
  }

  @override
  Future<Either<Failure, List<String>>> listViewNames({
    required DatabaseObject databaseObject,
  }) async {
    try {
      switch (databaseObject) {
        case SQLiteDatabaseObject(:final db):
          final viewNames = await sQFliteSQLiteSource.listViewNames(db: db);
          return Either.right(viewNames);
        default:
          throw UnimplementedError("Invalid database for sqlite");
      }
    } catch (error) {
      return Either.left(DatabaseOpenFailure(error: error));
    }
  }

  @override
  Future<Either<Failure, DatabaseView>> getViewInfo({
    required DatabaseObject databaseObject,
    required String viewName,
  }) async {
    try {
      switch (databaseObject) {
        case SQLiteDatabaseObject(:final db):
          final viewInfo = await sQFliteSQLiteSource.getViewInfo(
            db: db,
            viewName: viewName,
          );
          return Either.right(viewInfo);
        default:
          throw UnimplementedError("Invalid database for sqlite");
      }
    } on NotSingleViewError catch (_) {
      return Either.left(NotSingleViewFailure());
    } catch (error) {
      return Either.left(DatabaseOpenFailure(error: error));
    }
  }

  @override
  Future<Either<Failure, DatabaseQueryResult>> getRowsOfTable({
    required DatabaseObject databaseObject,
    required String tableName,
    List<String>? columnsToSelect,
    String? orderBy,
    bool? isDescendingOrder,
    int? fromRowId,
    int? toRowId,
  }) async {
    try {
      switch (databaseObject) {
        case SQLiteDatabaseObject(:final db):
          final queryResult = await sQFliteSQLiteSource.getRowsOfTable(
            db: db,
            tableName: tableName,
            columnsToSelect: columnsToSelect,
            fromRowId: fromRowId,
            toRowId: toRowId,
            orderBy: orderBy,
            isDescendingOrder: isDescendingOrder,
          );
          return Either.right(queryResult);
        default:
          throw UnimplementedError("Invalid database for sqlite");
      }
    } catch (error) {
      return Either.left(DatabaseOpenFailure(error: error));
    }
  }

  @override
  Future<Either<Failure, DatabaseQueryResult>> executeRawQuery({
    required DatabaseObject databaseObject,
    required String query,
  }) async {
    try {
      switch (databaseObject) {
        case SQLiteDatabaseObject(:final db):
          final queryResult = await sQFliteSQLiteSource.executeRawQuery(
            db: db,
            query: query,
          );
          return Either.right(queryResult);
        default:
          throw UnimplementedError("Invalid database for sqlite");
      }
    } catch (error) {
      return Either.left(DatabaseOpenFailure(error: error));
    }
  }
}

class SQFliteSQLiteSource {
  final sqlparser.SqlEngine sqlEngine;
  const SQFliteSQLiteSource({required this.sqlEngine});

  Future<DatabaseObject> openDatabase({required String dbPath}) async {
    final db = await sqflite.openDatabase(dbPath);
    return SQLiteDatabaseObject(db: db);
  }

  Future<void> closeDatabase({required Database db}) async {
    await db.close();
  }

  Future<List<String>> listTableNames({required Database db}) async {
    final tablesResult = await db.rawQuery(""" 
SELECT 
  name 
FROM 
  sqlite_master 
WHERE 
  type='table';
    """);
    return tablesResult.map((e) => e["name"] as String).toList();
  }

  Future<DatabaseTable> getTableInfo({
    required Database db,
    required String tableName,
  }) async {
    final tableInfoResult = await db.rawQuery(
      """ 
SELECT 
  sql
FROM 
  sqlite_master 
WHERE 
  type='table'
AND
  name=?
    """,
      [tableName],
    );
    if (tableInfoResult.length != 1) {
      throw NotSingleTableError();
    }
    final createTableQuery = tableInfoResult.single["sql"] as String;
    final parsedAst = sqlEngine.parse(createTableQuery);
    if (parsedAst.rootNode case sqlparser.CreateTableStatement(
      :final childNodes,
      :final tableName,
    )) {
      final tableColumns = <TableColumn>[];
      for (final column in childNodes) {
        if (column case sqlparser.ColumnDefinition(
          :final columnName,
          :final typeName,
          :final isNonNullable,
          :final constraints,
        )) {
          final tableColumn = TableColumn(
            columnName: columnName,
            dataType: typeName ?? "UNKNOWN",
            notNullable: isNonNullable,
            isPrimaryKey: constraints
                .whereType<sqlparser.PrimaryKeyColumn>()
                .isNotEmpty,
            unique: constraints.whereType<sqlparser.UniqueColumn>().isNotEmpty,
          );
          tableColumns.add(tableColumn);
        }
      }
      return DatabaseTable(
        tableName: tableName,
        columns: tableColumns,
        sql: createTableQuery,
      );
    } else {
      throw InvalidSQLStatementError();
    }
  }

  Future<List<String>> listViewNames({required Database db}) async {
    final viewsResult = await db.rawQuery(""" 
SELECT
  name
FROM
  sqlite_master
WHERE
  type='view'
    """);
    return viewsResult.map((e) => e["name"] as String).toList();
  }

  Future<DatabaseView> getViewInfo({
    required Database db,
    required String viewName,
  }) async {
    final tableInfoResult = await db.rawQuery(
      """ 
SELECT 
  sql
FROM 
  sqlite_master 
WHERE 
  type='view'
AND
  name=?
    """,
      [viewName],
    );
    if (tableInfoResult.length != 1) {
      throw NotSingleViewError();
    }
    final createViewQuery = tableInfoResult.single["sql"] as String;
    return DatabaseView(viewName: viewName, sql: createViewQuery);
  }

  Future<List<String>> _getColumnsOfTable({
    required Database db,
    required String tableName,
  }) async {
    final tableInfo = await getTableInfo(db: db, tableName: tableName);
    return tableInfo.columns.map((e) => e.columnName).toList();
  }

  Future<DatabaseQueryResult> getRowsOfTable({
    required Database db,
    required String tableName,
    List<String>? columnsToSelect,
    String? orderBy,
    bool? isDescendingOrder,
    int? fromRowId,
    int? toRowId,
  }) async {
    final privateRenamedRowId = "_private_renamed_row_id"; // rowid doesn't
    // show up if another column is primary key, so use this to force
    // the row id to show up
    final queryBuilder = StringBuffer();
    queryBuilder.writeln("SELECT");
    // If columnToSelect is null, it means SELECT *, ie all columns
    columnsToSelect ??= await _getColumnsOfTable(db: db, tableName: tableName);
    for (final column in columnsToSelect) {
      queryBuilder.write("$column, ");
    }
    queryBuilder.writeln("rowid as $privateRenamedRowId");

    queryBuilder.writeln('FROM "$tableName"'); // No, it doesn't matter that
    // it's vulnerable to SQL injection, the user is using it on their own db

    queryBuilder.writeln("WHERE");

    if (fromRowId != null) {
      queryBuilder.writeln(
        "$privateRenamedRowId>=$fromRowId AND",
      ); // This is not
      // vulnerable to SQL injection, so no problem
    }
    if (toRowId != null) {
      queryBuilder.writeln("$privateRenamedRowId<=$toRowId AND"); // Same here
    }
    queryBuilder.writeln("1=1"); // Default truthy condition for when there
    // is no above conditions given.

    if (orderBy != null) {
      queryBuilder.write(
        'ORDER BY "$orderBy" ${isDescendingOrder == null ? "DESC" : "ASC"}',
      );
    }
    final rowsResult = await db.rawQuery(queryBuilder.toString());
    final processedRows = <TableRow>[];
    for (final row in rowsResult) {
      final TableRow currentRow;
      currentRow = TableRow(
        rowId: (row[privateRenamedRowId] as int).toString(),
        rowData: columnsToSelect.map((e) => row[e]).toList(),
      );
      processedRows.add(currentRow);
    }
    return DatabaseQueryResult(
      columnNames: columnsToSelect,
      rows: processedRows,
      originalQuery: queryBuilder.toString(),
    );
  }

  Future<DatabaseQueryResult> executeRawQuery({
    required Database db,
    required String query,
  }) async {
    final rawQueryResult = await db.rawQuery(query);
    final processedRows = <TableRow>[];
    for (final row in rawQueryResult) {
      final TableRow currentRow = TableRow(
        rowId: (row["rowid"] as int).toString(),
        rowData: row.entries
            .where((e) => e.key != "rowid")
            .map((e) => e.value)
            .toList(),
      );

      processedRows.add(currentRow);
    }
    final List<String> columnNames = [];

    final firstRow = rawQueryResult.firstOrNull;
    if (firstRow != null) {
      columnNames.addAll(firstRow.keys.where((e) => e != "rowid"));
    }

    return DatabaseQueryResult(
      columnNames: columnNames,
      rows: processedRows,
      originalQuery: query,
    );
  }
}
