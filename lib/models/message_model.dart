class MessageModel {
  String? messageId;
  String? senderId;
  int? timestamp;
  DefaultMessage? defaultMessage;
  Reaction? reaction;

  MessageModel({this.messageId, this.senderId, this.timestamp, this.defaultMessage, this.reaction});

  MessageModel.fromJson(Map<String, dynamic> json) {
    messageId = json['messageId'];
    senderId = json['senderId'];
    timestamp = json['timestamp'];
    defaultMessage =
        json['defaultMessage'] != null ? DefaultMessage.fromJson(json['defaultMessage']) : null;
    reaction = json['reaction'] != null ? Reaction.fromJson(json['reaction']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['messageId'] = messageId;
    data['senderId'] = senderId;
    data['timestamp'] = DateTime.now().millisecondsSinceEpoch;
    if (defaultMessage != null) {
      data['defaultMessage'] = defaultMessage!.toJson();
    }
    if (reaction != null) {
      data['reaction'] = reaction!.toJson();
    }
    return data;
  }
}

class DefaultMessage {
  String? text;
  String? fileUrl;

  DefaultMessage({this.text, this.fileUrl});

  DefaultMessage.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    fileUrl = json['file_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    data['file_url'] = fileUrl;
    return data;
  }
}

class Reaction {
  String? messageIdOfReaction;
  String? reactionUrl;

  Reaction({this.messageIdOfReaction, this.reactionUrl});

  Reaction.fromJson(Map<String, dynamic> json) {
    messageIdOfReaction = json['messageIdOfReaction'];
    reactionUrl = json['reaction_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['messageIdOfReaction'] = messageIdOfReaction;
    data['reaction_url'] = reactionUrl;
    return data;
  }
}
