import 'package:equatable/equatable.dart';
import 'package:futuristicgoo_utils/futuristicgoo_utils.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sqlite_async/sqlite_async.dart';
part 'database_meta_entities.g.dart';

class SemVerJsonConverter extends JsonConverter<SemVer, String> {
  const SemVerJsonConverter() : super();
  @override
  String toJson(SemVer object) {
    return object.toString();
  }

  @override
  SemVer fromJson(String json) {
    return SemVer.fromString(json);
  }
}

sealed class DatabaseInfo extends Equatable {
  final Uri databaseUri;
  @JsonKey(includeToJson: true, includeFromJson: false)
  SemVer get version;
  @JsonKey(includeToJson: true, includeFromJson: false)
  String get type => runtimeType.toString();
  const DatabaseInfo({required this.databaseUri});
  @override
  List<Object?> get props => [databaseUri];
  Map<String, dynamic> toJson();
  factory DatabaseInfo.fromJson(Map<String, dynamic> json) {
    final typeString = json["type"];
    if (typeString == (SQLiteDatabaseInfo).toString()) {
      return SQLiteDatabaseInfo.fromJson(json);
    } else {
      throw TypeError();
    }
  }
}

@JsonSerializable(converters: [SemVerJsonConverter()])
class SQLiteDatabaseInfo extends DatabaseInfo {
  @JsonKey(includeToJson: true, includeFromJson: false)
  @override
  SemVer get version => SemVer.fromString("0.0.1");
  const SQLiteDatabaseInfo({required super.databaseUri});
  @override
  Map<String, dynamic> toJson() => _$SQLiteDatabaseInfoToJson(this);
  factory SQLiteDatabaseInfo.fromJson(Map<String, dynamic> json) =>
      _$SQLiteDatabaseInfoFromJson(json);
}

sealed class DatabaseObject with EquatableMixin {
  const DatabaseObject();
}

class SQLite3AsyncDatabaseObject extends DatabaseObject {
  final SqliteDatabase db;
  const SQLite3AsyncDatabaseObject({required this.db});
  @override
  List<Object?> get props => [db];
}
