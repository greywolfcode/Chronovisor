import 'package:intl/intl.dart';

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
  @_DateConverter()
  DateTime? createdDate;
  @JsonKey(name: 'updated_date')
  @_DateConverter()
  DateTime? updatedDate;
  @JsonKey(name: 'topic_id')
  String? topicId;
  @JsonKey(name: 'message_id')
  String? messageId;
  @JsonKey(name: 'attached_files')
  List<AttachedFile>? attachedFiles;
  @JsonKey(name: 'previous_message_versions')
  List<Message>? previousMessageVersions;
  @JsonKey(name: 'quoted_message_metadata')
  List<Message>? quotedMessageMetadata;
  List<Reaction>? reactions;
  List<Annotation>? annotations;
  String? text;

  Message(this.creator, this.topicId, this.messageId);

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

// DateTime Classes
//------------------
class _DateConverter implements JsonConverter<DateTime, String>
{
  const _DateConverter();

  @override
  fromJson(String json)
  {
    return stringToDate(json);
  }

  @override
  String toJson(DateTime date)
  {
    return dateToString(date);
  }

  DateTime stringToDate(String date)
  {
    return DateFormat("EEEE, MMMM dd, yyyy 'at' h:mm:ss' 'a 'UTC'").parse(date, true);
  }
  String dateToString(DateTime date)
  {
    return DateFormat("EEEE, MMMM dd, yyyy 'at' h:mm:ss' 'a 'UTC'").format(date);
  }
}

// Annotations Classes
//---------------------
@JsonSerializable(explicitToJson: true)
class Annotation
{
  @JsonKey(name: 'url_metadata')
  UrlMetadata? urlMetadata; 
  @JsonKey(name: 'video_call_metadata')
  VideoCallMetadata? videoCallMetadata; 
  @JsonKey(name: 'format_metadata')
  FormatMetadata? formatMetadata; 
  @JsonKey(name: 'start_index')
  int startIndex; 
  int length;

  Annotation(this.startIndex, this.length, this.urlMetadata);

  factory Annotation.fromJson(Map<String, dynamic> json) => _$AnnotationFromJson(json);

  Map<String, dynamic> toJson() => _$AnnotationToJson(this);
}
@JsonSerializable(explicitToJson: true)
class UrlMetadata
{
  @JsonKey(name: 'image_url')
  String imageUrl; 
  String title;
  String snippet;
  UrlValue url;

  UrlMetadata(this.imageUrl, this.title, this.snippet, this.url);

  factory UrlMetadata.fromJson(Map<String, dynamic> json) => _$UrlMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$UrlMetadataToJson(this);
}
@JsonSerializable(explicitToJson: true)
class UrlValue
{
  @JsonKey(name: 'private_do_not_access_or_else_safe_url_wrapped_value')
  String privateDoNotAccessOrElseSafeUrlWrappedValue; 

  UrlValue(this.privateDoNotAccessOrElseSafeUrlWrappedValue);

  factory UrlValue.fromJson(Map<String, dynamic> json) => _$UrlValueFromJson(json);

  Map<String, dynamic> toJson() => _$UrlValueToJson(this);
}
@JsonSerializable(explicitToJson: true)
class VideoCallMetadata
{
  @JsonKey(name: 'meeting_space')
  MeetingSpace meetingSpace; 

  VideoCallMetadata(this.meetingSpace);

  factory VideoCallMetadata.fromJson(Map<String, dynamic> json) => _$VideoCallMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$VideoCallMetadataToJson(this);
}
@JsonSerializable(explicitToJson: true)
class MeetingSpace
{
  @JsonKey(name: 'meeting_url')
  String meetingUrl; 

  MeetingSpace(this.meetingUrl);

  factory MeetingSpace.fromJson(Map<String, dynamic> json) => _$MeetingSpaceFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingSpaceToJson(this);
}
@JsonSerializable(explicitToJson: true)
class FormatMetadata
{
  @JsonKey(name: 'format_type')
  String formatType; 

  FormatMetadata(this.formatType);

  factory FormatMetadata.fromJson(Map<String, dynamic> json) => _$FormatMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$FormatMetadataToJson(this);
}

// Attached Files Classes
//------------------------
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