// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_meta_entities.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SQLiteDatabaseInfo _$SQLiteDatabaseInfoFromJson(Map<String, dynamic> json) =>
    SQLiteDatabaseInfo(databaseUri: Uri.parse(json['databaseUri'] as String));

Map<String, dynamic> _$SQLiteDatabaseInfoToJson(SQLiteDatabaseInfo instance) =>
    <String, dynamic>{
      'databaseUri': instance.databaseUri.toString(),
      'type': instance.type,
      'version': const SemVerJsonConverter().toJson(instance.version),
    };
