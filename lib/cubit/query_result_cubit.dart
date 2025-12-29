import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:squealer/core/entities/database_data_entities.dart';
import 'package:squealer/core/entities/database_meta_entities.dart';
import 'package:squealer/core/entities/failure_success.dart';
import 'package:squealer/data/viewer_repo.dart';

part 'query_result_state.dart';

class QueryResultCubit extends Cubit<QueryResultState> {
  final ViewerRepo viewerRepo;
  QueryResultCubit({required this.viewerRepo}) : super(QueryResultInitial()) {
    emit(QueryResultLoading());
  }

  Future<void> databaseOpened({required DatabaseObject databaseObject}) async {
    if (state is! QueryResultDatabaseLoaded) {
      emit(QueryResultDatabaseLoaded(databaseObject: databaseObject));
    }
  }

  Future<void> executeQuery({required String sqlQuery}) async {
    if (state case QueryResultDatabaseLoaded(:final databaseObject)) {
      emit(QueryResultExecuting(databaseObject: databaseObject));
      final rawQueryResult = await viewerRepo.executeRawQuery(
        databaseObject: databaseObject,
        query: sqlQuery,
      );
      switch (rawQueryResult) {
        case Left(value: GenericFailure(:final stackTrace)):
          emit(
            QueryResultExecuteError(
              databaseObject: databaseObject,
              failure: rawQueryResult.value,
              stackTrace: stackTrace,
            ),
          );
        case Left(:final value):
          emit(
            QueryResultExecuteError(
              databaseObject: databaseObject,
              failure: value,
            ),
          );
        case Right(:final value):
          emit(
            QueryResultExecuteResult(
              databaseObject: databaseObject,
              queryResult: value,
            ),
          );
      }
    }
  }
}
