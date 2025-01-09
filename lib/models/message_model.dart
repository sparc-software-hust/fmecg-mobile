class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final bool systemMessage;
  final bool pin;
  final DateTime? pinTime;
  final DateTime insertedAt;
  final DateTime? updatedAt;
  final List<Map> attachments;
  final List<Map> reactions;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.systemMessage = false,
    this.pin = false,
    this.pinTime,
    required this.insertedAt,
    this.updatedAt,
    this.attachments = const [],
    this.reactions = const []
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json["id"],
    conversationId: json["conversation_id"],
    senderId: json["sender_id"],
    systemMessage: json["system_message"],
    pin: json["pin"],
    pinTime: DateTime.tryParse(json["pin_time"]),
    insertedAt: DateTime.parse(json["inserted_at"]),
    updatedAt: DateTime.tryParse(json["updated_at"]),
    attachments: json["attachments"],
    reactions: json["reactions"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "conversation_id": conversationId,
    "sender_id": senderId,
    "system_message": systemMessage,
    "pin": pin,
    "pin_time": pinTime?.toIso8601String(),
    "inserted_at": insertedAt.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "attachments": attachments,
    "reactions": reactions
  };
}

