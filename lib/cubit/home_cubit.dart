import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:squealer/core/entities/database_meta_entities.dart';
import 'package:squealer/data/file_picker_repo.dart';
part 'package:squealer/cubit/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final FilePickerRepository filePickerRepository;
  HomeCubit({required this.filePickerRepository}) : super(HomeInitial()) {
    emit(HomeLoaded());
  }

  Future<void> getDatabaseFromFilePath({required String path}) async {
    emit(HomeLoading());
    final filePickerResult = await filePickerRepository.getDatabaseFromFilePath(
      filePath: path,
    );
    if (filePickerResult case Right(value: final databaseFile)) {
      emit(HomeDatabaseFilePicked(databaseFile: databaseFile));
    } else {
      emit(HomeLoaded());
    }
  }

  Future<void> pickDatabaseFile() async {
    emit(HomeLoading());
    final filePickerResult = await filePickerRepository.pickDatabaseFile(
    );
    if (filePickerResult case Right(value: final databaseFile)) {
      emit(HomeDatabaseFilePicked(databaseFile: databaseFile));
    } else {
      emit(HomeLoaded());
    }
  }
}
