part of 'global_settings_cubit.dart';

sealed class GlobalSettingsState {
  const GlobalSettingsState();
}

class GlobalSettingsInitial extends GlobalSettingsState {}

class GlobalSettingsLoading extends GlobalSettingsState {}

class GlobalSettingsFirstTime extends GlobalSettingsState {}

class GlobalSettingsLoaded extends GlobalSettingsState with EquatableMixin {
  final SquealerSettings settings;
  final SquealerMetadata metadata;
  const GlobalSettingsLoaded({required this.settings, required this.metadata});

  @override
  List<Object?> get props => [settings, metadata];
}

class GlobalSettingsError extends GlobalSettingsState with EquatableMixin {
  final Failure failure;
  const GlobalSettingsError({required this.failure});
  @override
  List<Object?> get props => [failure];
}
