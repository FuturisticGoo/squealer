import 'package:fpdart/fpdart.dart';
import 'package:futuristicgoo_utils/futuristicgoo_utils.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:squealer/core/constants.dart';
import 'package:squealer/core/entities/failure_success.dart';
import 'package:squealer/core/entities/squealer_metadata.dart';
import 'package:squealer/core/entities/squealer_settings.dart';
import 'package:squealer/data/settings_repo.dart';

class SettingsRepoImpl implements SettingsRepo {
  final SqliteSettingsSource sqliteSettingsSource;
  const SettingsRepoImpl({required this.sqliteSettingsSource});
  @override
  Future<Either<Failure, SquealerSettings>> getSettings() async {
    try {
      final squealerSettings = await sqliteSettingsSource.getSettings();
      Loggify.getLogger?.fine("Got settings $squealerSettings");
      return Either.right(squealerSettings);
    } on NoSettingsFoundError catch (error, stackTrace) {
      Loggify.getLogger?.config("No settings found", error, stackTrace);
      return Either.left(NoSettingsFoundFailure());
    } catch (error, stackTrace) {
      Loggify.getLogger?.severe(
        "Error while trying to get settings",
        error,
        stackTrace,
      );
      return Either.left(GenericFailure(error: error, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, Success>> saveSettings({
    required SquealerSettings newSettings,
  }) async {
    try {
      await sqliteSettingsSource.saveSettings(newSettings: newSettings);
      Loggify.getLogger?.fine("Saving settings $newSettings");
      return Either.right(Success());
    } catch (error, stackTrace) {
      Loggify.getLogger?.severe(
        "Error while trying to save settings",
        error,
        stackTrace,
      );
      return Either.left(GenericFailure(error: error, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, SquealerMetadata>> getMetadata() async {
    try {
      final squealerMetadata = await sqliteSettingsSource.getMetadata();
      Loggify.getLogger?.fine("Got metadata $squealerMetadata");
      return Either.right(squealerMetadata);
    } on NoMetadataFoundError catch (error, stackTrace) {
      Loggify.getLogger?.config("No metadata found", error, stackTrace);
      return Either.left(NoMetadataFoundFailure());
    } catch (error, stackTrace) {
      Loggify.getLogger?.severe(
        "Error while trying to get metadata",
        error,
        stackTrace,
      );
      return Either.left(GenericFailure(error: error, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, Success>> saveMetadata({
    required SquealerMetadata newMetadata,
  }) async {
    try {
      await sqliteSettingsSource.saveMetadata(newMetadata: newMetadata);
      Loggify.getLogger?.fine("Metadata saved $newMetadata");
      return Either.right(Success());
    } catch (error, stackTrace) {
      Loggify.getLogger?.severe(
        "Error while trying to save metadata",
        error,
        stackTrace,
      );
      return Either.left(GenericFailure(error: error, stackTrace: stackTrace));
    }
  }
}

class SqliteSettingsSource {
  final SqliteDatabase db;
  SqliteSettingsSource({required this.db});

  Future<void> ensureTables() async {
    await db.execute("""
CREATE TABLE IF NOT EXISTS 
  ${_SqlNames.settingsTableName} 
(
  ${_SqlNames.settingsIdColumnName} TEXT PRIMARY KEY,
  ${_SqlNames.settingsValueColumnName} TEXT
)
""");

    await db.execute("""
CREATE TABLE IF NOT EXISTS 
  ${_SqlNames.metadataTable} 
(
  ${_SqlNames.metadataIdColumnName} TEXT PRIMARY KEY,
  ${_SqlNames.metadataValueColumnName} TEXT
)
""");
  }

  Future<SquealerSettings> getSettings() async {
    final settingsRows = await db.execute(""" 
SELECT 
  ${_SqlNames.settingsIdColumnName}, ${_SqlNames.settingsValueColumnName}
FROM
  ${_SqlNames.settingsTableName}
    """);
    if (settingsRows.isEmpty) {
      throw NoSettingsFoundError();
    }
    try {
      final rowFetchCount = int.parse(
        settingsRows.singleWhere(
              (row) =>
                  row[_SqlNames.settingsIdColumnName] ==
                  _SqlNames.settingsRowFetchCount,
            )[_SqlNames.settingsValueColumnName]
            as String,
      );
      return SquealerSettings(rowFetchCount: rowFetchCount);
    } on StateError catch (_) {
      throw NoSettingsFoundError();
    }
  }

  Future<void> _insertSetting({
    required String id,
    required String value,
  }) async {
    await db.writeTransaction((tx) async {
      await tx.execute(
        """
DELETE FROM
  ${_SqlNames.settingsTableName}
WHERE
  ${_SqlNames.settingsIdColumnName}==?
""",
        [id],
      );
      await tx.execute(
        """ 
INSERT INTO
  ${_SqlNames.settingsTableName}
  (${_SqlNames.settingsIdColumnName}, ${_SqlNames.settingsValueColumnName})
VALUES
  (?, ?)
""",
        [id, value],
      );
    });
  }

  Future<void> _insertMetadata({
    required String id,
    required String value,
  }) async {
    await db.writeTransaction((tx) async {
      await tx.execute(
        """
DELETE FROM
  ${_SqlNames.metadataTable}
WHERE
  ${_SqlNames.metadataIdColumnName}==?
""",
        [id],
      );
      await tx.execute(
        """ 
INSERT INTO
  ${_SqlNames.metadataTable}
  (${_SqlNames.metadataIdColumnName}, ${_SqlNames.metadataValueColumnName})
VALUES
  (?, ?)
""",
        [id, value],
      );
    });
  }

  Future<void> saveSettings({required SquealerSettings newSettings}) async {
    await _insertSetting(
      id: _SqlNames.settingsRowFetchCount,
      value: newSettings.rowFetchCount.toString(),
    );
  }

  Future<SquealerMetadata> getMetadata() async {
    final metadataRows = await db.execute(""" 
SELECT 
  ${_SqlNames.metadataIdColumnName}, ${_SqlNames.metadataValueColumnName}
FROM
  ${_SqlNames.metadataTable}
    """);
    if (metadataRows.isEmpty) {
      throw NoMetadataFoundError();
    }
    try {
      final savedVersion =
          metadataRows.singleWhere(
                (row) =>
                    row[_SqlNames.metadataIdColumnName] ==
                    _SqlNames.metadataVersion,
              )[_SqlNames.metadataValueColumnName]
              as String?;
      if (savedVersion == null) {
        return SquealerMetadata(lastUsedVersion: null, isFirstTime: true);
      } else {
        final version = SemVer.fromString(savedVersion);
        return SquealerMetadata(lastUsedVersion: version, isFirstTime: false);
      }
    } on StateError catch (_) {
      throw NoSettingsFoundError();
    }
  }

  Future<void> saveMetadata({required SquealerMetadata newMetadata}) async {
    SquealerMetadata metadata;
    if (newMetadata.lastUsedVersion != null) {
      metadata = SquealerMetadata(
        lastUsedVersion: appVersion,
        isFirstTime: false,
      );
    } else {
      metadata = newMetadata;
    }
    await _insertMetadata(
      id: _SqlNames.metadataVersion,
      value: metadata.lastUsedVersion.toString(),
    );
  }
}

abstract final class _SqlNames {
  static const settingsTableName = "settings";
  static const settingsIdColumnName = "settings_id";
  static const settingsValueColumnName = "settings_value";
  static const settingsRowFetchCount = "row_fetch_count";

  static const metadataTable = "squealer_metadata";
  static const metadataIdColumnName = "metadata_id";
  static const metadataValueColumnName = "metadata_value";
  static const metadataVersion = "version";
}
