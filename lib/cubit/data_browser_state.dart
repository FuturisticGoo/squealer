part of 'data_browser_cubit.dart';

sealed class DataBrowserState {
  const DataBrowserState();
}

class DataBrowserInitial extends DataBrowserState {}

class DataBrowserLoading extends DataBrowserState {}

class DataBrowserLoaded extends DataBrowserState with EquatableMixin {
  final DatabaseObject databaseObject;
  final List<String> tables;
  final List<String> views;
  final String? selectedTable;
  final DatabaseQueryResult? selectedTableResult;
  const DataBrowserLoaded({
    required this.databaseObject,
    required this.tables,
    required this.views,
    required this.selectedTableResult,
    required this.selectedTable,
  });
  @override
  List<Object?> get props => [
    databaseObject,
    tables,
    views,
    selectedTableResult,
    selectedTable,
  ];
}

class DataBrowserError extends DataBrowserState with EquatableMixin {
  final Object error;
  final StackTrace? stackTrace;
  DataBrowserError({required this.error, this.stackTrace});
  @override
  List<Object?> get props => [error, stackTrace];
}
