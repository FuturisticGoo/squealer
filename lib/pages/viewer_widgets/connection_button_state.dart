import 'package:flutter/material.dart';
import 'package:squealer/core/entities/database_meta_entities.dart';

sealed class ButtonState {
  String get text;
  Icon get icon;
  const ButtonState();
  static List<ButtonState> get values => [
    PickState(),
    // CreateState(), // Will do in later version
    ConnectState(dbInfo: null),
  ];
}

class PickState extends ButtonState {
  @override
  String get text => "Pick";
  @override
  Icon get icon => Icon(Icons.file_open);
  const PickState();
}

class CreateState extends ButtonState {
  @override
  String get text => "Create";
  @override
  Icon get icon => Icon(Icons.create);
  const CreateState();
}

class ConnectState extends ButtonState {
  @override
  String get text => "Connect";
  @override
  Icon get icon => Icon(Icons.link);

  final DatabaseInfo? dbInfo;
  const ConnectState({required this.dbInfo});
}
