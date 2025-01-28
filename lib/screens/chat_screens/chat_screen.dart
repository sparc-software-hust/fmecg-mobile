import 'package:fmecg_mobile/constants/chat_user.dart';
import 'package:fmecg_mobile/constants/color_constant.dart';
import 'package:fmecg_mobile/networks/http_dio.dart';
import 'package:fmecg_mobile/networks/socket_channel.dart';
import 'package:fmecg_mobile/screens/chat_screens/chat_detail_screen.dart';
import 'package:flutter/material.dart';

class Doctor {
  final String id;
  final String accountId;
  final String username;
  final int gender;
  final int birth;
  final String phoneNumber;
  final String? image;
  final int statusId;
  final String information;
  final int roleId;

  Doctor({
    required this.id,
    required this.accountId,
    required this.username,
    required this.gender,
    required this.birth,
    required this.phoneNumber,
    this.image,
    required this.statusId,
    required this.information,
    required this.roleId,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] as String,
      accountId: json['account_id'] as String,
      username: json['username'] as String,
      gender: json['gender'] as int,
      birth: json['birth'] as int,
      phoneNumber: json['phone_number'] as String,
      image: json['image'] as String?,
      statusId: json['status_id'] as int,
      information: json['information'] as String,
      roleId: json['role_id'] as int,
    );
  }
}
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final SocketChannel socketChannel = SocketChannel();
  final TextEditingController searchController = TextEditingController();
  List<Doctor> doctorList = [];
  List<Doctor> filteredDoctors = [];

  @override
  void initState() {
    super.initState();
    fetchDoctors(); 
    searchController.addListener(() {
      filterDoctors(searchController.text);
    });

    socketChannel.on("new_message_conversation", (data, ref, joinRef) {
      print('dataaaa:$data');
    });
  }
  Future<void> fetchDoctors() async {
      try {
        final response = await dioConfigInterceptor.get('/users/doctors');
        setState(() {
          doctorList = (response.data as List)
              .map((doctor) => Doctor.fromJson(doctor as Map<String, dynamic>))
              .toList();
          filteredDoctors = List.from(doctorList);
        });
      } catch (e) {
        print('Error fetching doctors: $e');
      }
    }

 void filterDoctors(String query) {
    final filtered = doctorList
        .where((doctor) =>
            doctor.username.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      filteredDoctors = filtered;
    });
  }
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: ColorConstant.surface,
      appBar: AppBar(
        flexibleSpace: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        ),
        backgroundColor: ColorConstant.surface,
        toolbarHeight: size.height * 0.1,
        title: const Text(
          "Tin nhắn",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [
          IconButton(
              onPressed: null,
              icon: Icon(
                Icons.send,
                color: Colors.blue,
              ))
        ],
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
                    hintStyle:
                        const TextStyle(color: ColorConstant.onSurfaceVariant),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: ColorConstant.onSurfaceVariant,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: ColorConstant.surfaceVariant,
                    contentPadding: const EdgeInsets.all(8),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.grey.shade100)),
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
                          isMessageRead: (index != 0) ? true : false
                          
                          );
                    }),
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
              ChatDetailScreen(indexSelect: widget.index)));
      },
      child: Container(
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.imageUrl),
                    maxRadius: 30,
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.name,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Text(
                            widget.messageText,
                            style: TextStyle(
                                fontSize: 13,
                                color: !isRead
                                    ? Colors.black
                                    : Colors.grey.shade600,
                                fontWeight: !isRead
                                    ? FontWeight.bold
                                    : FontWeight.normal),
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
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: !isRead ? FontWeight.bold : FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}
