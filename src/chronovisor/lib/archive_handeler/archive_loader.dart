/*
  Chronovisor chat archive viewer tool.
  Copyright (C) 2026  greywolfcode

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published byl
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License along
  with this program; if not, write to the Free Software Foundation, Inc.,
  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/

import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:archive/archive_io.dart';
import 'package:archive/archive.dart';

import 'package:drift/drift.dart';

import '../data_handeler/messages_json.dart';
import '../data_handeler/messages_database.dart';

final chatPath = 'Takeout/Google Chat';

Future<String> loadExport(String path) async
{
  final saveDir = Directory('save');

  saveDir.createSync(recursive: true);

  final numFolders = saveDir.listSync(recursive: false).length;

  final outputPath = p.join('save', 'user${(numFolders + 1).toString().padLeft(8, '0')}');
  Directory(outputPath).createSync(recursive: true);

  final inputStream = InputFileStream(path);

  final archive = ZipDecoder().decodeStream(inputStream);

  for (final file in archive) 
  {

    //No symbolic links in Chat Archives

    if (file.isFile) {
      //file.name includes directory path
      final outputStream = OutputFileStream('$outputPath/${file.name.replaceFirst('Takeout/Google Chat/', '')}');
      
      file.writeContent(outputStream);
      outputStream.closeSync();
    } 
    else 
    {
      Directory('$outputPath/${file.name.replaceFirst('Takeout/Google Chat/', '')}').createSync(recursive: true);
    }
  }

  await generateDatabases(outputPath);

  return outputPath;
}
Future<void> generateDatabases(String dirPath) async
{
  final archiveDir = Directory(p.join(dirPath, "Groups"));
  final  List<Directory> groups = archiveDir.listSync(recursive: false, followLinks: false).whereType<Directory>().toList();

  for (Directory group in groups)
  {
    File messagesPath = File(p.join(group.path, "messages.json"));
    //TODO:Show error to user
    if (!messagesPath.existsSync())
    {
      continue;
    }

    final jsonData = messagesPath.readAsStringSync();
    final messageData = jsonDecode(jsonData) as Map<String, dynamic>;
    final messages = ChatData.fromJson(messageData); 

    final database = MessagesDatabase(File(p.join(group.path, "messages.sqlite")));
    for (Message message in messages.messages)
    {
      await insertMessage(database, message);
    }
  }
}
Future<void> insertMessage(MessagesDatabase database, Message message) async
{
  String? email;
  if (message.creator is HumanCreator)
  {
    email = (message.creator as HumanCreator).email;
  }

  int id = await database
    .into(database.messagesTable)
    .insert(
      MessagesTableCompanion.insert(
        name: Value(message.creator.name), 
        email: Value(email), 
        userType: Value(message.creator.type),
        createdDate: Value(message.createdDate), 
        messageText: Value(message.text), 
        topicId: Value(message.topicId),
        messageId: Value(message.messageId),
      )
    );
  
  var reactions = message.reactions;
  if (reactions != null)
  {
    await database
    .into(database.reactionTable)
    .insert(
      ReactionTableCompanion.insert(
        parentId: id,
        emails: reactions.reactorEmails,
        emoji: reactions.emoji.unicode
      )
    );
  }
}

ChatArchive processArchive(String path)
{
  final bytes = File(path).readAsBytesSync();
  final archive = ZipDecoder().decodeBytes(bytes);

  final List<ArchiveFile> chatFolder = [];

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