import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:archive/archive.dart';

final chatPath = p.join('Takeout', 'Google Chat');

void loadExport(String path)
{
  final bytes = File(path).readAsBytesSync();
  final archive = ZipDecoder().decodeBytes(bytes);

  final List<ArchiveFile> chatFolder = [];

  for (final entry in archive)
  {
    //only want folders
    if (entry.isDirectory)
    {
      if (entry.name.contains(chatPath))
      {
        chatFolder.add(entry);
        break;
      }
    }    
  }

}