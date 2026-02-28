import 'package:fpdart/fpdart.dart';
import 'package:squealer/core/entities/database_meta_entities.dart';
import 'package:squealer/core/entities/failure_success.dart';

abstract class AppDataRepo {
  Future<Either<Failure, List<DatabaseInfo>>> getRecentDatabases();
  Future<Either<Failure, Success>> saveDatabaseToRecent({
    required DatabaseInfo databaseInfo,
  });
  Future<Either<Failure, Success>> removeDatabaseFromRecent({
    required DatabaseInfo? databaseInfo,
  });

  Future<Either<Failure, List<String>>> getSavedSQLStatements();
  Future<Either<Failure, Success>> saveSQLStatement({
    required String sqlStatement,
  });
  Future<Either<Failure, Success>> removeSQLStatement({
    required String? sqlStatement,
  });
}
