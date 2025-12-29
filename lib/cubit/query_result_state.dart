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
  const QueryResultDatabaseLoaded({required this.databaseObject});
  @override
  List<Object?> get props => [databaseObject];
}

class QueryResultExecuting extends QueryResultDatabaseLoaded {
  const QueryResultExecuting({required super.databaseObject});
}

class QueryResultExecuteResult extends QueryResultDatabaseLoaded {
  final DatabaseQueryResult queryResult;
  const QueryResultExecuteResult({
    required super.databaseObject,
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
    required this.failure,
    this.stackTrace,
  });
  @override
  List<Object?> get props => [super.props, failure, stackTrace];
}

class QueryResultError extends QueryResultState {}
