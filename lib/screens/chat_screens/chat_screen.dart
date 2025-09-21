import 'package:fmecg_mobile/constants/chat_user.dart';
import 'package:fmecg_mobile/constants/color_constant.dart';
import 'package:fmecg_mobile/networks/socket_channel.dart';
import 'package:fmecg_mobile/screens/chat_screens/chat_detail_screen.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final SocketChannel socketChannel = SocketChannel();
  @override
  void initState() {
    super.initState();
    socketChannel.on("new_message_conversation", (data, ref, joinRef) {
      print('dataaaa:$data');
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: ColorConstant.surface,
      appBar: AppBar(
        flexibleSpace: GestureDetector(onTap: () => FocusManager.instance.primaryFocus?.unfocus()),
        backgroundColor: ColorConstant.surface,
        toolbarHeight: size.height * 0.1,
        title: const Text("Tin nhắn", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: const [IconButton(onPressed: null, icon: Icon(Icons.send, color: Colors.blue))],
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SizedBox(
          height: size.height,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Tìm bác sĩ...",
                    hintStyle: const TextStyle(color: ColorConstant.onSurfaceVariant),
                    prefixIcon: const Icon(Icons.search, color: ColorConstant.onSurfaceVariant, size: 20),
                    filled: true,
                    fillColor: ColorConstant.surfaceVariant,
                    contentPadding: const EdgeInsets.all(8),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.grey.shade100),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: ChatUsers.chatUsers.length,
                  padding: const EdgeInsets.only(top: 16),
                  itemBuilder: (context, index) {
                    return ConversationList(
                      index: index,
                      name: ChatUsers.chatUsers[index].name,
                      messageText: ChatUsers.chatUsers[index].message,
                      imageUrl: ChatUsers.chatUsers[index].imageUrl,
                      time: ChatUsers.chatUsers[index].time,
                      isMessageRead: (index != 0) ? true : false,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConversationList extends StatefulWidget {
  final String name;
  final String messageText;
  final String imageUrl;
  final String time;
  final bool isMessageRead;
  final int index;
  const ConversationList({
    super.key,
    required this.name,
    required this.messageText,
    required this.imageUrl,
    required this.time,
    required this.isMessageRead,
    required this.index,
  });
  @override
  State<ConversationList> createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {
  late bool isRead = widget.isMessageRead;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        setState(() {
          isRead = true;
        });
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatDetailScreen(indexSelect: widget.index)));
      },
      child: Container(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  CircleAvatar(backgroundImage: NetworkImage(widget.imageUrl), maxRadius: 30),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(widget.name, style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 6),
                          Text(
                            widget.messageText,
                            style: TextStyle(
                              fontSize: 13,
                              color: !isRead ? Colors.black : Colors.grey.shade600,
                              fontWeight: !isRead ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              widget.time,
              style: TextStyle(fontSize: 12, fontWeight: !isRead ? FontWeight.bold : FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}
