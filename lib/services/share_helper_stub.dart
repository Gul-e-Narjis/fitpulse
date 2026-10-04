import 'dart:typed_data';

bool get canShareFiles => false;

void downloadPng(Uint8List bytes, String filename) {}

Future<bool> sharePng(Uint8List bytes, String filename, String text) async =>
    false;
