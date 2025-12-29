class FileNotPickedError extends Error {}

class NotSingleTableError extends Error {}

class NotSingleViewError extends Error {}

class InvalidSQLStatementError extends Error {}

class Failure {
  const Failure();
  @override
  String toString() => runtimeType.toString();
}

class GenericFailure extends Failure {
  final Object error;
  final StackTrace stackTrace;
  const GenericFailure({required this.error, required this.stackTrace});
}

class DatabaseOpenFailure extends GenericFailure {
  const DatabaseOpenFailure({required super.error, required super.stackTrace});
}

class DatabaseCloseFailure extends GenericFailure {
  const DatabaseCloseFailure({required super.error, required super.stackTrace});
}

class TableNameListingFailure extends GenericFailure {
  TableNameListingFailure({required super.error, required super.stackTrace});
}

class ViewNameListingFailure extends GenericFailure {
  ViewNameListingFailure({required super.error, required super.stackTrace});
}

class FileNotPickedFailure extends Failure {}

class NotSingleTableFailure extends Failure {}

class InvalidSQLStatementFailure extends Failure {}

class NotSingleViewFailure extends Failure {}

class Success {}
