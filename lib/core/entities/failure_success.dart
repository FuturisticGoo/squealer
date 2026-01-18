class FileNotPickedError extends Error {}

class NoTableError extends Error {}

class NoViewError extends Error {}

class InvalidSQLStatementError extends Error {}

class NoSettingsFoundError extends Error {}

class NoMetadataFoundError extends Error {}

class InvalidPathError extends Error {}

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

class NoSettingsFoundFailure extends Failure {}

class NoMetadataFoundFailure extends Failure {}

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

class InvalidPathFailure extends GenericFailure {
  InvalidPathFailure({required super.error, required super.stackTrace});
}

class FileNotPickedFailure extends GenericFailure {
  FileNotPickedFailure({required super.error, required super.stackTrace});
}

class NoTableFailure extends Failure {}

class InvalidSQLStatementFailure extends Failure {}

class NoViewFailure extends Failure {}

class Success {}
