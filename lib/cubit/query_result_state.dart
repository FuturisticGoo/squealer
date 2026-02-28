part of 'query_result_cubit.dart';

sealed class QueryResultState extends Equatable {
  const QueryResultState();
  @override
  List<Object?> get props => [];
}

class QueryResultInitial extends QueryResultState {}

class QueryResultLoading extends QueryResultState {}

class QueryResultDatabaseLoaded extends QueryResultState {
  final DatabaseObject databaseObject;
  final List<String> savedStatements;
  const QueryResultDatabaseLoaded({
    required this.databaseObject,
    required this.savedStatements,
  });
  @override
  List<Object?> get props => [databaseObject, savedStatements];
  QueryResultDatabaseLoaded updateSavedStatements(
    List<String> newSavedStatments,
  ) {
    switch (this) {
      case QueryResultExecuting(:final databaseObject):
        return QueryResultExecuting(
          databaseObject: databaseObject,
          savedStatements: newSavedStatments,
        );
      case QueryResultExecuteResult(:final databaseObject, :final queryResult):
        return QueryResultExecuteResult(
          databaseObject: databaseObject,
          savedStatements: newSavedStatments,
          queryResult: queryResult,
        );
      case QueryResultExecuteError(
        :final databaseObject,
        :final failure,
        :final stackTrace,
      ):
        return QueryResultExecuteError(
          databaseObject: databaseObject,
          failure: failure,
          stackTrace: stackTrace,
          savedStatements: newSavedStatments,
        );
      case QueryResultDatabaseLoaded(:final databaseObject):
        return QueryResultDatabaseLoaded(
          databaseObject: databaseObject,
          savedStatements: newSavedStatments,
        );
    }
  }
}

class QueryResultExecuting extends QueryResultDatabaseLoaded {
  const QueryResultExecuting({
    required super.databaseObject,
    required super.savedStatements,
  });
}

class QueryResultExecuteResult extends QueryResultDatabaseLoaded {
  final DatabaseQueryResult queryResult;
  const QueryResultExecuteResult({
    required super.databaseObject,
    required super.savedStatements,
    required this.queryResult,
  });
  @override
  List<Object?> get props => [super.props, queryResult];
}

class QueryResultExecuteError extends QueryResultDatabaseLoaded {
  final Failure failure;
  final StackTrace? stackTrace;
  const QueryResultExecuteError({
    required super.databaseObject,
    required super.savedStatements,
    required this.failure,
    this.stackTrace,
  });
  @override
  List<Object?> get props => [super.props, failure, stackTrace];
}

class QueryResultError extends QueryResultState {}
