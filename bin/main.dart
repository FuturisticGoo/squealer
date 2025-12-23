import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlparser/sqlparser.dart';

Future<void> main() async {
  databaseFactory = databaseFactoryFfi;
  final path = "/home/fgoo/Downloads/emoticdb.sqlite";
  final db = await openDatabase(path);
  final tableInfoResult = await db.rawQuery(
    """ 
SELECT 
  sql
FROM 
  sqlite_master 
WHERE 
  type='table'
AND
  name=?
    """,
    ["emoticons"],
  );
  final sql = tableInfoResult.single["sql"] as String;
  final engine = SqlEngine();
  print(sql);
  final ast = engine.parse(sql);
  print(ast.rootNode.runtimeType);
  for (final col in ast.rootNode.childNodes.toList()) {
    switch (col) {
      case ColumnDefinition(:final columnName, :final typeName):
        print(
          "$columnName, $typeName, ${col.isNonNullable},  ${col.constraints.first}, ",
        );
    }
  }
}
