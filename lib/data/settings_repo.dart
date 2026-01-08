import 'package:fpdart/fpdart.dart';
import 'package:squealer/core/entities/failure_success.dart';
import 'package:squealer/core/entities/squealer_metadata.dart';
import 'package:squealer/core/entities/squealer_settings.dart';

abstract class SettingsRepo {
  Future<Either<Failure, SquealerSettings>> getSettings();
  Future<Either<Failure, Success>> saveSettings({
    required SquealerSettings newSettings,
  });
  Future<Either<Failure, SquealerMetadata>> getMetadata();
  Future<Either<Failure, Success>> saveMetadata({
    required SquealerMetadata newMetadata,
  });
}
