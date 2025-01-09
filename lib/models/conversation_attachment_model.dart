class ConversationAttachment {
  final String id;
  final String conversationId;
  final String messageId;
  final String contentUrl;
  final String fileName;
  final int? size;
  final String? thumbnailUrl;
  final int? type;

  ConversationAttachment({
    required this.id,
    required this.conversationId,
    required this.messageId,
    required this.contentUrl,
    required this.fileName,
    this.size,
    this.thumbnailUrl,
    this.type = 2,
  });

  factory ConversationAttachment.fromJson(Map<String, dynamic> json) =>
    ConversationAttachment(
      id: json["id"],
      conversationId: json["conversation_id"],
      messageId: json["message_id"],
      contentUrl: json["content_url"],
      fileName: json["file_name"],
      size: json["size"],
      thumbnailUrl: json["thumbnail_url"],
      type: json["type"],
    );

  Map<String, dynamic> toJson() => {
    "id": id,
    "conversation_id": conversationId,
    "message_id": messageId,
    "content_url": contentUrl,
    "file_name": fileName,
    "size": size,
    "thumbnail_url": thumbnailUrl,
    "type": type,
  };

  AttachmentType convertIntToAttType(int? intType) {
    switch (intType) {
      case 0:
        return AttachmentType.image;
      case 1:
        return AttachmentType.video;
      case 2:
        return AttachmentType.file;
      default:
        return AttachmentType.file;
    }
  }
}

enum AttachmentType { image, video, file }
