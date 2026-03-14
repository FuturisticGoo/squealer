import 'package:equatable/equatable.dart';

class SavedStatement extends Equatable {
  final int id;
  final String name;
  final String statement;
  const SavedStatement({
    required this.id,
    required this.name,
    required this.statement,
  });
  @override
  List<Object?> get props => [id, name, statement];
}
