import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:squealer/core/entities/database_data_entities.dart';
import 'package:squealer/core/entities/database_meta_entities.dart';
import 'package:squealer/data/viewer_repo.dart';

part 'structure_listing_state.dart';

class StructureListingCubit extends Cubit<StructureListingState> {
  final ViewerRepo viewerRepo;
  StructureListingCubit({required this.viewerRepo})
    : super(StructureListingInitial()) {
    emit(StructureListingLoading());
  }

  Future<void> databaseOpened({required DatabaseObject databaseObject}) async {
    if (state is! StructureListingLoaded) {
      emit(StructureListingLoaded.initialEmpty(databaseObject: databaseObject));
    }
  }

  Future<void> loadAllSchemaNames() async {
    final localState = state;
    if (localState case StructureListingLoaded(:final databaseObject)) {
      emit(
        StructureListingLoading(
          structureLoadingPart: LoadingRelationNames(previousState: localState),
        ),
      );
      List<String> tables;
      List<String> views;
      List<String> indices;
      List<String> triggers;
      final tableNamesResult = await viewerRepo.listTableNames(
        databaseObject: databaseObject,
      );
      switch (tableNamesResult) {
        case Left(value: final error):
          emit(StructureListingError(error: error));
          return;
        case Right(value: final tableNames):
          tables = tableNames;
      }

      final viewNamesResult = await viewerRepo.listViewNames(
        databaseObject: databaseObject,
      );
      switch (viewNamesResult) {
        case Left(value: final error):
          emit(StructureListingError(error: error));
          return;
        case Right(value: final viewNames):
          views = viewNames;
      }

      final indexNamesResult = await viewerRepo.listIndexNames(
        databaseObject: databaseObject,
      );
      switch (indexNamesResult) {
        case Left(value: final error):
          emit(StructureListingError(error: error));
          return;
        case Right(value: final indexNames):
          indices = indexNames;
      }

      final triggerNamesResult = await viewerRepo.listTriggerNames(
        databaseObject: databaseObject,
      );
      switch (triggerNamesResult) {
        case Left(value: final error):
          emit(StructureListingError(error: error));
          return;
        case Right(value: final triggerNames):
          triggers = triggerNames;
      }

      emit(
        StructureListingLoaded.initialEmpty(
          databaseObject: databaseObject,
        ).copyWith(
          tables: tables,
          views: views,
          indices: indices,
          triggers: triggers,
        ),
      );
    }
  }

  Future<void> getTableDetails({required String tableName}) async {
    final localState = state;
    if (localState case StructureListingLoaded(
      :final databaseObject,
      :final tablesExpanded,
    )) {
      emit(
        StructureListingLoading(
          structureLoadingPart: LoadingTableDetails(
            previousState: localState,
            tableName: tableName,
          ),
        ),
      );
      final tableDetailsResult = await viewerRepo.getTableInfo(
        databaseObject: databaseObject,
        tableName: tableName,
      );
      switch (tableDetailsResult) {
        case Left(value: final error):
          emit(StructureListingError(error: error));
        case Right(value: final tableDetails):
          emit(
            localState.copyWith(
              tablesExpanded: {...tablesExpanded, tableName: tableDetails},
            ),
          );
      }
    }
  }

  Future<void> hideTableDetails({required String tableName}) async {
    final localState = state;
    if (localState case StructureListingLoaded(:final tablesExpanded)) {
      tablesExpanded.remove(tableName);
      emit(localState.copyWith(tablesExpanded: tablesExpanded));
    }
  }

  Future<void> getViewDetails({required String viewName}) async {
    final localState = state;
    if (localState case StructureListingLoaded(
      :final databaseObject,
      :final viewsExpanded,
    )) {
      emit(
        StructureListingLoading(
          structureLoadingPart: LoadingViewDetails(
            previousState: localState,
            viewName: viewName,
          ),
        ),
      );
      final viewDetailsResult = await viewerRepo.getViewInfo(
        databaseObject: databaseObject,
        viewName: viewName,
      );
      switch (viewDetailsResult) {
        case Left(value: final error):
          emit(StructureListingError(error: error));
        case Right(value: final viewDetails):
          emit(
            localState.copyWith(
              viewsExpanded: {...viewsExpanded, viewName: viewDetails},
            ),
          );
      }
    }
  }

  Future<void> hideViewDetails({required String viewName}) async {
    final localState = state;
    if (localState case StructureListingLoaded(
      :final viewsExpanded,
    )) {
      viewsExpanded.remove(viewName);
      emit(
        localState.copyWith(viewsExpanded: viewsExpanded));
    }
  }

  Future<void> getIndexDetails({required String indexName}) async {
    final localState = state;
    if (localState case StructureListingLoaded(
      :final databaseObject,
      :final indicesExpanded,
    )) {
      emit(
        StructureListingLoading(
          structureLoadingPart: LoadingIndexDetails(
            previousState: localState,
            indexName: indexName,
          ),
        ),
      );
      final indexDetailsResult = await viewerRepo.getIndexInfo(
        databaseObject: databaseObject,
        indexName: indexName,
      );
      switch (indexDetailsResult) {
        case Left(value: final error):
          emit(StructureListingError(error: error));
        case Right(value: final indexDetails):
          emit(
            localState.copyWith(
              indicesExpanded: {...indicesExpanded, indexName: indexDetails},
            ),
          );
      }
    }
  }

  Future<void> hideIndexDetails({required String indexName}) async {
    final localState = state;
    if (localState case StructureListingLoaded(:final indicesExpanded)) {
      indicesExpanded.remove(indexName);
      emit(localState.copyWith(indicesExpanded: indicesExpanded));
    }
  }

  Future<void> getTriggerDetails({required String triggerName}) async {
    final localState = state;
    if (localState case StructureListingLoaded(
      :final databaseObject,
      :final triggersExpanded,
    )) {
      emit(
        StructureListingLoading(
          structureLoadingPart: LoadingTriggerDetails(
            previousState: localState,
            triggerName: triggerName,
          ),
        ),
      );
      final triggerDetailsResult = await viewerRepo.getTriggerInfo(
        databaseObject: databaseObject,
        triggerName: triggerName,
      );
      switch (triggerDetailsResult) {
        case Left(value: final error):
          emit(StructureListingError(error: error));
        case Right(value: final triggerDetails):
          emit(
            localState.copyWith(
              triggersExpanded: {
                ...triggersExpanded,
                triggerName: triggerDetails,
              },
            ),
          );
      }
    }
  }

  Future<void> hideTriggerDetails({required String triggerName}) async {
    final localState = state;
    if (localState case StructureListingLoaded(
      triggersExpanded: final triggersExpanded,
    )) {
      triggersExpanded.remove(triggerName);
      emit(localState.copyWith(triggersExpanded: triggersExpanded));
    }
  }

}
