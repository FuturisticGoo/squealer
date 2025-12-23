import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:pick_or_save/pick_or_save.dart';
import 'package:squealer/core/entities/database_meta_entities.dart';
import 'package:squealer/core/entities/failure_success.dart';

abstract class FilePickerSource {
  Future<DatabaseInfo> pickDatabaseFile();
}

const _allowedExtension = ["sqlite", "db"];

class NativeFilePicker extends FilePickerSource {
  @override
  Future<SQLiteDatabaseInfo> pickDatabaseFile() async {
    Uri? databaseFileUri;
    if (Platform.isAndroid) {
      final filePickerResult = await PickOrSave().filePicker(
        params: FilePickerParams(
          getCachedFilePath: true,
          pickerType: PickerType.file,
          enableMultipleSelection: false,
          allowedExtensions: _allowedExtension.map((e) => ".$e").toList(),
        ),
      );
      if (filePickerResult != null && filePickerResult.isNotEmpty) {
        databaseFileUri = Uri.parse(filePickerResult.first);
      }
    } else {
      final filePickerResult = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: _allowedExtension,
        dialogTitle: "Pick SQLite database",
      );
      if (filePickerResult != null && filePickerResult.files.isNotEmpty) {
        // In Linux, it returns the absolute path
        databaseFileUri = Uri.file(filePickerResult.xFiles.first.path);
      }
    }
    if (databaseFileUri != null) {
      return SQLiteDatabaseInfo(databaseUri: databaseFileUri);
    } else {
      throw FileNotPickedError();
    }
  }
}

class CustomFilePicker extends FilePickerSource {
  @override
  Future<DatabaseInfo> pickDatabaseFile() async {
    // TODO: implement custom file picker UI
    throw UnimplementedError();
  }
}
