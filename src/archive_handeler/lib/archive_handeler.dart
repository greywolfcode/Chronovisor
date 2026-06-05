import 'package:archive/archive.dart';
import 'dart:io';

void loadExport(String path)
{
  final bytes = File(path).readAsBytesSync();
  final archive = ZipDecoder().decodeBytes(bytes);
}