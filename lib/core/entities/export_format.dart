sealed class ExportFormat {
  const ExportFormat();
}

class CSVFormat implements ExportFormat {
  final String delimiter;
  final bool storeColumnNames;
  const CSVFormat({this.delimiter = ",", this.storeColumnNames = true});
}

class JSONFormat implements ExportFormat {
  final bool storeQuery;
  final bool storeColumnNames;
  const JSONFormat({this.storeQuery = true, this.storeColumnNames = true});
}
