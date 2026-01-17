import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:futuristicgoo_utils/futuristicgoo_utils.dart';
import 'package:pick_or_save/pick_or_save.dart';
import 'package:squealer/core/constants.dart';
import 'package:squealer/core/entities/database_meta_entities.dart';
import 'package:squealer/core/entities/failure_success.dart';
import 'package:uri_content/uri_content.dart';
import 'package:path/path.dart' as p;

abstract class FilePickerSource {
  Future<DatabaseInfo> pickDatabaseFile();
}

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
          allowedExtensions: allowedExtension.map((e) => ".$e").toList(),
        ),
      );
      if (filePickerResult != null && filePickerResult.isNotEmpty) {
        databaseFileUri = Uri.parse(filePickerResult.first);
      }
    } else {
      final filePickerResult = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: allowedExtension,
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

class CustomFilePicker {
  final UriContent uriContent;
  const CustomFilePicker({required this.uriContent});
  Future<DatabaseInfo> getDatabaseInfoFromFilePath({
    required String filePath,
  }) async {
    if (!await File(filePath).exists()) {
      throw InvalidPathError();
    }
    return SQLiteDatabaseInfo(databaseUri: Uri.file(filePath));
  }

  // TODO: its  not opening the file when opened with fx
  Future<DatabaseInfo> getDatabaseInfoFromContentUri({
    required Uri contentUri,
  }) async {
    if (!contentUri.isScheme("content")) {
      throw InvalidPathError();
    }

    Loggify.getLogger?.info("Going to read $contentUri");
    final cachePath = await getAppCacheDir();
    final streamSize = await uriContent.getContentLength(contentUri);
    Loggify.getLogger?.info("Content URI file size: $streamSize");
    final stream = uriContent.getContentStream(contentUri);
    final outFile = File(p.join(cachePath, contentUri.pathSegments.last));
    final outFileSink = outFile.openWrite(mode: FileMode.writeOnly);
    await for (final bytes in stream) {
      Loggify.getLogger?.info("Writing ${bytes.lengthInBytes} bytes");
      outFileSink.add(bytes);
    }
    await outFileSink.flush();
    await outFileSink.close();
    return getDatabaseInfoFromFilePath(filePath: outFile.path);
  }
}
