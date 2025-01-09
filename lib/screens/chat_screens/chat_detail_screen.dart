import 'package:fmecg_mobile/certs/secrets.dart';
import 'package:fmecg_mobile/constants/chat_message.dart';
import 'package:fmecg_mobile/constants/chat_user.dart';
import 'package:fmecg_mobile/constants/color_constant.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';

class ChatDetailScreen extends StatefulWidget {
  final int indexSelect;
  const ChatDetailScreen({
    super.key,
    required this.indexSelect,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final List<OpenAIChatCompletionChoiceMessageModel> _userMessages = [];
  String textGen = "";
  bool isCreateNewMessage = true;
  @override
  void initState() {
    super.initState();
    OpenAI.apiKey = Secrets.chatGPTToken;
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  _createUserMessageOpenAI(String prompt) {
    final OpenAIChatCompletionChoiceMessageModel message = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt)
      ],
      role: OpenAIChatMessageRole.user,
    );
    return message;
  }

  _completeChat(String prompt) {
    final OpenAIChatCompletionChoiceMessageModel newMessage = _createUserMessageOpenAI(prompt);
    _userMessages.add(newMessage);

    Stream<OpenAIStreamChatCompletionModel> chatStream = OpenAI.instance.chat.createStream(
      model: "gpt-3.5-turbo",
      messages: _userMessages,
      seed: 279,
      n: 1,
    );

    chatStream.listen(_listenOpenAIChat,
      onError: (error) {
        print(error);
        setState(() => isCreateNewMessage = true);
      },
      cancelOnError: false,
      onDone: () {
        setState(() => isCreateNewMessage = true);
        textGen = "";
        _scrollToBottom();
      },
    );
  }

  _listenOpenAIChat(OpenAIStreamChatCompletionModel streamData) {
      final List<OpenAIChatCompletionChoiceMessageContentItemModel?>? content = streamData.choices.first.delta.content;
      if (content == null || content.isEmpty) return;
      final String type = content.first!.type;
      final String? textCompletion = content.first!.text;
      if (type != "text" || textCompletion == null) return;
      textGen += textCompletion;

      setState(() {
        if (isCreateNewMessage) {
          ChatMessage.listMessage.add(
            ChatMessage(
                messageContent: textGen,
                messageType: "receiver"),
          );
          isCreateNewMessage = false;
        } else {
          final lastMessage = ChatMessage.listMessage.last;
          lastMessage.messageContent = textGen;
        }
      });

    }

  _scrollToBottom() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent + 60,
      duration: const Duration(milliseconds: 50),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
          child: Container(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  width: 2,
                ),
                CircleAvatar(
                  backgroundImage: NetworkImage(
                      ChatUsers.chatUsers[widget.indexSelect].imageUrl),
                  maxRadius: 20,
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        ChatUsers.chatUsers[widget.indexSelect].name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Text(
                        "Trực tuyến",
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.settings,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: ChatMessage.listMessage.length,
                shrinkWrap: true,
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                physics: const ClampingScrollPhysics(),
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.only(
                        left: 14, right: 14, top: 10, bottom: 10),
                    child: Align(
                      alignment: (ChatMessage.listMessage[index].messageType ==
                              "receiver"
                          ? Alignment.topLeft
                          : Alignment.topRight),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: (ChatMessage.listMessage[index].messageType ==
                                  "receiver"
                              ? Colors.grey.shade200
                              : Colors.blue[200]),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          ChatMessage.listMessage[index].messageContent,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: const EdgeInsets.only(left: 10, bottom: 10, top: 10),
                height: 60,
                decoration: const BoxDecoration(
                    color: ColorConstant.surfaceVariant,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Row(
                  children: <Widget>[
                    Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                            hintText: "Nhập tin nhắn...",
                            hintStyle: TextStyle(color: Colors.black54),
                            border: InputBorder.none
                        ),
                        onChanged: (value) => setState(() {}),
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    IconButton(
                      onPressed: controller.text.isEmpty ? null : () {
                        final String text = controller.text;
                        _completeChat(text);
                        setState(() {
                          ChatMessage.listMessage.add(
                            ChatMessage(
                                messageContent: text,
                                messageType: "sender"),
                          );
                        });
                        controller.clear();
                        Future.delayed(const Duration(milliseconds: 200), () {
                          _scrollToBottom();
                        });
                      },
                      icon: Icon(
                        Icons.send,
                        color: controller.text.isEmpty ? Colors.grey : Colors.blue,
                        size: 23,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
