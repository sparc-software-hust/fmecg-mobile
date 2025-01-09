class ConversationMember {
  final String id;
  final String conversationId;
  final int? statusNotification;
  final int? role;
  final bool? seen;

  ConversationMember({
    required this.id,
    required this.conversationId,
    this.statusNotification = 1,
    this.role = 1,
    this.seen = false,
  });

  factory ConversationMember.fromJson(Map<String, dynamic> json) =>
    ConversationMember(
      id: json["id"],
      conversationId: json["conversation_id"],
      statusNotification: json["status_notification"],
      role: json["role"],
      seen: json["seen"],
    );

  Map<String, dynamic> toJson() => {
    "id": id,
    "conversation_id": conversationId,
    "status_notification": statusNotification,
    "role": role,
    "seen": seen,
  };
}

enum StatusNotification { notify, silent }
enum ConversationMemberRole { creator, member }
