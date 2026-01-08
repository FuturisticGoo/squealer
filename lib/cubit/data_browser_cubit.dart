import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:squealer/core/entities/database_data_entities.dart';
import 'package:squealer/core/entities/database_meta_entities.dart';
import 'package:squealer/data/viewer_repo.dart';

part 'data_browser_state.dart';


class DataBrowserCubit extends Cubit<DataBrowserState> {
  final ViewerRepo viewerRepo;
  DataBrowserCubit({required this.viewerRepo}) : super(DataBrowserInitial()) {
    emit(DataBrowserLoading());
  }

  Future<void> databaseOpened({required DatabaseObject databaseObject}) async {
    if (state is! DataBrowserLoaded) {
      emit(
        DataBrowserLoaded(
          databaseObject: databaseObject,
          tables: [],
          views: [],
        ),
      );
    }
  }

  Future<void> loadTableAndViewNames() async {
    if (state case DataBrowserLoaded(:final databaseObject)) {
      List<String> tables;
      List<String> views;
      final tableNamesResult = await viewerRepo.listTableNames(
        databaseObject: databaseObject,
      );
      switch (tableNamesResult) {
        case Left(value: final error):
          emit(DataBrowserError(error: error));
          return;
        case Right(value: final tableNames):
          tables = tableNames;
      }

      final viewNamesResult = await viewerRepo.listViewNames(
        databaseObject: databaseObject,
      );
      switch (viewNamesResult) {
        case Left(value: final error):
          emit(DataBrowserError(error: error));
          return;
        case Right(value: final viewNames):
          views = viewNames;
      }
      emit(
        DataBrowserLoaded(
          databaseObject: databaseObject,
          tables: tables,
          views: views,

        ),
      );
    }
  }

  Future<void> showDataOfRelation({
    required String relationName,
    int? fromRowNumber,
    String? orderBy,
    bool? isDescendingOrder,
    required int fetchCount,
  }) async {
    if (state case DataBrowserLoaded(
      :final databaseObject,
      :final tables,
      :final views,
    )) {
      final dataQueryResult = await viewerRepo.getRowsOfRelation(
        databaseObject: databaseObject,
        relationName: relationName,
        fromRowNumber: fromRowNumber,
        limitRows: fetchCount,
        orderBy: orderBy,
        isDescendingOrder: isDescendingOrder,
      );
      switch (dataQueryResult) {
        case Left(value: final error):
          emit(DataBrowserError(error: error));
        case Right(value: final dataQueryResult):
          emit(
            DataBrowserLoadedRelation(
              databaseObject: databaseObject,
              tables: tables,
              views: views,
              selectedRelationResult: dataQueryResult,
              selectedRelation: relationName,
              isLast: dataQueryResult.rows.length < fetchCount,
            ),
          );
      }
    }
  }
}
