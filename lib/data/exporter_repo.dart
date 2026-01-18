import 'package:fpdart/fpdart.dart';
import 'package:squealer/core/entities/database_data_entities.dart';
import 'package:squealer/core/entities/export_format.dart';
import 'package:squealer/core/entities/failure_success.dart';

abstract class ExporterRepo {
  Future<Either<Failure, Success>> exportTable({
    required DatabaseQueryResult databaseQueryResult,
    required ExportFormat exportFormat,
  });
  Future<Either<Failure, Success>> exportSql({required String sql});
}
