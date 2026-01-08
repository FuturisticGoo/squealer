import 'package:equatable/equatable.dart';
import 'package:futuristicgoo_utils/futuristicgoo_utils.dart';
import 'package:squealer/core/constants.dart';

class SquealerMetadata extends Equatable {
  final SemVer? lastUsedVersion;
  final bool isFirstTime;
  const SquealerMetadata({
    required this.lastUsedVersion,
    required this.isFirstTime,
  });
  @override
  List<Object?> get props => [lastUsedVersion, isFirstTime];

  bool get isUpdated =>
      lastUsedVersion == null || appVersion > lastUsedVersion!;
}
