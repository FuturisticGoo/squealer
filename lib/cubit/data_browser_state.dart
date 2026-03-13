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

  const DataBrowserLoaded({
    required this.databaseObject,
    required this.tables,
    required this.views,
  });
  @override
  List<Object?> get props => [databaseObject, tables, views];
}

class QueryParams extends Equatable {
  final String relationName;
  final int? fromRowNumber;
  final int limitRows;
  final String? orderBy;
  final bool? isDescendingOrder;
  const QueryParams({
    required this.relationName,
    required this.fromRowNumber,
    required this.limitRows,
    required this.orderBy,
    required this.isDescendingOrder,
  });
  @override
  List<Object?> get props => [
    relationName,
    fromRowNumber,
    limitRows,
    orderBy,
    isDescendingOrder,
  ];
}

class DataBrowserLoadedRelation extends DataBrowserLoaded {
  final String selectedRelation;
  final DatabaseQueryResult selectedRelationResult;
  final bool isLast;
  final QueryParams queryParams;
  const DataBrowserLoadedRelation({
    required super.databaseObject,
    required super.tables,
    required super.views,
    required this.selectedRelationResult,
    required this.selectedRelation,
    required this.isLast,
    required this.queryParams,
  });
  @override
  List<Object?> get props => [
    databaseObject,
    tables,
    views,
    selectedRelationResult,
    selectedRelation,
    isLast,
    queryParams,
  ];
}

class DataBrowserError extends DataBrowserState with EquatableMixin {
  final Object error;
  final StackTrace? stackTrace;
  DataBrowserError({required this.error, this.stackTrace});
  @override
  List<Object?> get props => [error, stackTrace];
}
