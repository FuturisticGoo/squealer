import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:squealer/core/entities/database_meta_entities.dart';
import 'package:squealer/core/entities/failure_success.dart';
import 'package:squealer/data/viewer_repo.dart';

part 'viewer_state.dart';

class ViewerCubit extends Cubit<ViewerState> {
  final ViewerRepo viewerRepo;
  ViewerCubit({required this.viewerRepo, required DatabaseInfo databaseInfo})
    : super(ViewerInitial()) {
    emit(ViewerLoading());
    _openDatabase(databaseInfo: databaseInfo);
  }

  Future<void> _openDatabase({required DatabaseInfo databaseInfo}) async {
    final dbOpenResult = await viewerRepo.openDatabase(
      databaseInfo: databaseInfo,
    );
    switch (dbOpenResult) {
      case Left(value: GenericFailure(:final stackTrace)):
        emit(ViewerError(failure: dbOpenResult.value, stackTrace: stackTrace));
      case Left(:final value):
        emit(ViewerError(failure: value));
      case Right(value: final databaseObject):
        emit(ViewerDatabaseLoaded(databaseObject: databaseObject));
    }
  }

  Future<void> closeDatabase() async {
    if (state case ViewerDatabaseLoaded(:final databaseObject)) {
      await viewerRepo.closeDatabase(databaseObject: databaseObject);
    }
  }
}
