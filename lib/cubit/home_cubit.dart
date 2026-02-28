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
    _loadedRecentDatabases();
  }

  Future<void> _loadedRecentDatabases() async {
    final recentDatabasesResult = await appDataRepo.getRecentDatabases();
    switch (recentDatabasesResult) {
      case Right(value: final recentDatabases):
        if (state case HomeDatabaseFilePicked(:final databaseInfo)) {
          emit(
            HomeDatabaseFilePicked(
              databaseInfo: databaseInfo,
              recentDatabases: recentDatabases,
            ),
          );
        }
        emit(HomeLoaded(recentDatabases: recentDatabases));
      case Left():
        emit(HomeLoaded());
    }
  }

  Future<void> getDatabaseFromContentUri({required Uri contentUri}) async {
    emit(HomeLoading());
    final filePickerResult = await filePickerRepository
        .getDatabaseFromContentUri(contentUri: contentUri);
    switch (filePickerResult) {
      case Right(value: final databaseInfo):
        emit(HomeDatabaseFilePicked(databaseInfo: databaseInfo));
      case Left():
        emit(HomeLoaded());
    }
  }

  Future<void> getDatabaseFromFilePath({required String path}) async {
    emit(HomeLoading());
    final filePickerResult = await filePickerRepository.getDatabaseFromFilePath(
      filePath: path,
    );
    if (filePickerResult case Right(value: final databaseInfo)) {
      emit(HomeDatabaseFilePicked(databaseInfo: databaseInfo));
    } else {
      emit(HomeLoaded());
    }
  }

  Future<void> pickDatabaseFile() async {
    emit(HomeLoading());
    final filePickerResult = await filePickerRepository.pickDatabaseFile();
    if (filePickerResult case Right(value: final databaseInfo)) {
      emit(HomeDatabaseFilePicked(databaseInfo: databaseInfo));
    } else {
      emit(HomeLoaded());
    }
  }

  Future<void> saveDatabaseToRecent({
    required DatabaseInfo databaseInfo,
  }) async {
    if (state case HomeLoaded(
      :final recentDatabases,
    ) when !recentDatabases.contains(databaseInfo)) {
      await appDataRepo.saveDatabaseToRecent(databaseInfo: databaseInfo);
      await _loadedRecentDatabases();
    }
  }

  Future<void> removeDatabaseFromRecent({
    required DatabaseInfo databaseInfo,
  }) async {
    if (state case HomeLoaded()) {
      await appDataRepo.removeDatabaseFromRecent(databaseInfo: databaseInfo);
      await _loadedRecentDatabases();
    }
  }
}
