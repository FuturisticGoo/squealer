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
  final List<String> indices;
  final Map<String, DatabaseIndex> indicesExpanded;
  final List<String> triggers;
  final Map<String, DatabaseTrigger> triggersExpanded;
  const StructureListingLoaded({
    required this.databaseObject,
    required this.tables,
    required this.tablesExpanded,
    required this.views,
    required this.viewsExpanded,
    required this.indices,
    required this.indicesExpanded,
    required this.triggers,
    required this.triggersExpanded,
  });
  @override
  List<Object?> get props => [
    databaseObject,
    tables,
    tablesExpanded,
    views,
    viewsExpanded,
    indices,
    indicesExpanded,
    triggers,
    triggersExpanded,
  ];
  StructureListingLoaded copyWith({
    DatabaseObject? databaseObject,
    List<String>? tables,
    Map<String, DatabaseTable>? tablesExpanded,
    List<String>? views,
    Map<String, DatabaseView>? viewsExpanded,
    List<String>? indices,
    Map<String, DatabaseIndex>? indicesExpanded,
    List<String>? triggers,
    Map<String, DatabaseTrigger>? triggersExpanded,
  }) {
    return StructureListingLoaded(
      databaseObject: databaseObject ?? this.databaseObject,
      tables: tables ?? this.tables,
      tablesExpanded: tablesExpanded ?? this.tablesExpanded,
      views: views ?? this.views,
      viewsExpanded: viewsExpanded ?? this.viewsExpanded,
      indices: indices ?? this.indices,
      indicesExpanded: indicesExpanded ?? this.indicesExpanded,
      triggers: triggers ?? this.triggers,
      triggersExpanded: triggersExpanded ?? this.triggersExpanded,
    );
  }

  factory StructureListingLoaded.initialEmpty({
    required DatabaseObject databaseObject,
  }) => StructureListingLoaded(
    databaseObject: databaseObject,
    tables: [],
    tablesExpanded: {},
    views: [],
    viewsExpanded: {},
    indices: [],
    indicesExpanded: {},
    triggers: [],
    triggersExpanded: {},
  );
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

class LoadingIndexDetails extends StructureLoadingPart {
  final String indexName;
  const LoadingIndexDetails({
    required super.previousState,
    required this.indexName,
  });
}

class LoadingTriggerDetails extends StructureLoadingPart {
  final String triggerName;
  const LoadingTriggerDetails({
    required super.previousState,
    required this.triggerName,
  });
}
