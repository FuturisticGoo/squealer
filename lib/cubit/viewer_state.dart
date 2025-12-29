part of 'viewer_cubit.dart';

sealed class ViewerState {
  const ViewerState();
}

class ViewerInitial extends ViewerState {}

class ViewerLoading extends ViewerState {}

class ViewerDatabaseLoaded extends ViewerState with EquatableMixin {
  final DatabaseObject databaseObject;
  const ViewerDatabaseLoaded({required this.databaseObject});
  @override
  List<Object?> get props => [databaseObject];
}

class ViewerError extends ViewerState with EquatableMixin {
  final Failure failure;
  final StackTrace? stackTrace;
  const ViewerError({required this.failure, this.stackTrace});
  @override
  List<Object?> get props => [failure, stackTrace];
}
