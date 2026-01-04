import 'package:fpdart/fpdart.dart';
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
  Future<Either<Failure, DatabaseInfo>> getDatabaseFromFilePath({
    required String filePath,
  }) async {
    try {
      final pickerResult = await customFilePicker.getDatabaseInfoFromFilePath(
        filePath: filePath,
      );
      return Either.right(pickerResult);
    } catch (error, stackTrace) {
      return Either.left(GenericFailure(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<Failure, DatabaseInfo>> pickDatabaseFile() async {
    try {
      final pickerResult = await nativeFilePicker.pickDatabaseFile();
      return Either.right(pickerResult);
    } on FileNotPickedError {
      return Either.left(FileNotPickedFailure());
    } catch (error, stackTrace) {
      return Either.left(GenericFailure(error: error, stackTrace: stackTrace));
    }
  }
}
