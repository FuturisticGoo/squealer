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
      emit(
        StructureListingLoaded(
          databaseObject: databaseObject,
          tables: [],
          tablesExpanded: {},
          views: [],
          viewsExpanded: {},
        ),
      );
    }
  }

  Future<void> loadTableAndViewNames() async {
    final localState = state;
    if (localState case StructureListingLoaded(:final databaseObject)) {
      emit(
        StructureListingLoading(
          structureLoadingPart: LoadingRelationNames(previousState: localState),
        ),
      );
      List<String> tables;
      List<String> views;
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
      emit(
        StructureListingLoaded(
          databaseObject: databaseObject,
          tables: tables,
          tablesExpanded: {},
          views: views,
          viewsExpanded: {},
        ),
      );
    }
  }

  Future<void> getTableDetails({required String tableName}) async {
    final localState = state;
    if (localState case StructureListingLoaded(
      :final databaseObject,
      :final tables,
      :final tablesExpanded,
      :final views,
      :final viewsExpanded,
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
            StructureListingLoaded(
              databaseObject: databaseObject,
              tables: tables,
              tablesExpanded: {...tablesExpanded, tableName: tableDetails},
              views: views,
              viewsExpanded: viewsExpanded,
            ),
          );
      }
    }
  }

  Future<void> hideTableDetails({required String tableName}) async {
    if (state case StructureListingLoaded(
      :final databaseObject,
      :final tables,
      :final tablesExpanded,
      :final views,
      :final viewsExpanded,
    )) {
      tablesExpanded.remove(tableName);
      emit(
        StructureListingLoaded(
          databaseObject: databaseObject,
          tables: tables,
          tablesExpanded: tablesExpanded,
          views: views,
          viewsExpanded: viewsExpanded,
        ),
      );
    }
  }

  Future<void> getViewDetails({required String viewName}) async {
    final localState = state;
    if (localState case StructureListingLoaded(
      :final databaseObject,
      :final tables,
      :final tablesExpanded,
      :final views,
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
            StructureListingLoaded(
              databaseObject: databaseObject,
              tables: tables,
              tablesExpanded: tablesExpanded,
              views: views,
              viewsExpanded: {...viewsExpanded, viewName: viewDetails},
            ),
          );
      }
    }
  }

  Future<void> hideViewDetails({required String viewName}) async {
    if (state case StructureListingLoaded(
      :final databaseObject,
      :final tables,
      :final tablesExpanded,
      :final views,
      :final viewsExpanded,
    )) {
      viewsExpanded.remove(viewName);
      emit(
        StructureListingLoaded(
          databaseObject: databaseObject,
          tables: tables,
          tablesExpanded: tablesExpanded,
          views: views,
          viewsExpanded: viewsExpanded,
        ),
      );
    }
  }
}
