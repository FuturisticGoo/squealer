import 'dart:typed_data';

import 'package:squealer/core/handy_extensions.dart';

class SimpleSQLiteCommandWriter {
  final StringBuffer stringBuffer = StringBuffer();

  void writeRawSql(String sql, {bool addNewLine = true}) {
    final trimmed = sql.trim();
    (addNewLine ? stringBuffer.writeln : stringBuffer.write)(
      trimmed.endsWith(";") ? trimmed : "$trimmed;",
    );
  }

  void writeInsert({
    required String schemaName,
    required List<Object?> row,
    bool addNewLine = true,
  }) {
    final insertStringBuffer = StringBuffer();
    insertStringBuffer.write("""INSERT INTO "$schemaName" VALUES ( """);
    for (int i = 0; i < row.length; i++) {
      final cell = row[i];
      switch (cell) {
        case num():
          insertStringBuffer.write("$cell");
        case String():
          insertStringBuffer.write("""'${cell.replaceAll("'", "''")}'""");
        case bool():
          insertStringBuffer.write(cell ? "1" : "0");
        case null:
          insertStringBuffer.write("NULL");
        case Uint8List():
          insertStringBuffer.write("X'${cell.getHex()}'");
        default:
          throw UnsupportedError("Unsupported datatype");
      }
      if (i == row.length - 1) {
        insertStringBuffer.write(" )");
      } else {
        insertStringBuffer.write(", ");
      }
    }
    if (addNewLine) {
      insertStringBuffer.writeln(";");
    } else {
      insertStringBuffer.write(";");
    }

    stringBuffer.write(insertStringBuffer.toString());
  }

  @override
  String toString() => stringBuffer.toString();

  void clear() => stringBuffer.clear();
}
