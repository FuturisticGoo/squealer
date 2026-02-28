part of 'home_cubit.dart';

sealed class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState with EquatableMixin {
  final List<DatabaseInfo> recentDatabases;
  const HomeLoaded({required this.recentDatabases});
  @override
  List<Object?> get props => [recentDatabases];
}

class HomeDatabaseFilePicked extends HomeLoaded with EquatableMixin {
  final DatabaseInfo databaseInfo;
  const HomeDatabaseFilePicked({
    required this.databaseInfo,
    required super.recentDatabases,
  });
  @override
  List<Object?> get props => [super.props, databaseInfo];
}
