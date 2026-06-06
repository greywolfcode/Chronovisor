import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';

import 'package:archive/archive.dart';

final chatPath = 'Takeout/Google Chat';

ChatArchive loadExport(String path)
{
  final bytes = File(path).readAsBytesSync();
  final archive = ZipDecoder().decodeBytes(bytes);

  final List<ArchiveFile> chatFolder = [];

  for (final entry in archive)
  {
    //only want folders
    if (entry.isFile)
    {
      if (entry.name.contains(chatPath))
      {
        chatFolder.add(entry);
      }
    }    
  }

  String user = '';
  List<MessageGroup> dms = [];
  List<MessageGroup> spaces = [];

  //store each set of spaces/dms based on their path
  HashMap<String, List<ArchiveFile>> messageGroups = HashMap<String, List<ArchiveFile>>();

  for (final entry in chatFolder)
  {

    var file = entry.name.split('/');
    var fileName = file.removeAt(file.length - 1);
    var filePath = file.join('');

    if (fileName == 'user_info.json')
    {
      user = utf8.decoder.convert(entry.content);
      continue;
    }

    //add new dm/space to map
    if (!messageGroups.containsKey(filePath))
    {
      messageGroups[filePath] = [];
    }

    messageGroups[filePath]!.add(entry);
  }  

  for (final key in messageGroups.keys)
  {
    if (messageGroups[key] == null)
    {
      continue;
    }

    String messages = '';
    String groupInfo = '';
    List<ArchiveFile> files = [];

    for (final file in messageGroups[key]!)
    {
      if (file.name.contains('group_info.json'))
      {
        groupInfo = utf8.decoder.convert(file.content);
      }
      else if (file.name.contains('messages.json'))
      {
        messages = utf8.decoder.convert(file.content);
      }
      else
      {
        files.add(file);
      }
    }

    if (key.contains('DM'))
    {
      dms.add(MessageGroup(groupInfo, messages, files));
    }
    else if (key.contains('Space'))
    {
      spaces.add(MessageGroup(groupInfo, messages, files));
    }
  }

  return ChatArchive(user, dms, spaces);

}

class ChatArchive
{
  const ChatArchive(this.user, this.dms, this.spaces);

  final String user;
  final List<MessageGroup> dms;
  final List<MessageGroup> spaces;

  @override
  String toString()
  {
    return 'DMs: ${dms.length}  Spaces: ${spaces.length} User: $user';
  }
}

class MessageGroup 
{
  const MessageGroup(this.groupInfo, this.messages, this.files);

  final String groupInfo;
  final String messages;
  final List<ArchiveFile> files;
}