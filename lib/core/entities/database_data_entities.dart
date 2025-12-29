import 'package:equatable/equatable.dart';

class DatabaseQueryResult extends Equatable {
  final List<String> columnNames;
  final List<TableRow> rows;
  final String? originalQuery;
  const DatabaseQueryResult({
    required this.columnNames,
    required this.rows,
    this.originalQuery,
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
  final String sql;
  const DatabaseView({required this.viewName, required this.sql});
  @override
  List<Object?> get props => [viewName, sql];
}

class TableColumn extends Equatable {
  final String columnName;
  final String dataType;
  final bool? notNullable;
  final bool? unique;
  final bool? isPrimaryKey;
  const TableColumn({
    required this.columnName,
    required this.dataType,
    this.notNullable,
    this.unique,
    this.isPrimaryKey,
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
