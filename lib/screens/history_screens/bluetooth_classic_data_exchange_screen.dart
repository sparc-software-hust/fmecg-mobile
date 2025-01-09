// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

// import 'package:fmecg_mobile/screens/history_screens/pick_files_screen.dart';
// import 'package:fmecg_mobile/utils/files_management.dart';
// import 'package:fmecg_mobile/utils/utils.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

// class ChatPage extends StatefulWidget {
//   final BluetoothDevice server;

//   const ChatPage({super.key, required this.server});

//   @override
//   _ChatPage createState() => _ChatPage();
// }

// class _Message {
//   int whom;
//   String text;

//   _Message(this.whom, this.text);
// }

// class _ChatPage extends State<ChatPage> {
//   static const platform = MethodChannel("com.example.method_channel/java");
//   static const clientID = 0;
//   BluetoothConnection? connection;

//   List<_Message> messages = List<_Message>.empty(growable: true);
//   String _messageBuffer = '';
//   List dataToFile = [];
//   late File fileSum;

//   final TextEditingController textEditingController = TextEditingController();
//   final ScrollController listScrollController = ScrollController();

//   bool isConnecting = true;
//   bool get isConnected => (connection?.isConnected ?? false);

//   bool isDisconnecting = false;
//   bool isWritingData = false;

//   @override
//   void initState() {
//     super.initState();
//     initSetupFile();
//     BluetoothConnection.toAddress(widget.server.address).then((_connection) {
//       print('Connected to the device');
//       connection = _connection;
//       setState(() {
//         isConnecting = false;
//         isDisconnecting = false;
//       });

//       connection!.input!.listen(_onDataReceived).onDone(() async {
//         // Example: Detect which side closed the connection
//         // There should be `isDisconnecting` flag to show are we are (locally)
//         // in middle of disconnecting process, should be set before calling
//         // `dispose`, `finish` or `close`, which all causes to disconnect.
//         // If we except the disconnection, `onDone` should be fired as result.
//         // If we didn't except this (no flag set), it means closing by remote.

//         // if (isDisconnecting) {
//         //   print('Disconnecting locally!');
//         // } else {
//         //   print('Disconnected remotely!');
//         // }
//         setState(() => isWritingData = true);
//         await FilesManagement.handleSaveDataToFileV2(fileSum, dataToFile);
//         setState(() => isWritingData = false);
//         Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => Material(child: PickFiles(txtPath: fileSum.path))));


//       });
//     }).catchError((error) {
//       print('Cannot connect, exception occured');
//       print(error);
//     });
//   }

//   @override
//   void dispose() {
//     if (isConnected) {
//       isDisconnecting = true;
//       connection?.dispose();
//       connection = null;
//     }

//     super.dispose();
//   }

//   initSetupFile() async {
//     final bool hasAccessFiles = await Utils.requestManageStorage();
//     if (!hasAccessFiles) {
//       return Utils.showDialogWarningError(context, true, "Vui lòng cấp quyền truy cập file cho App!");
//     }
//     await FilesManagement.createDirectoryFirstTimeWithDevice();
//     fileSum = await FilesManagement.setUpFileSaveTxt();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final List<Row> list = messages.map((_message) {
//       return Row(
//         children: <Widget>[
//           Container(
//             child: Text(
//                 (text) {
//                   return text == '/shrug' ? '¯\\_(ツ)_/¯' : text;
//                 }(_message.text.trim()),
//                 style: const TextStyle(color: Colors.white)),
//             padding: const EdgeInsets.all(12.0),
//             margin: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
//             width: 222.0,
//             decoration: BoxDecoration(
//                 color:
//                     _message.whom == clientID ? Colors.blueAccent : Colors.grey,
//                 borderRadius: BorderRadius.circular(7.0)),
//           ),
//         ],
//         mainAxisAlignment: _message.whom == clientID
//             ? MainAxisAlignment.end
//             : MainAxisAlignment.start,
//       );
//     }).toList();

//     final serverName = widget.server.name ?? "Unknown";
//     return Scaffold(
//       appBar: AppBar(
//           title: (isConnecting
//               ? Text('Connecting chat to ' + serverName + '...')
//               : isConnected
//                   ? Text('Live chat with ' + serverName)
//                   : Text('Chat log with ' + serverName))),
//       body: SafeArea(
//         child: Column(
//           children: <Widget>[
//             Flexible(
//               child: ListView(
//                   padding: const EdgeInsets.all(12.0),
//                   controller: listScrollController,
//                   children: list),
//             ),
//             Row(
//               children: <Widget>[
//                 Flexible(
//                   child: Container(
//                     margin: const EdgeInsets.only(left: 16.0),
//                     child: TextField(
//                       style: const TextStyle(fontSize: 15.0),
//                       controller: textEditingController,
//                       decoration: InputDecoration.collapsed(
//                         hintText: isConnecting
//                             ? 'Wait until connected...'
//                             : isConnected
//                                 ? 'Type your message...'
//                                 : isWritingData
//                                     ? "Writing data to files..."
//                                     : "Done. Disconnected.",
//                         hintStyle: const TextStyle(color: Colors.grey),
//                       ),
//                       enabled: isConnected,
//                     ),
//                   ),
//                 ),
//                 Container(
//                   margin: const EdgeInsets.all(8.0),
//                   child: IconButton(
//                       icon: const Icon(Icons.bluetooth_disabled_sharp),
//                       onPressed: isConnected
//                           ? () => connection?.finish()
//                           : null),
//                 ),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   void _onDataReceived(Uint8List data) {
//     // Allocate buffer for parsed data
//     int backspacesCounter = 0;
//     for (var byte in data) {
//       if (byte == 8 || byte == 127) {
//         backspacesCounter++;
//       }
//     }
//     Uint8List buffer = Uint8List(data.length - backspacesCounter);
//     int bufferIndex = buffer.length;

//     // Apply backspace control character
//     backspacesCounter = 0;
//     for (int i = data.length - 1; i >= 0; i--) {
//       if (data[i] == 8 || data[i] == 127) {
//         backspacesCounter++;
//       } else {
//         if (backspacesCounter > 0) {
//           backspacesCounter--;
//         } else {
//           buffer[--bufferIndex] = data[i];
//         }
//       }
//     }

//     String dataString = String.fromCharCodes(buffer);
//     dataToFile.add(dataString);
//     int index = buffer.indexOf(13);
//     if (~index != 0) {
//       setState(() {
//         messages.add(
//           _Message(
//             1,
//             backspacesCounter > 0
//                 ? _messageBuffer.substring(
//                     0, _messageBuffer.length - backspacesCounter)
//                 : _messageBuffer + dataString.substring(0, index),
//           ),
//         );
//         _messageBuffer = dataString.substring(index);
//       });
//     } else {
//       _messageBuffer = (backspacesCounter > 0
//           ? _messageBuffer.substring(
//               0, _messageBuffer.length - backspacesCounter)
//           : _messageBuffer + dataString);
//     }

//     Future.delayed(const Duration(milliseconds: 333)).then((_) {
//       listScrollController.animateTo(
//           listScrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 333),
//           curve: Curves.easeOut);
//     });
//   }

//   void _sendMessage(String text) async {
//     text = text.trim();
//     textEditingController.clear();

//     if (text.isNotEmpty) {
//       try {
//         connection!.output.add(Uint8List.fromList(utf8.encode(text + "\r\n")));
//         await connection!.output.allSent;

//         setState(() {
//           messages.add(_Message(clientID, text));
//         });

//         Future.delayed(const Duration(milliseconds: 333)).then((_) {
//           listScrollController.animateTo(
//               listScrollController.position.maxScrollExtent,
//               duration: const Duration(milliseconds: 333),
//               curve: Curves.easeOut);
//         });
//       } catch (e) {
//         // Ignore error, but notify state
//         setState(() {});
//       }
//     }
//   }
// }
