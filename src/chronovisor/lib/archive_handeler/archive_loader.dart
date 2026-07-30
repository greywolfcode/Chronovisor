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
    AttachedFilesStorage filesStorage = AttachedFilesStorage();
    for (Message message in messages.messages)
    {
      await insertMessage(database, message, filesStorage);
    }
  }
}
Future<void> insertMessage(MessagesDatabase database, Message message, AttachedFilesStorage filesStorage) async
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
        //If there is no created dat, there is an updated date
        createdDate: Value(message.createdDate ?? message.updatedDate), 
        messageText: Value(message.text), 
        topicId: Value(message.topicId),
        messageId: Value(message.messageId),
      )
    );
  var files = message.attachedFiles;
  if (files != null)
  {
    for (var file in files.files)
    {
      String storedName = filesStorage.getStoredFileName(file.exportName);

      await database
      .into(database.filesTable)
      .insert(
        FilesTableCompanion.insert(
          parentId: id,
          originalName: file.originalName,
          exportName: file.exportName,
          storedName: storedName
        )
      );
    }
  }
  var previousVersions = message.previousMessageVersions;
  if (previousVersions != null)
  {
    //assuming that any images in previous versions have the same name;
    //there doesn't appear to be a way to tell otherwise
    filesStorage.freeze();
    for (var version in previousVersions)
    {
      insertMessage(database, version, filesStorage);
    }
    filesStorage.unfreeze();
  }

  var reactions = message.reactions;
  if (reactions != null)
  {
    for (var reaction in reactions)
    {
      await database
      .into(database.reactionTable)
      .insert(
        ReactionTableCompanion.insert(
          parentId: id,
          emails: reaction.reactorEmails,
          emoji: reaction.emoji.unicode
        )
      );
    }
  }
  var annotations = message.annotations;
  if (annotations != null)
  {
    for (var annotation in annotations)
    {
      await database
      .into(database.annotationsTable)
      .insert(
        AnnotationsTableCompanion.insert(
          parentId: id,
          startIndex: annotation.startIndex,
          length: annotation.length,

          // Url Metadata
          imageUrl: Value(annotation.urlMetadata?.imageUrl),
          title: Value(annotation.urlMetadata?.title),
          snippet: Value(annotation.urlMetadata?.snippet),
          privateDoNotAccessOrElseSafeUrlWrappedValue: Value(annotation.urlMetadata?.url.privateDoNotAccessOrElseSafeUrlWrappedValue ),

          // Video Call Metadata
          meetingUrl: Value(annotation.videoCallMetadata?.meetingSpace.meetingUrl),

          // Format Metadata
          formatType: Value(annotation.formatMetadata?.formatType)
        )
      );
    }
  }
}

///Stores how many times a file name has been attached
class AttachedFilesStorage
{
  Map<String, int> files = {};
  ///Only accept new files, don't update count
  bool frozen = false;

  AttachedFilesStorage();

  void freeze()
  {
    frozen = true;
  }
  void unfreeze()
  {
    frozen = false;
  }
  String getStoredFileName(String file)
  {
    if (frozen)
    {
      return file;
    }

    if (!files.containsKey(file))
    {
      files.addAll(
        {file: 1},
      );
      return file;
    }

    //Not new, and not frozzen, so update count
    files.update(file, (value) => files[file]! + 1, ifAbsent: () => 1);
    List<String> fileParts = file.split(".");
    String extension = fileParts.removeLast();
    return  "${fileParts.join()}(${(files[file]! + 1).toString()})$extension";
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