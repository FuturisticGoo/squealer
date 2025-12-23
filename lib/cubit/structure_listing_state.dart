part of 'structure_listing_cubit.dart';

sealed class StructureListingState {
  const StructureListingState();
}

class StructureListingInitial extends StructureListingLoading {}

class StructureListingLoading extends StructureListingState {}

class StructureListingLoaded extends StructureListingState with EquatableMixin {
  final DatabaseObject databaseObject;
  final List<String> tables;
  final Map<String, DatabaseTable> tablesExpanded;
  final List<String> views;
  final Map<String, DatabaseView> viewsExpanded;
  const StructureListingLoaded({
    required this.databaseObject,
    required this.tables,
    required this.tablesExpanded,
    required this.views,
    required this.viewsExpanded,
  });
  @override
  List<Object?> get props => [
    databaseObject,
    tables,
    tablesExpanded,
    views,
    viewsExpanded,
  ];
}

class StructureListingError extends StructureListingState with EquatableMixin {
  final Object error;
  final StackTrace? stackTrace;
  const StructureListingError({required this.error, this.stackTrace});
  @override
  List<Object?> get props => [error, stackTrace];
}
