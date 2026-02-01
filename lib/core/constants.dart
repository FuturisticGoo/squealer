import 'package:futuristicgoo_utils/futuristicgoo_utils.dart';

const allowedExtension = ["sqlite", "db"];

const appDatabase = "squealer.sqlite";
const appName = "Squealer";
const appId = "futuristicgoo.squealer";
final appVersion = SemVer.fromString("0.1.2");
const defaultRowFetchCount = 50;

const jsonExportSquealerVersionKey = "_squealer_version";
const jsonExportQueryKey = "query";
const jsonExportColumnsKey = "columns";
const jsonExportRowsKey = "rows";
