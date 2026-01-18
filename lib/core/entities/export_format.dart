sealed class ExportFormat {
  const ExportFormat();
}

class CSVFormat implements ExportFormat {
  final String delimiter;
  final bool storeColumnNames;
  final String endOfLine;
  final String stringDelimiter;
  const CSVFormat({
    this.delimiter = ",",
    this.storeColumnNames = true,
    this.endOfLine = "\r\n",
    this.stringDelimiter = '"',
  });
}

class JSONFormat implements ExportFormat {
  final bool storeQuery;
  final bool storeColumnNames;
  final int indentation;
  const JSONFormat({
    this.storeQuery = true,
    this.storeColumnNames = true,
    this.indentation = 4,
  });
}
