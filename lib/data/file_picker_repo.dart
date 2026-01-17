import 'package:fpdart/fpdart.dart';
import 'package:futuristicgoo_utils/futuristicgoo_utils.dart';
import 'package:squealer/core/entities/database_meta_entities.dart';
import 'package:squealer/core/entities/failure_success.dart';
import 'package:squealer/data/file_picker_source.dart';

class FilePickerRepository {
  final FilePickerSource nativeFilePicker;
  final CustomFilePicker customFilePicker;
  const FilePickerRepository({
    required this.nativeFilePicker,
    required this.customFilePicker,
  });

  Future<Either<Failure, DatabaseInfo>> getDatabaseFromContentUri({
    required Uri contentUri,
  }) async {
    try {
      final databaseInfo = await customFilePicker.getDatabaseInfoFromContentUri(
        contentUri: contentUri,
      );
      return Either.right(databaseInfo);
    } on InvalidPathError catch (error, stackTrace) {
      Loggify.getLogger?.severe(
        "InvalidPathError in getDatabaseFromContentUri",
        error,
        stackTrace,
      );
      return Either.left(
        InvalidPathFailure(error: error, stackTrace: stackTrace),
      );
    } catch (error, stackTrace) {
      Loggify.getLogger?.severe(
        "Unknown error in getDatabaseFromContentUri",
        error,
        stackTrace,
      );
      return Either.left(GenericFailure(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<Failure, DatabaseInfo>> getDatabaseFromFilePath({
    required String filePath,
  }) async {
    try {
      final pickerResult = await customFilePicker.getDatabaseInfoFromFilePath(
        filePath: filePath,
      );
      return Either.right(pickerResult);
    } on InvalidPathError catch (error, stackTrace) {
      Loggify.getLogger?.severe(
        "InvalidPathError in getDatabaseFromFilePath",
        error,
        stackTrace,
      );
      return Either.left(
        InvalidPathFailure(error: error, stackTrace: stackTrace),
      );
    } catch (error, stackTrace) {
      Loggify.getLogger?.severe(
        "Unknown error in getDatabaseFromFilePath",
        error,
        stackTrace,
      );
      return Either.left(GenericFailure(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<Failure, DatabaseInfo>> pickDatabaseFile() async {
    try {
      final pickerResult = await nativeFilePicker.pickDatabaseFile();
      return Either.right(pickerResult);
    } on FileNotPickedError catch (error, stackTrace) {
      Loggify.getLogger?.config(
        "FileNotPickedError in pickDatabaseFile",
        error,
        stackTrace,
      );
      return Either.left(FileNotPickedFailure());
    } catch (error, stackTrace) {
      Loggify.getLogger?.severe(
        "Unknown error in pickDatabaseFile",
        error,
        stackTrace,
      );
      return Either.left(GenericFailure(error: error, stackTrace: stackTrace));
    }
  }
}
