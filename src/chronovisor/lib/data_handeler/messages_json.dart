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
  Message(this.creator, this.text, this.createdDate, this.topicId, this.messageId);

  Creator creator;

  //TODO: Parse different message types instead of nullable options

  @JsonKey(name: 'created_date')
  String? createdDate;

  String? text;

  @JsonKey(name: 'topic_id')
  String? topicId;

  @JsonKey(name: 'message_id')
  String? messageId;

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

@JsonSerializable()
class Creator {
  Creator(this.name, this.email, this.userType);

  String name;

  //Bots don't have an email
  String? email;

  @JsonKey(name: 'user_type')
  String userType;

  factory Creator.fromJson(Map<String, dynamic> json) => _$CreatorFromJson(json);

  Map<String, dynamic> toJson() => _$CreatorToJson(this);
}