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

SQLiteCipherDatabaseInfo _$SQLiteCipherDatabaseInfoFromJson(
  Map<String, dynamic> json,
) => SQLiteCipherDatabaseInfo(
  databaseUri: Uri.parse(json['databaseUri'] as String),
  secret: json['secret'] as String,
  secretType: $enumDecode(_$SecretTypeEnumMap, json['secretType']),
);

Map<String, dynamic> _$SQLiteCipherDatabaseInfoToJson(
  SQLiteCipherDatabaseInfo instance,
) => <String, dynamic>{
  'databaseUri': instance.databaseUri.toString(),
  'type': instance.type,
  'version': const SemVerJsonConverter().toJson(instance.version),
  'secretType': _$SecretTypeEnumMap[instance.secretType]!,
  'secret': instance.secret,
};

const _$SecretTypeEnumMap = {
  SecretType.passphrase: 'passphrase',
  SecretType.keyHexDigest: 'keyHexDigest',
};
