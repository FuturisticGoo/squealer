import 'dart:typed_data';

extension HexString on Uint8List {
  String getHex() {
    return map((e) => e.toRadixString(16).padLeft(2, '0')).join();
  }
}
