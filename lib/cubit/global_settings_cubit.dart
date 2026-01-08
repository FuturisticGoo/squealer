import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:futuristicgoo_utils/futuristicgoo_utils.dart';
import 'package:squealer/core/entities/failure_success.dart';
import 'package:squealer/core/entities/squealer_metadata.dart';
import 'package:squealer/core/entities/squealer_settings.dart';
import 'package:squealer/data/settings_repo.dart';
part 'package:squealer/cubit/global_settings_state.dart';

class GlobalSettingsCubit extends Cubit<GlobalSettingsState> {
  final SettingsRepo settingsRepo;
  GlobalSettingsCubit({required this.settingsRepo})
    : super(GlobalSettingsInitial()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    emit(GlobalSettingsLoading());
    final settingsResult = await settingsRepo.getSettings();
    final metadataResult = await settingsRepo.getMetadata();
    switch ((settingsResult, metadataResult)) {
      case (
        Left(value: NoSettingsFoundFailure()),
        Left(value: NoMetadataFoundFailure()),
      ):
        emit(GlobalSettingsFirstTime());
      case (Left(:final value), _):
      case (_, Left(:final value)):
        emit(GlobalSettingsError(failure: value));
      case (Right(value: final settings), Right(value: final metadata)):
        emit(GlobalSettingsLoaded(settings: settings, metadata: metadata));
    }
  }

  Future<void> saveNewRowFetchCount({required int rowFetchCount}) async {
    if (state case GlobalSettingsLoaded() || GlobalSettingsFirstTime()) {
      await settingsRepo.saveSettings(
        newSettings: SquealerSettings(rowFetchCount: rowFetchCount),
      );
    }
  }

  Future<void> updateLastUsedVersion({required SemVer newVersion}) async {
    if (state case GlobalSettingsLoaded() || GlobalSettingsFirstTime()) {
      await settingsRepo.saveMetadata(
        newMetadata: SquealerMetadata(
          lastUsedVersion: newVersion,
          isFirstTime: false,
        ),
      );
    }
  }
}
