import 'package:json_annotation/json_annotation.dart';

part 'messages_json.g.dart';

// Chat Classes
//--------------
@JsonSerializable(explicitToJson: true)
class ChatData {
  ChatData(this.messages);

  List<Message> messages;

  factory ChatData.fromJson(Map<String, dynamic> json) => _$ChatDataFromJson(json);

  Map<String, dynamic> toJson() => _$ChatDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Message
{
  @_CreatorConverter()
  Creator creator;

  @JsonKey(name: 'created_date')
  String? createdDate;
  @JsonKey(name: 'updated_date')
  String? updatedDate;
  @JsonKey(name: 'topic_id')
  String? topicId;
  @JsonKey(name: 'message_id')
  String? messageId;
  @JsonKey(name: 'attached_files')
  AttachedFiles? attachedFiles;

  Reaction? reactions;

  String? text;
  

  Message(this.creator, this.topicId, this.messageId);

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

// Attached Files Classes
//------------------------
@JsonSerializable(explicitToJson: true)
class AttachedFiles
{
  List<AttachedFile> files;

  AttachedFiles(this.files);

  factory AttachedFiles.fromJson(Map<String, dynamic> json) => _$AttachedFilesFromJson(json);

  Map<String, dynamic> toJson() => _$AttachedFilesToJson(this);
}
@JsonSerializable(explicitToJson: true)
class AttachedFile
{
  @JsonKey(name: "original_name")
  String originalName;
  @JsonKey(name: "export_name")
  String exportName;

  AttachedFile(this.originalName, this.exportName);

  factory AttachedFile.fromJson(Map<String, dynamic> json) => _$AttachedFileFromJson(json);

  Map<String, dynamic> toJson() => _$AttachedFileToJson(this);
}

// Reaction Classes
//------------------
@JsonSerializable(explicitToJson: true)
class Reaction
{
  @JsonKey(name: "reactor_emails")
  List<String> reactorEmails;

  ReactionEmoji emoji;

  Reaction(this.reactorEmails, this.emoji);

  factory Reaction.fromJson(Map<String, dynamic> json) => _$ReactionFromJson(json);

  Map<String, dynamic> toJson() => _$ReactionToJson(this);
}
@JsonSerializable(explicitToJson: true)
class ReactionEmoji
{
  String unicode;

  ReactionEmoji(this.unicode);

  factory ReactionEmoji.fromJson(Map<String, dynamic> json) => _$ReactionEmojiFromJson(json);

  Map<String, dynamic> toJson() => _$ReactionEmojiToJson(this);
}

// Creator Classes
//-----------------
class _CreatorConverter implements JsonConverter<Creator, Map<String, dynamic>>
{
  const _CreatorConverter();

  @override
  fromJson(Map<String, dynamic> json)
  {
    if (json.containsKey("email"))
    {
      return HumanCreator(
        json["name"] as String, 
        json["email"] as String
      );
    }
    else
    {
      return BotCreator(
        json["name"] as String
      );
    }
  }

  @override
  Map<String, dynamic> toJson(Creator creator)
  {
    Map<String, dynamic> json = {};

    json["name"] = creator.name;
    json["type"] = creator.type;

    if (creator is HumanCreator)
    {
      json["email"] = creator.email;
    }

    return json;
  }
}

abstract class Creator
{
  String get type;
  String get name;
}

class HumanCreator extends Creator
{
  @override
  String type = "Human";
  @override
  String name;
  String email;

  HumanCreator(this.name, this.email);
}

class BotCreator extends Creator
{
  @override
  String type = "Bot";
  @override
  String name;

  BotCreator(this.name);
}