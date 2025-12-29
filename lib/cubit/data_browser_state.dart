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
  List<Object?> get props => [
    databaseObject,
    tables,
    views,
  ];
}

class DataBrowserLoadedRelation extends DataBrowserLoaded {
  final String selectedRelation;
  final DatabaseQueryResult selectedRelationResult;
  final bool isLast;
  const DataBrowserLoadedRelation({
    required super.databaseObject,
    required super.tables,
    required super.views,
    required this.selectedRelationResult,
    required this.selectedRelation,
    required this.isLast,
  });
  @override
  List<Object?> get props => [
    databaseObject,
    tables,
    views,
    selectedRelationResult,
    selectedRelation,
    isLast,
  ];
}
class DataBrowserError extends DataBrowserState with EquatableMixin {
  final Object error;
  final StackTrace? stackTrace;
  DataBrowserError({required this.error, this.stackTrace});
  @override
  List<Object?> get props => [error, stackTrace];
}
