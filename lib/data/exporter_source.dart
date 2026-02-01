import 'dart:async';
import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:fpdart/fpdart.dart';
import 'package:futuristicgoo_utils/futuristicgoo_utils.dart';
import 'package:squealer/core/constants.dart';
import 'package:squealer/core/entities/database_data_entities.dart';
import 'package:squealer/core/entities/export_format.dart';
import 'package:squealer/core/entities/export_progress_type.dart';
import 'package:squealer/core/entities/failure_success.dart';
import 'package:squealer/core/sql_writer.dart';
import 'package:squealer/data/exporter_repo.dart';

class ExporterRepoImpl implements ExporterRepo {
  final ExporterSource exporterSource;
  const ExporterRepoImpl({required this.exporterSource});
  @override
  Future<Either<Failure, Success>> exportQueryResult({
    required DatabaseQueryResult databaseQueryResult,
    required ExportFormat exportFormat,
  }) async {
    try {
      await exporterSource.exportQueryResult(
        databaseQueryResult: databaseQueryResult,
        exportFormat: exportFormat,
      );
      return Either.right(Success());
    } on NoSaveFilePickedException catch (error, stackTrace) {
      Loggify.getLogger?.severe(
        "NoSaveFilePickedException in exportTable",
        error,
        stackTrace,
      );
      return Either.left(
        FileNotPickedFailure(error: error, stackTrace: stackTrace),
      );
    } catch (error, stackTrace) {
      Loggify.getLogger?.severe(
        "Unknown error in exportTable",
        error,
        stackTrace,
      );
      return Either.left(GenericFailure(error: error, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, Success>> exportSql({required String sql}) async {
    try {
      await exporterSource.exportSql(sql: sql);
      return Either.right(Success());
    } on NoSaveFilePickedException catch (error, stackTrace) {
      Loggify.getLogger?.severe(
        "NoSaveFilePickedException in exportSql",
        error,
        stackTrace,
      );
      return Either.left(
        FileNotPickedFailure(error: error, stackTrace: stackTrace),
      );
    } catch (error, stackTrace) {
      Loggify.getLogger?.severe(
        "Unknown error in exportSql",
        error,
        stackTrace,
      );
      return Either.left(GenericFailure(error: error, stackTrace: stackTrace));
    }
  }
}

class ExporterSource {
  const ExporterSource();
  Future<void> exportQueryResult({
    required DatabaseQueryResult databaseQueryResult,
    required ExportFormat exportFormat,
  }) async {
    final globalProgressPipe = GlobalProgressPipe.instance;
    final appCacheDir = await getAppCacheDir();
    switch (exportFormat) {
      case CSVFormat(
        :final delimiter,
        :final storeColumnNames,
        :final stringDelimiter,
        :final endOfLine,
      ):
        final converter = ListToCsvConverter(
          fieldDelimiter: delimiter,
          textDelimiter: stringDelimiter,
          eol: endOfLine,
        );
        final outputFileName =
            "${DateTime.now().millisecondsSinceEpoch.toString()}.csv";
        final outputFile = await CrossFileWriter.openFileForWriting(
          fileName: outputFileName,
          cacheDirectory: appCacheDir,
        );
        final sc = StreamController<String>();
        final outCsvStringBuffer = StringBuffer();
        final outputBufferCompleter = Completer();
        sc.stream.listen(
          (event) async {
            outCsvStringBuffer.write(event);
          },
          onDone: () async {
            outputBufferCompleter.complete();
          },
        );
        final csvSink = converter.startChunkedConversion(sc.sink);
        if (storeColumnNames) {
          csvSink.add(databaseQueryResult.columnNames);
        }
        globalProgressPipe.addProgress(
          progressEvent: ExportingRowsUpdate(finished: 0, total: 2),
        );
        for (final rows in databaseQueryResult.rows) {
          csvSink.add(rows.rowData);
        }
        globalProgressPipe.addProgress(
          progressEvent: ExportingRowsUpdate(finished: 1, total: 2),
        );
        csvSink.close();
        await outputBufferCompleter.future;
        await outputFile.write(outCsvStringBuffer.toString());
        await outputFile.close();
        globalProgressPipe.addProgress(
          progressEvent: ExportingRowsUpdate(finished: 2, total: 2),
        );
        globalProgressPipe.addProgress(progressEvent: ExportingRowsFinished());

      case JSONFormat(
        :final storeQuery,
        :final storeColumnNames,
        :final indentation,
      ):
        final outputFileName =
            "${DateTime.now().millisecondsSinceEpoch.toString()}.json";
        final outputFile = await CrossFileWriter.openFileForWriting(
          fileName: outputFileName,
          cacheDirectory: appCacheDir,
        );
        final jsonMap = {
          jsonExportSquealerVersionKey: appVersion.toString(),
          if (storeQuery) jsonExportQueryKey: databaseQueryResult.originalQuery,
          if (storeColumnNames)
            jsonExportColumnsKey: databaseQueryResult.columnNames,
          jsonExportRowsKey: databaseQueryResult.rows
              .map((e) => e.rowData)
              .toList(),
        };
        final jsonEncoder = JsonEncoder.withIndent(" " * indentation);
        globalProgressPipe.addProgress(
          progressEvent: ExportingRowsUpdate(finished: 0, total: 2),
        );
        final jsonString = jsonEncoder.convert(jsonMap);
        globalProgressPipe.addProgress(
          progressEvent: ExportingRowsUpdate(finished: 1, total: 2),
        );
        await outputFile.write(jsonString);
        await outputFile.close();
        globalProgressPipe.addProgress(
          progressEvent: ExportingRowsUpdate(finished: 2, total: 2),
        );
        globalProgressPipe.addProgress(progressEvent: ExportingRowsFinished());
      case SQLFormat(:final storeSchema, :final storeData):
        if (databaseQueryResult.runOnSchema == null) {
          globalProgressPipe.addProgress(progressEvent: ExportingRowsError());
          globalProgressPipe.addProgress(
            progressEvent: ExportingRowsFinished(),
          );
          throw NoSchemaMentionedError();
        }
        final outputFileName =
            "${DateTime.now().millisecondsSinceEpoch.toString()}.sql";
        final outputFile = await CrossFileWriter.openFileForWriting(
          fileName: outputFileName,
          cacheDirectory: appCacheDir,
        );
        final outputBuffer = SimpleSQLiteCommandWriter();
        globalProgressPipe.addProgress(
          progressEvent: ExportingRowsUpdate(finished: 0, total: 2),
        );
        if (storeSchema) {
          outputBuffer.writeRawSql(databaseQueryResult.runOnSchema!.sql);
        }
        globalProgressPipe.addProgress(
          progressEvent: ExportingRowsUpdate(finished: 1, total: 2),
        );
        if (storeData) {
          for (final row in databaseQueryResult.rows) {
            outputBuffer.writeInsert(
              schemaName: databaseQueryResult.runOnSchema!.schemaName,
              row: row.rowData,
            );
          }
        }
        globalProgressPipe.addProgress(
          progressEvent: ExportingRowsUpdate(finished: 2, total: 2),
        );
        await outputFile.write(outputBuffer.toString());
        await outputFile.close();
        globalProgressPipe.addProgress(progressEvent: ExportingRowsFinished());
    }
  }

  Future<void> exportSql({required String sql}) async {
    final appCacheDir = await getAppCacheDir();
    final outputFileName =
        "${DateTime.now().millisecondsSinceEpoch.toString()}.sql";
    final outputFile = await CrossFileWriter.openFileForWriting(
      fileName: outputFileName,
      cacheDirectory: appCacheDir,
    );
    await outputFile.write(sql);
    await outputFile.close();
  }
}
