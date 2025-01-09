class Conversation {
  final String id;
  final String? name;
  final int? type;
  final String? avatarUrl;
  final DateTime insertedAt;

  Conversation({
    required this.id,
    this.name,
    this.type,
    this.avatarUrl,
    required this.insertedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
    id: json["id"],
    name: json["name"],
    type: json["type"],
    avatarUrl: json["avatar_url"],
    insertedAt: json["inserted_at"] != null ? DateTime.parse(json["inserted_at"]) : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "type": type,
    "avatar_url": avatarUrl,
    "inserted_at": insertedAt.toIso8601String(),
  };
}
