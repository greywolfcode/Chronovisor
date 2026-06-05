import 'dart:collection';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:archive/archive.dart';

final chatPath = p.join('Takeout', 'Google Chat');

ChatArchive loadExport(String path)
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

  String user = '';
  List<MessageGroup> dms = [];
  List<MessageGroup> spaces = [];

  HashMap<String, List<ArchiveFile>> messageGroups;

  for (final entry in chatFolder)
  {
    
  }

  return ChatArchive(user, dms, spaces);

}

class ChatArchive
{
  const ChatArchive(this.user, this.dms, this.spaces);

  final String user;
  final List<MessageGroup> dms;
  final List<MessageGroup> spaces;
}

class MessageGroup 
{
  const MessageGroup(this.group_info, this.messages, this.files);

  final String group_info;
  final String messages;
  final List<ArchiveFile> files;
}