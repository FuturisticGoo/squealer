import 'package:fpdart/fpdart.dart';
import 'package:squealer/core/entities/database_meta_entities.dart';
import 'package:squealer/core/entities/database_data_entities.dart';
import 'package:squealer/core/entities/failure_success.dart';

abstract class ViewerRepo {
  Future<Either<Failure, DatabaseObject>> openDatabase({
    required DatabaseInfo databaseInfo,
  });
  Future<Either<Failure, Success>> closeDatabase({
    required DatabaseObject databaseObject,
  });
  Future<Either<Failure, List<String>>> listTableNames({
    required DatabaseObject databaseObject,
  });
  Future<Either<Failure, DatabaseTable>> getTableInfo({
    required DatabaseObject databaseObject,
    required String tableName,
  });
  Future<Either<Failure, List<String>>> listViewNames({
    required DatabaseObject databaseObject,
  });
  Future<Either<Failure, DatabaseView>> getViewInfo({
    required DatabaseObject databaseObject,
    required String viewName,
  });

  Future<Either<Failure, DatabaseQueryResult>> getRowsOfRelation({
    required DatabaseObject databaseObject,
    required String relationName,
    List<String>? columnsToSelect,
    String? orderBy,
    bool? isDescendingOrder,
    int? fromRowNumber,
    int? limitRows,
  });

  Future<Either<Failure, DatabaseQueryResult>> executeRawQuery({
    required DatabaseObject databaseObject,
    required String query,
  });
}
