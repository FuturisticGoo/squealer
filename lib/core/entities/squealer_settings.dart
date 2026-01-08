import 'package:equatable/equatable.dart';

final class SquealerSettings extends Equatable {
  final int rowFetchCount;
  const SquealerSettings({required this.rowFetchCount});
  @override
  List<Object?> get props => [rowFetchCount];
}
