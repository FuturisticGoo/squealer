import 'package:equatable/equatable.dart';

class DatabaseQueryResult extends Equatable {
  final List<String> columnNames;
  final List<TableRow> rows;
  final String originalQuery;
  const DatabaseQueryResult({
    required this.columnNames,
    required this.rows,
    required this.originalQuery,
  });
  @override
  List<Object?> get props => [columnNames, rows, originalQuery];
}

class DatabaseTable extends Equatable {
  final String tableName;
  final List<TableColumn> columns;
  final String sql;
  const DatabaseTable({
    required this.tableName,
    required this.columns,
    required this.sql,
  });
  @override
  List<Object?> get props => [tableName, columns, sql];
}

class DatabaseView extends Equatable {
  final String viewName;
  final List<TableColumn> columns;
  final String sql;
  const DatabaseView({
    required this.viewName,
    required this.sql,
    required this.columns,
  });
  @override
  List<Object?> get props => [viewName, sql, columns];
}

class DatabaseIndex extends Equatable {
  final String indexName;
  final String onTable;
  final List<String> onColumns;
  final String? sql;
  const DatabaseIndex({
    required this.indexName,
    required this.onTable,
    required this.onColumns,
    required this.sql,
  });
  @override
  List<Object?> get props => [indexName, onTable, onColumns, sql];
}

class DatabaseTrigger extends Equatable {
  final String triggerName;
  final String onTable;
  final String sql;
  const DatabaseTrigger({
    required this.triggerName,
    required this.onTable,
    required this.sql,
  });
  @override
  List<Object?> get props => [triggerName, onTable, sql];
}

class TableColumn extends Equatable {
  final String columnName;
  final String dataType;
  final bool notNullable;
  final bool unique;
  final bool isPrimaryKey;
  final dynamic defaultValue;
  const TableColumn({
    required this.columnName,
    required this.dataType,
    required this.notNullable,
    required this.unique,
    required this.isPrimaryKey,
    required this.defaultValue,
  });
  @override
  List<Object?> get props => [
    columnName,
    dataType,
    notNullable,
    unique,
    isPrimaryKey,
  ];
}

class TableRow extends Equatable {
  final int rowNumber;
  final List<Object?> rowData;
  const TableRow({required this.rowNumber, required this.rowData});
  @override
  List<Object?> get props => [rowNumber, rowData];
}
