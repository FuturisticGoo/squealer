import 'package:fpdart/fpdart.dart';
import 'package:squealer/core/entities/database_meta_entities.dart';
import 'package:squealer/core/entities/failure_success.dart';
import 'package:squealer/core/entities/saved_statements.dart';

abstract class AppDataRepo {
  Future<Either<Failure, List<DatabaseInfo>>> getRecentDatabases();
  Future<Either<Failure, Success>> saveDatabaseToRecent({
    required DatabaseInfo databaseInfo,
  });
  Future<Either<Failure, Success>> removeDatabaseFromRecent({
    required DatabaseInfo? databaseInfo,
  });

  Future<Either<Failure, List<SavedStatement>>> getSavedSQLStatements();
  Future<Either<Failure, Success>> saveSQLStatement({
    required String name,
    required String statement,
  });
  Future<Either<Failure, Success>> removeSQLStatement({
    required SavedStatement? savedStatement,
  });
}
