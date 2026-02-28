import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:squealer/core/entities/database_data_entities.dart';
import 'package:squealer/core/entities/database_meta_entities.dart';
import 'package:squealer/core/entities/export_format.dart';
import 'package:squealer/core/entities/failure_success.dart';
import 'package:squealer/data/app_data_repo.dart';
import 'package:squealer/data/exporter_repo.dart';
import 'package:squealer/data/viewer_repo.dart';

part 'query_result_state.dart';

class QueryResultCubit extends Cubit<QueryResultState> {
  final ViewerRepo viewerRepo;
  final ExporterRepo exporterRepo;
  final AppDataRepo appDataRepo;
  QueryResultCubit({
    required this.viewerRepo,
    required this.exporterRepo,
    required this.appDataRepo,
  }) : super(QueryResultInitial()) {
    emit(QueryResultLoading());
  }

  Future<void> databaseOpened({required DatabaseObject databaseObject}) async {
    if (state is! QueryResultDatabaseLoaded) {
      emit(
        QueryResultDatabaseLoaded(
          databaseObject: databaseObject,
          savedStatements: [],
        ),
      );
      await _loadSQLStatements();
    }
  }

  Future<void> exportData({required ExportFormat exportFormat}) async {
    if (state case QueryResultExecuteResult(:final queryResult)) {
      final exportResult = await exporterRepo.exportQueryResult(
        databaseQueryResult: queryResult,
        exportFormat: exportFormat,
      );
    }
  }

  Future<void> exportSql() async {
    if (state case QueryResultExecuteResult(:final queryResult)) {
      await exporterRepo.exportSql(sql: queryResult.originalQuery);
    }
  }

  Future<void> _loadSQLStatements() async {
    final localState = state;
    if (localState case QueryResultDatabaseLoaded()) {
      final savedStatementsResult = await appDataRepo.getSavedSQLStatements();
      final List<String> savedStatements;
      switch (savedStatementsResult) {
        case Left():
          savedStatements = [];
        case Right(:final value):
          savedStatements = value;
      }
      emit(localState.updateSavedStatements(savedStatements));
    }
  }

  Future<void> saveSQLStatement({required String statement}) async {
    await appDataRepo.saveSQLStatement(sqlStatement: statement);
    await _loadSQLStatements();
  }

  Future<void> removeSQLStatement({required String statement}) async {
    await appDataRepo.removeSQLStatement(sqlStatement: statement);
    await _loadSQLStatements();
  }

  Future<void> executeQuery({required String sqlQuery}) async {
    if (state case QueryResultDatabaseLoaded(
      :final databaseObject,
      :final savedStatements,
    )) {
      emit(
        QueryResultExecuting(
          databaseObject: databaseObject,
          savedStatements: savedStatements,
        ),
      );
      final rawQueryResult = await viewerRepo.executeRawQuery(
        databaseObject: databaseObject,
        query: sqlQuery,
      );
      switch (rawQueryResult) {
        case Left(value: GenericFailure(:final stackTrace)):
          emit(
            QueryResultExecuteError(
              databaseObject: databaseObject,
              savedStatements: savedStatements,
              failure: rawQueryResult.value,
              stackTrace: stackTrace,
            ),
          );
        case Left(:final value):
          emit(
            QueryResultExecuteError(
              databaseObject: databaseObject,
              savedStatements: savedStatements,
              failure: value,
            ),
          );
        case Right(:final value):
          emit(
            QueryResultExecuteResult(
              databaseObject: databaseObject,
              savedStatements: savedStatements,
              queryResult: value,
            ),
          );
      }
    }
  }
}
