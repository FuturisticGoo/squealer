import 'package:fpdart/fpdart.dart';
import 'package:futuristicgoo_utils/futuristicgoo_utils.dart';
import 'package:squealer/core/entities/database_meta_entities.dart';
import 'package:squealer/core/entities/database_data_entities.dart';
import 'package:squealer/core/entities/failure_success.dart';
import 'package:squealer/data/viewer_repo.dart';
import 'package:sqlite_async/sqlite_async.dart';

class SQLiteViewerRepo implements ViewerRepo {
  final SQLite3AsyncSQLiteSource sqLite3AsyncSQLiteSource;
  const SQLiteViewerRepo({required this.sqLite3AsyncSQLiteSource});
  @override
  Future<Either<Failure, DatabaseObject>> openDatabase({
    required covariant SQLiteDatabaseInfo databaseInfo,
  }) async {
    try {
      final dbObject = await sqLite3AsyncSQLiteSource.openDatabase(
        dbPath: databaseInfo.databaseUri.toFilePath(),
      );
      return Either.right(dbObject);
    } catch (error, stackTrace) {
      Loggify.getLogger?.severe(
        "Error while opening database",
        error,
        stackTrace,
      );
      return Either.left(
        DatabaseOpenFailure(error: error, stackTrace: stackTrace),
      );
    }
  }

  @override
  Future<Either<Failure, Success>> closeDatabase({
    required covariant SQLite3AsyncDatabaseObject databaseObject,
  }) async {
    try {
      await databaseObject.db.close();
      Loggify.getLogger?.config("Closed database ${databaseObject.db}");
      return Either.right(Success());
    } catch (error, stackTrace) {
      Loggify.getLogger?.severe(
        "Error while closing database",
        error,
        stackTrace,
      );
      return Either.left(
        DatabaseCloseFailure(error: error, stackTrace: stackTrace),
      );
    }
  }

  @override
  Future<Either<Failure, List<String>>> listTableNames({
    required covariant SQLite3AsyncDatabaseObject databaseObject,
  }) async {
    try {
      final tableNames = await sqLite3AsyncSQLiteSource.listTableNames(
        db: databaseObject.db,
      );
      return Either.right(tableNames);
    } catch (error, stackTrace) {
      Loggify.getLogger?.severe(
        "Error while listing table names",
        error,
        stackTrace,
      );
      return Either.left(
        TableNameListingFailure(error: error, stackTrace: stackTrace),
      );
    }
  }

  @override
  Future<Either<Failure, DatabaseTable>> getTableInfo({
    required covariant SQLite3AsyncDatabaseObject databaseObject,
    required String tableName,
  }) async {
    try {
      final tableInfo = await sqLite3AsyncSQLiteSource.getTableInfo(
        db: databaseObject.db,
        tableName: tableName,
      );
      return Either.right(tableInfo);
    } on NoTableError catch (error, stackTrace) {
      Loggify.getLogger?.severe(
        "Only one row expected, got unexpected length",
        error,
        stackTrace,
      );
      return Either.left(NoTableFailure());
    } on InvalidSQLStatementError catch (error, stackTrace) {
      Loggify.getLogger?.severe(
        "Invalid SQL statement used in getTableInfo",
        error,
        stackTrace,
      );
      return Either.left(InvalidSQLStatementFailure());
    } catch (error, stackTrace) {
      Loggify.getLogger?.severe(
        "Unknown error in getTableInfo",
        error,
        stackTrace,
      );
      return Either.left(GenericFailure(error: error, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, List<String>>> listViewNames({
    required covariant SQLite3AsyncDatabaseObject databaseObject,
  }) async {
    try {
      final viewNames = await sqLite3AsyncSQLiteSource.listViewNames(
        db: databaseObject.db,
      );
      return Either.right(viewNames);
    } catch (error, stackTrace) {
      Loggify.getLogger?.severe(
        "Error while listing view names",
        error,
        stackTrace,
      );
      return Either.left(
        ViewNameListingFailure(error: error, stackTrace: stackTrace),
      );
    }
  }

  @override
  Future<Either<Failure, DatabaseView>> getViewInfo({
    required covariant SQLite3AsyncDatabaseObject databaseObject,
    required String viewName,
  }) async {
    try {
      final viewInfo = await sqLite3AsyncSQLiteSource.getViewInfo(
        db: databaseObject.db,
        viewName: viewName,
      );
      return Either.right(viewInfo);
    } on NoViewError catch (error, stackTrace) {
      Loggify.getLogger?.severe(
        "Only one row expected, got unexpected length",
        error,
        stackTrace,
      );
      return Either.left(NoViewFailure());
    } catch (error, stackTrace) {
      Loggify.getLogger?.severe(
        "Unknown error in getViewInfo",
        error,
        stackTrace,
      );
      return Either.left(GenericFailure(error: error, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, List<String>>> listIndexNames({
    required covariant SQLite3AsyncDatabaseObject databaseObject,
  }) async {
    try {
      final indexNames = await sqLite3AsyncSQLiteSource.listIndexNames(
        db: databaseObject.db,
      );
      return Either.right(indexNames);
    } catch (error, stackTrace) {
      Loggify.getLogger?.severe(
        "Unknown error in listIndexNames",
        error,
        stackTrace,
      );
      return Either.left(GenericFailure(error: error, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, DatabaseIndex>> getIndexInfo({
    required covariant SQLite3AsyncDatabaseObject databaseObject,
    required String indexName,
  }) async {
    try {
      final indexInfo = await sqLite3AsyncSQLiteSource.getIndexInfo(
        db: databaseObject.db,
        indexName: indexName,
      );
      return Either.right(indexInfo);
    } on NoIndexError catch (error, stackTrace) {
      Loggify.getLogger?.severe(
        "Only one row expected, got unexpected length",
        error,
        stackTrace,
      );
      return Either.left(NoIndexFailure());
    } catch (error, stackTrace) {
      Loggify.getLogger?.severe(
        "Unknown error in getIndexInfo",
        error,
        stackTrace,
      );
      return Either.left(GenericFailure(error: error, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, List<String>>> listTriggerNames({
    required covariant SQLite3AsyncDatabaseObject databaseObject,
  }) async {
    try {
      final triggerNames = await sqLite3AsyncSQLiteSource.listTriggerNames(
        db: databaseObject.db,
      );
      return Either.right(triggerNames);
    } catch (error, stackTrace) {
      Loggify.getLogger?.severe(
        "Unknown error in listTriggerNames",
        error,
        stackTrace,
      );
      return Either.left(GenericFailure(error: error, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, DatabaseTrigger>> getTriggerInfo({
    required covariant SQLite3AsyncDatabaseObject databaseObject,
    required String triggerName,
  }) async {
    try {
      final triggerInfo = await sqLite3AsyncSQLiteSource.getTriggerInfo(
        db: databaseObject.db,
        triggerName: triggerName,
      );
      return Either.right(triggerInfo);
    } on NoTriggerError catch (error, stackTrace) {
      Loggify.getLogger?.severe(
        "Only one row expected, got unexpected length",
        error,
        stackTrace,
      );
      return Either.left(NoTriggerFailure());
    } catch (error, stackTrace) {
      Loggify.getLogger?.severe(
        "Unknown error in getTriggerInfo",
        error,
        stackTrace,
      );
      return Either.left(GenericFailure(error: error, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, DatabaseQueryResult>> getRowsOfRelation({
    required covariant SQLite3AsyncDatabaseObject databaseObject,
    required String relationName,
    List<String>? columnsToSelect,
    String? orderBy,
    bool? isDescendingOrder,
    int? fromRowNumber,
    int? limitRows,
  }) async {
    try {
      final queryResult = await sqLite3AsyncSQLiteSource.getRowsOfRelation(
        db: databaseObject.db,
        relationName: relationName,
        columnsToSelect: columnsToSelect,
        fromRowNumber: fromRowNumber,
        limitRows: limitRows,
        orderBy: orderBy,
        isDescendingOrder: isDescendingOrder,
      );
      return Either.right(queryResult);
    } catch (error, stackTrace) {
      Loggify.getLogger?.severe(
        "Unknown error in getRowsOfRelation",
        error,
        stackTrace,
      );
      return Either.left(GenericFailure(error: error, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, DatabaseQueryResult>> executeRawQuery({
    required covariant SQLite3AsyncDatabaseObject databaseObject,
    required String query,
  }) async {
    try {
      final queryResult = await sqLite3AsyncSQLiteSource.executeRawQuery(
        db: databaseObject.db,
        query: query,
      );
      return Either.right(queryResult);
    } catch (error, stackTrace) {
      Loggify.getLogger?.severe(
        "Unknown error in executeRawQuery",
        error,
        stackTrace,
      );
      return Either.left(GenericFailure(error: error, stackTrace: stackTrace));
    }
  }
}

class SQLite3AsyncSQLiteSource {
  const SQLite3AsyncSQLiteSource();

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
  type='table'
ORDER BY
  name
    """);
    return tablesResult.map((row) => row["name"] as String).toList();
  }

  Future<List<TableColumn>> _getTableColumnInfo({
    required SqliteDatabase db,
    required String relationName,
  }) async {
    final tableInfoResult = await db.getAll(
      'PRAGMA table_info("$relationName")',
    );

    if (tableInfoResult.isEmpty) {
      throw NoTableError();
    }

    final indexListResult = await db.getAll(
      'PRAGMA index_list("$relationName")',
    );
    final uniqueIndexes = indexListResult.where((element) {
      return element["unique"] == 1;
    });
    final uniqueColumns = <String>{};
    for (final uniqueIndex in uniqueIndexes) {
      final indexName = uniqueIndex["name"] as String;
      final uniqueColumnResult = await db.get(
        'PRAGMA index_info("$indexName")',
      );
      uniqueColumns.add(uniqueColumnResult["name"]);
    }

    final tableColumns = <TableColumn>[];
    for (final row in tableInfoResult) {
      final tableColumn = TableColumn(
        columnName: row["name"] as String,
        dataType: row["type"] as String,
        notNullable: row["notnull"] == 1,
        isPrimaryKey: row["pk"] == 1,
        unique: uniqueColumns.contains(row["name"] as String),
        defaultValue: row["dflt_value"],
      );
      tableColumns.add(tableColumn);
    }
    return tableColumns;
  }

  Future<DatabaseSchema> _getSchemaInfo({
    required SqliteDatabase db,
    required String schemaName,
  }) async {
    final columns = await _getTableColumnInfo(db: db, relationName: schemaName);
    final schemaResult = await db.get(
      """ 
SELECT 
  sql, type
FROM 
  sqlite_master 
WHERE 
  ( type='table' OR type='view' )
AND
  name=?
    """,
      [schemaName],
    );
    if (schemaResult["type"] == "table") {
      return DatabaseTable(
        schemaName: schemaName,
        columns: columns,
        sql: schemaResult["sql"] as String,
      );
    } else if (schemaResult["type"] == "view") {
      return DatabaseView(
        schemaName: schemaName,
        columns: columns,
        sql: schemaResult["sql"] as String,
      );
    } else {
      throw UnsupportedError("Wrong type in sqlite_master");
    }
  }

  Future<DatabaseTable> getTableInfo({
    required SqliteDatabase db,
    required String tableName,
  }) async {
    return _getSchemaInfo(db: db, schemaName: tableName) as DatabaseTable;
  }

  Future<List<String>> listViewNames({required SqliteDatabase db}) async {
    final viewsResult = await db.getAll(""" 
SELECT
  name
FROM
  sqlite_master
WHERE
  type='view'
ORDER BY 
  name
    """);
    return viewsResult.map((row) => row["name"] as String).toList();
  }

  Future<DatabaseView> getViewInfo({
    required SqliteDatabase db,
    required String viewName,
  }) async {
    return _getSchemaInfo(db: db, schemaName: viewName) as DatabaseView;
  }

  Future<List<String>> listIndexNames({required SqliteDatabase db}) async {
    final indicesResult = await db.getAll(""" 
SELECT
  name
FROM
  sqlite_master
WHERE
  type='index'
ORDER BY 
  name
    """);
    return indicesResult.map((row) => row["name"] as String).toList();
  }

  Future<DatabaseIndex> getIndexInfo({
    required SqliteDatabase db,
    required String indexName,
  }) async {
    final indexInfoResult = await db.getAll(
      """ 
SELECT 
  tbl_name, sql
FROM 
  sqlite_master 
WHERE 
  type='index'
AND
  name=?
    """,
      [indexName],
    );
    if (indexInfoResult.length != 1) {
      throw NoIndexError();
    }

    final pragmaIndexInfoResult = await db.getAll(""" 
PRAGMA index_info("$indexName")
    """);
    if (indexInfoResult.isEmpty) {
      throw NoIndexError();
    }
    final createIndexQuery = indexInfoResult.single["sql"] as String?;
    final onTable = indexInfoResult.single["tbl_name"] as String;
    final onColumns = pragmaIndexInfoResult
        .map((e) => e["name"] as String)
        .toList();
    return DatabaseIndex(
      indexName: indexName,
      sql: createIndexQuery,
      onTable: onTable,
      onColumns: onColumns,
    );
  }

  Future<List<String>> listTriggerNames({required SqliteDatabase db}) async {
    final triggersResult = await db.getAll(""" 
SELECT
  name
FROM
  sqlite_master
WHERE
  type='trigger'
ORDER BY 
  name
    """);
    return triggersResult.map((row) => row["name"] as String).toList();
  }

  Future<DatabaseTrigger> getTriggerInfo({
    required SqliteDatabase db,
    required String triggerName,
  }) async {
    final triggerInfoResult = await db.getAll(
      """ 
SELECT 
  tbl_name, sql
FROM 
  sqlite_master 
WHERE 
  type='trigger'
AND
  name=?
    """,
      [triggerName],
    );
    if (triggerInfoResult.length != 1) {
      throw NoTriggerError();
    }
    final createTriggerQuery = triggerInfoResult.single["sql"] as String;
    final onTable = triggerInfoResult.single["tbl_name"] as String;
    return DatabaseTrigger(
      triggerName: triggerName,
      sql: createTriggerQuery,
      onTable: onTable,
    );
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
      runOnSchema: await _getSchemaInfo(db: db, schemaName: relationName),
    );
  }

  Future<DatabaseQueryResult> executeRawQuery({
    required SqliteDatabase db,
    required String query,
  }) async {
    // TODO: do lazy query
    final rawQueryResult = await db.execute(query);
    final processedRows = <TableRow>[];
    int rowIdx = 0;
    for (final row in rawQueryResult) {
      final TableRow currentRow = TableRow(
        rowNumber: rowIdx,
        rowData: row.values,
      );
      rowIdx++;
      processedRows.add(currentRow);
    }

    return DatabaseQueryResult(
      columnNames: rawQueryResult.columnNames,
      rows: processedRows,
      originalQuery: query,
      runOnSchema: null,
    );
  }
}
