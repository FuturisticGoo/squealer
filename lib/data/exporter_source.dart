import 'dart:async';
import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:fpdart/fpdart.dart';
import 'package:futuristicgoo_utils/futuristicgoo_utils.dart';
import 'package:squealer/core/constants.dart';
import 'package:squealer/core/entities/database_data_entities.dart';
import 'package:squealer/core/entities/export_format.dart';
import 'package:squealer/core/entities/failure_success.dart';
import 'package:squealer/data/exporter_repo.dart';

class ExporterRepoImpl implements ExporterRepo {
  final ExporterSource exporterSource;
  const ExporterRepoImpl({required this.exporterSource});
  @override
  Future<Either<Failure, Success>> exportTable({
    required DatabaseQueryResult databaseQueryResult,
    required ExportFormat exportFormat,
  }) async {
    try {
      await exporterSource.exportTable(
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
  Future<void> exportTable({
    required DatabaseQueryResult databaseQueryResult,
    required ExportFormat exportFormat,
  }) async {
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
        final appCacheDir = await getAppCacheDir();
        final outputFileName =
            "${DateTime.now().millisecondsSinceEpoch.toString()}.csv";
        final outputFile = await CrossFileWriter.openFileForWriting(
          fileName: outputFileName,
          cacheDirectory: appCacheDir,
        );
        final sc = StreamController<String>();
        final fileWriterCompleter = Completer();
        sc.stream.listen(
          (event) async {
            await outputFile.write(event);
          },
          onDone: () async {
            await outputFile.close();
            fileWriterCompleter.complete();
          },
        );
        final csvSink = converter.startChunkedConversion(sc.sink);
        if (storeColumnNames) {
          csvSink.add(databaseQueryResult.columnNames);
        }
        for (final rows in databaseQueryResult.rows) {
          csvSink.add(rows.rowData);
        }
        csvSink.close();
        await fileWriterCompleter.future;

      case JSONFormat(
        :final storeQuery,
        :final storeColumnNames,
        :final indentation,
      ):
        final appCacheDir = await getAppCacheDir();
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
        final jsonString = jsonEncoder.convert(jsonMap);
        await outputFile.write(jsonString);
        await outputFile.close();
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
