import 'package:fpdart/fpdart.dart';
import 'package:sqlparser/sqlparser.dart' as sqlparser;
import 'package:squealer/core/entities/database_meta_entities.dart';
import 'package:squealer/core/entities/database_data_entities.dart';
import 'package:squealer/core/entities/failure_success.dart';
import 'package:squealer/core/logging.dart';
import 'package:squealer/data/viewer_repo.dart';
import 'package:sqlite_async/sqlite_async.dart';

class SQLiteViewerRepo implements ViewerRepo {
  final SQLite3AsyncSQLiteSource sqLite3AsyncSQLiteSource;
  const SQLiteViewerRepo({required this.sqLite3AsyncSQLiteSource});
  @override
  Future<Either<Failure, DatabaseObject>> openDatabase({
    required DatabaseInfo databaseInfo,
  }) async {
    try {
      switch (databaseInfo) {
        case SQLiteDatabaseInfo(:final databaseUri):
          final dbObject = await sqLite3AsyncSQLiteSource.openDatabase(
            dbPath: databaseUri.toFilePath(),
          );
          return Either.right(dbObject);
        default:
          throw UnimplementedError("Invalid database for sqlite");
      }
    } catch (error, stackTrace) {
      getLogger().severe("Error while opening database", error, stackTrace);
      return Either.left(
        DatabaseOpenFailure(error: error, stackTrace: stackTrace),
      );
    }
  }

  @override
  Future<Either<Failure, Success>> closeDatabase({
    required DatabaseObject databaseObject,
  }) async {
    try {
      switch (databaseObject) {
        case SQLite3AsyncDatabaseObject(:final db):
          await sqLite3AsyncSQLiteSource.closeDatabase(db: db);
          return Either.right(Success());
        default:
          throw UnimplementedError("Invalid database for sqlite");
      }
    } catch (error, stackTrace) {
      getLogger().severe("Error while closing database", error, stackTrace);
      return Either.left(
        DatabaseCloseFailure(error: error, stackTrace: stackTrace),
      );
    }
  }

  @override
  Future<Either<Failure, List<String>>> listTableNames({
    required DatabaseObject databaseObject,
  }) async {
    try {
      switch (databaseObject) {
        case SQLite3AsyncDatabaseObject(:final db):
          final tableNames = await sqLite3AsyncSQLiteSource.listTableNames(
            db: db,
          );
          return Either.right(tableNames);
        default:
          throw UnimplementedError("Invalid database for sqlite");
      }
    } catch (error, stackTrace) {
      getLogger().severe("Error while listing table names", error, stackTrace);
      return Either.left(
        TableNameListingFailure(error: error, stackTrace: stackTrace),
      );
    }
  }

  @override
  Future<Either<Failure, DatabaseTable>> getTableInfo({
    required DatabaseObject databaseObject,
    required String tableName,
  }) async {
    try {
      switch (databaseObject) {
        case SQLite3AsyncDatabaseObject(:final db):
          final tableInfo = await sqLite3AsyncSQLiteSource.getTableInfo(
            db: db,
            tableName: tableName,
          );
          return Either.right(tableInfo);
        default:
          throw UnimplementedError("Invalid database for sqlite");
      }
    } on NotSingleTableError catch (error, stackTrace) {
      getLogger().severe(
        "Only one row expected, got unexpected length",
        error,
        stackTrace,
      );
      return Either.left(NotSingleTableFailure());
    } on InvalidSQLStatementError catch (error, stackTrace) {
      getLogger().severe(
        "Invalid SQL statement used in getTableInfo",
        error,
        stackTrace,
      );
      return Either.left(InvalidSQLStatementFailure());
    } catch (error, stackTrace) {
      getLogger().severe("Unknown error in getTableInfo", error, stackTrace);
      return Either.left(GenericFailure(error: error, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, List<String>>> listViewNames({
    required DatabaseObject databaseObject,
  }) async {
    try {
      switch (databaseObject) {
        case SQLite3AsyncDatabaseObject(:final db):
          final viewNames = await sqLite3AsyncSQLiteSource.listViewNames(
            db: db,
          );
          return Either.right(viewNames);
        default:
          throw UnimplementedError("Invalid database for sqlite");
      }
    } catch (error, stackTrace) {
      getLogger().severe("Error while listing view names", error, stackTrace);
      return Either.left(
        ViewNameListingFailure(error: error, stackTrace: stackTrace),
      );
    }
  }

  @override
  Future<Either<Failure, DatabaseView>> getViewInfo({
    required DatabaseObject databaseObject,
    required String viewName,
  }) async {
    try {
      switch (databaseObject) {
        case SQLite3AsyncDatabaseObject(:final db):
          final viewInfo = await sqLite3AsyncSQLiteSource.getViewInfo(
            db: db,
            viewName: viewName,
          );
          return Either.right(viewInfo);
        default:
          throw UnimplementedError("Invalid database for sqlite");
      }
    } on NotSingleViewError catch (error, stackTrace) {
      getLogger().severe(
        "Only one row expected, got unexpected length",
        error,
        stackTrace,
      );
      return Either.left(NotSingleViewFailure());
    } catch (error, stackTrace) {
      getLogger().severe("Unknown error in getViewInfo", error, stackTrace);
      return Either.left(GenericFailure(error: error, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, DatabaseQueryResult>> getRowsOfRelation({
    required DatabaseObject databaseObject,
    required String relationName,
    List<String>? columnsToSelect,
    String? orderBy,
    bool? isDescendingOrder,
    int? fromRowNumber,
    int? limitRows,
  }) async {
    try {
      switch (databaseObject) {
        case SQLite3AsyncDatabaseObject(:final db):
          final queryResult = await sqLite3AsyncSQLiteSource.getRowsOfRelation(
            db: db,
            relationName: relationName,
            columnsToSelect: columnsToSelect,
            fromRowNumber: fromRowNumber,
            limitRows: limitRows,
            orderBy: orderBy,
            isDescendingOrder: isDescendingOrder,
          );
          return Either.right(queryResult);
        default:
          throw UnimplementedError("Invalid database for sqlite");
      }
    } catch (error, stackTrace) {
      getLogger().severe(
        "Unknown error in getRowsOfRelation",
        error,
        stackTrace,
      );
      return Either.left(GenericFailure(error: error, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, DatabaseQueryResult>> executeRawQuery({
    required DatabaseObject databaseObject,
    required String query,
  }) async {
    try {
      switch (databaseObject) {
        case SQLite3AsyncDatabaseObject(:final db):
          final queryResult = await sqLite3AsyncSQLiteSource.executeRawQuery(
            db: db,
            query: query,
          );
          return Either.right(queryResult);
        default:
          throw UnimplementedError("Invalid database for sqlite");
      }
    } catch (error, stackTrace) {
      getLogger().severe("Unknown error in executeRawQuery", error, stackTrace);
      return Either.left(GenericFailure(error: error, stackTrace: stackTrace));
    }
  }
}

class SQLite3AsyncSQLiteSource {
  final sqlparser.SqlEngine sqlEngine;
  const SQLite3AsyncSQLiteSource({required this.sqlEngine});

  Future<SQLite3AsyncDatabaseObject> openDatabase({
    required String dbPath,
  }) async {
    final db = SqliteDatabase(path: dbPath);
    await db.initialize();
    return SQLite3AsyncDatabaseObject(db: db);
  }

  Future<void> closeDatabase({required SqliteDatabase db}) async {
    await db.close();
  }

  Future<List<String>> listTableNames({required SqliteDatabase db}) async {
    final tablesResult = await db.getAll(""" 
SELECT 
  name 
FROM 
  sqlite_master 
WHERE 
  type='table';
    """);
    return tablesResult.map((row) => row["name"] as String).toList();
  }

  Future<DatabaseTable> getTableInfo({
    required SqliteDatabase db,
    required String tableName,
  }) async {
    final tableInfoResult = await db.getAll(
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

  Future<List<String>> listViewNames({required SqliteDatabase db}) async {
    final viewsResult = await db.getAll(""" 
SELECT
  name
FROM
  sqlite_master
WHERE
  type='view'
    """);
    return viewsResult.map((row) => row["name"] as String).toList();
  }

  Future<DatabaseView> getViewInfo({
    required SqliteDatabase db,
    required String viewName,
  }) async {
    final tableInfoResult = await db.getAll(
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

  Future<DatabaseQueryResult> getRowsOfRelation({
    required SqliteDatabase db,
    required String relationName,
    List<String>? columnsToSelect,
    String? orderBy,
    bool? isDescendingOrder,
    int? fromRowNumber,
    int? limitRows,
  }) async {
    final privateRowNumber = "_private_row_number"; // Using this as the row
    // number column name

    final queryBuilder = StringBuffer();
    queryBuilder.writeln("SELECT ");
    queryBuilder.writeln("* FROM ( "); // The paranthesis is intentional

    queryBuilder.writeln("SELECT");
    // If columnToSelect is null, it means SELECT *, ie all columns
    columnsToSelect ??= ["*"];
    for (final column in columnsToSelect) {
      queryBuilder.write("$column, ");
    }
    queryBuilder.writeln("ROW_NUMBER() OVER() AS $privateRowNumber ");
    queryBuilder.writeln('FROM "$relationName"'); // No, it doesn't matter that
    // it's vulnerable to SQL injection, the user is using it on their own db

    if (orderBy != null) {
      queryBuilder.write(
        'ORDER BY "$orderBy" ${(isDescendingOrder ?? false) ? "DESC" : "ASC"}',
      );
    }

    queryBuilder.writeln(" ) WHERE");

    if (fromRowNumber != null) {
      switch (isDescendingOrder) {
        case true:
          queryBuilder.writeln("$privateRowNumber<$fromRowNumber AND");
        case false:
        case null:
          queryBuilder.writeln("$privateRowNumber>$fromRowNumber AND");
      }
      // This is not vulnerable to SQL injection, so no problem
    }
    queryBuilder.writeln("1=1"); // Default truthy condition for when there
    // is no other conditions given.

    if (limitRows != null) {
      queryBuilder.writeln("LIMIT $limitRows");
    }
    final rowsResult = await db.getAll(queryBuilder.toString());
    // print(queryBuilder.toString());
    final processedRows = <TableRow>[];
    final columnNames = rowsResult.columnNames
        .filter((t) => t != privateRowNumber)
        .toList();
    for (final row in rowsResult) {
      final TableRow currentRow;
      currentRow = TableRow(
        rowNumber: row[privateRowNumber] as int,
        rowData: columnNames.map((e) => row[e]).toList(),
      );
      processedRows.add(currentRow);
    }
    return DatabaseQueryResult(
      columnNames: columnNames,
      rows: processedRows,
      originalQuery: queryBuilder.toString(),
    );
  }

  Future<DatabaseQueryResult> executeRawQuery({
    required SqliteDatabase db,
    required String query,
  }) async {
    // TODO: do lazy query
    final rawQueryResult = await db.getAll(query);
    final processedRows = <TableRow>[];
    for (final row in rawQueryResult) {
      final TableRow currentRow = TableRow(
        rowNumber: row["rowid"] as int,
        rowData: row.entries
            .where((e) => e.key != "rowid")
            .map((e) => e.value)
            .toList(),
      );

      processedRows.add(currentRow);
    }

    return DatabaseQueryResult(
      columnNames: rawQueryResult.columnNames,
      rows: processedRows,
      originalQuery: query,
    );
  }
}
