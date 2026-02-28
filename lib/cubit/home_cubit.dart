import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:squealer/core/entities/database_meta_entities.dart';
import 'package:squealer/data/app_data_repo.dart';
import 'package:squealer/data/file_picker_repo.dart';
part 'package:squealer/cubit/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final FilePickerRepository filePickerRepository;
  final AppDataRepo appDataRepo;
  HomeCubit({required this.filePickerRepository, required this.appDataRepo})
    : super(HomeInitial()) {
    emit(HomeLoading());
    loadedRecentDatabases();
  }

  Future<void> loadedRecentDatabases() async {
    final recentDatabasesResult = await appDataRepo.getRecentDatabases();
    switch (recentDatabasesResult) {
      case Right(value: final recentDatabases):
        emit(HomeLoaded(recentDatabases: recentDatabases));
      case Left():
        emit(HomeLoaded(recentDatabases: []));
    }
  }

  Future<void> getDatabaseFromContentUri({required Uri contentUri}) async {
    if (state case HomeLoaded(:final recentDatabases)) {
      emit(HomeLoading());
      final filePickerResult = await filePickerRepository
          .getDatabaseFromContentUri(contentUri: contentUri);
      switch (filePickerResult) {
        case Right(value: final databaseInfo):
          emit(
            HomeDatabaseFilePicked(
              databaseInfo: databaseInfo,
              recentDatabases: recentDatabases,
            ),
          );
        case Left():
          emit(HomeLoaded(recentDatabases: recentDatabases));
      }
    }
  }

  Future<void> getDatabaseFromFilePath({required String path}) async {
    if (state case HomeLoaded(:final recentDatabases)) {
      emit(HomeLoading());
      final filePickerResult = await filePickerRepository
          .getDatabaseFromFilePath(filePath: path);
      if (filePickerResult case Right(value: final databaseInfo)) {
        emit(
          HomeDatabaseFilePicked(
            databaseInfo: databaseInfo,
            recentDatabases: recentDatabases,
          ),
        );
      } else {
        emit(HomeLoaded(recentDatabases: recentDatabases));
      }
    }
  }

  Future<void> pickDatabaseFile() async {
    if (state case HomeLoaded(:final recentDatabases)) {
      emit(HomeLoading());
      final filePickerResult = await filePickerRepository.pickDatabaseFile();
      if (filePickerResult case Right(value: final databaseInfo)) {
        emit(
          HomeDatabaseFilePicked(
            databaseInfo: databaseInfo,
            recentDatabases: recentDatabases,
          ),
        );
      } else {
        emit(HomeLoaded(recentDatabases: recentDatabases));
      }
    }
  }

  Future<void> saveDatabaseToRecent({
    required DatabaseInfo databaseInfo,
  }) async {
    if (state case HomeLoaded(
      :final recentDatabases,
    ) when !recentDatabases.contains(databaseInfo)) {
      await appDataRepo.saveDatabaseToRecent(databaseInfo: databaseInfo);
      await loadedRecentDatabases();
    }
  }

  Future<void> removeDatabaseFromRecent({
    required DatabaseInfo databaseInfo,
  }) async {
    if (state case HomeLoaded()) {
      await appDataRepo.removeDatabaseFromRecent(databaseInfo: databaseInfo);
      await loadedRecentDatabases();
    }
  }
}
