import 'package:futuristicgoo_utils/futuristicgoo_utils.dart';

class ExportingRowsUpdate extends ProgressUpdate {
  const ExportingRowsUpdate({required super.finished, required super.total});
}

class ExportingRowsFinished extends ProgressFinished {}

class ExportingRowsError extends ProgressError {}
