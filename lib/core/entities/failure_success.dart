class FileNotPickedError extends Error {}

class NotSingleTableError extends Error {}

class NotSingleViewError extends Error {}

class InvalidSQLStatementError extends Error {}

class Failure {
  const Failure();
}

class GenericFailure extends Failure {
  final Object error;
  final StackTrace stackTrace;
  const GenericFailure({required this.error, required this.stackTrace});
}

class DatabaseOpenFailure extends Failure {
  final Object error;
  const DatabaseOpenFailure({required this.error});
}

class DatabaseCloseFailure extends Failure {
  final Object error;
  const DatabaseCloseFailure({required this.error});
}

class FileNotPickedFailure extends Failure {}

class NotSingleTableFailure extends Failure {}

class InvalidSQLStatementFailure extends Failure {}

class NotSingleViewFailure extends Failure {}

class Success {}
