part of 'structure_listing_cubit.dart';

sealed class StructureListingState {
  const StructureListingState();
}

class StructureListingInitial extends StructureListingState {}

class StructureListingLoading extends StructureListingState
    with EquatableMixin {
  // Which part specifically are we loading, to show the progress bar
  final StructureLoadingPart? structureLoadingPart;
  const StructureListingLoading({this.structureLoadingPart});
  @override
  List<Object?> get props => [structureLoadingPart];
}

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

sealed class StructureLoadingPart extends Equatable {
  final StructureListingLoaded previousState;
  const StructureLoadingPart({required this.previousState});
  @override
  List<Object?> get props => [previousState];
}

class LoadingRelationNames extends StructureLoadingPart {
  const LoadingRelationNames({required super.previousState});
}

class LoadingTableDetails extends StructureLoadingPart {
  final String tableName;
  const LoadingTableDetails({
    required super.previousState,
    required this.tableName,
  });
}

class LoadingViewDetails extends StructureLoadingPart {
  final String viewName;
  const LoadingViewDetails({
    required super.previousState,
    required this.viewName,
  });
}
