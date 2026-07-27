import 'package:json_annotation/json_annotation.dart';

part 'messages_json.g.dart';

@JsonSerializable(explicitToJson: true)
class ChatData {
  ChatData(this.messages);

  List<Message> messages;

  factory ChatData.fromJson(Map<String, dynamic> json) => _$ChatDataFromJson(json);

  Map<String, dynamic> toJson() => _$ChatDataToJson(this);
}


@JsonSerializable(explicitToJson: true)
class Message {

  @_CreatorConverter()
  final Creator creator;

  //TODO: Parse different message types instead of nullable options

  @JsonKey(name: 'created_date')
  String? createdDate;

  String? text;

  @JsonKey(name: 'topic_id')
  String? topicId;

  @JsonKey(name: 'message_id')
  String? messageId;

  Message({required this.creator, this.text, this.createdDate, this.topicId, this.messageId});

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

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