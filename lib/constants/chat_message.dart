class ChatMessage {
  String messageContent;
  String messageType;
  ChatMessage({required this.messageContent, required this.messageType});

  static List<ChatMessage> listMessage = [
    ChatMessage(messageContent: "Tôi có thể giúp gì cho bạn?", messageType: "receiver"),
    // ChatMessage(messageContent: "Buổi sáng vui vẻ", messageType: "receiver"),
    // ChatMessage(messageContent: "Cảm ơn.", messageType: "sender"),
    // ChatMessage(messageContent: "ok", messageType: "receiver"),
    // ChatMessage(messageContent: "ok", messageType: "receiver"),
  ];
}
