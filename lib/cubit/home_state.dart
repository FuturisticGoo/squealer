part of 'home_cubit.dart';

sealed class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {}

class HomeDatabaseFilePicked extends HomeState {
  final DatabaseInfo databaseFile;
  const HomeDatabaseFilePicked({required this.databaseFile});
}
