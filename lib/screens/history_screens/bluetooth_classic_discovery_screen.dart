// import 'dart:async';

// import 'package:fmecg_mobile/screens/history_screens/bluetooth_classic_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import 'package:fluttertoast/fluttertoast.dart';

// class DiscoveryPage extends StatefulWidget {
//   /// If true, discovery starts on page start, otherwise user must press action button.
//   final bool start;

//   const DiscoveryPage({super.key, this.start = true});

//   @override
//   _DiscoveryPage createState() => _DiscoveryPage();
// }

// class _DiscoveryPage extends State<DiscoveryPage> {
//   StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
//   List<BluetoothDiscoveryResult> results =
//       List<BluetoothDiscoveryResult>.empty(growable: true);
//   bool isDiscovering = false;

//   _DiscoveryPage();

//   @override
//   void initState() {
//     super.initState();

//     isDiscovering = widget.start;
//     if (isDiscovering) {
//       _startDiscovery();
//     }
//   }

//   void _restartDiscovery() {
//     setState(() {
//       results.clear();
//       isDiscovering = true;
//     });

//     _startDiscovery();
//   }

//   void _startDiscovery() {
//     _streamSubscription =
//         FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
//       setState(() {
//         final existingIndex = results.indexWhere(
//             (element) => element.device.address == r.device.address);
//         if (existingIndex >= 0) {
//           results[existingIndex] = r;
//         } else if (r.rssi >= - 80 && r.device.name != null) {
//           results.add(r);
//         }
//       });
//     });

//     _streamSubscription!.onDone(() {
//       setState(() {
//         isDiscovering = false;
//       });
//     });
//   }

//   // @TODO . One day there should be `_pairDevice` on long tap on something... ;)

//   @override
//   void dispose() {
//     // Avoid memory leak (`setState` after dispose) and cancel discovery
//     _streamSubscription?.cancel();

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: isDiscovering
//             ? const Text('Discovering devices')
//             : const Text('Discovered devices'),
//         actions: <Widget>[
//           isDiscovering
//               ? FittedBox(
//                   child: Container(
//                     margin: const EdgeInsets.all(16.0),
//                     child: CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.black.withOpacity(0.8)),
//                     ),
//                   ),
//                 )
//               : IconButton(
//                   icon: const Icon(Icons.replay),
//                   onPressed: _restartDiscovery,
//                 )
//         ],
//       ),
//       body: ListView.builder(
//         itemCount: results.length,
//         itemBuilder: (BuildContext context, index) {
//           BluetoothDiscoveryResult result = results[index];
//           final device = result.device;
//           final address = device.address;
//           return BluetoothDeviceListEntry(
//             device: device,
//             rssi: result.rssi,
//             onTap: () async {
//               try {
//                 bool bonded = false;
//                 if (device.isBonded) {
//                   await FlutterBluetoothSerial.instance.removeDeviceBondWithAddress(address);
//                   Fluttertoast.showToast(
//                     msg: "Unpaired ${device.name} successfully",
//                     toastLength: Toast.LENGTH_SHORT,
//                     gravity: ToastGravity.BOTTOM,
//                     timeInSecForIosWeb: 1,
//                     backgroundColor: const Color(0xffDBDBDB),
//                     textColor: const Color(0xff2E2E2E),
//                     fontSize: 16.0
//                   );

//                 } else {
//                   bonded = (await FlutterBluetoothSerial.instance
//                       .bondDeviceAtAddress(address))!;
//                   if (bonded) {
//                     Fluttertoast.showToast(
//                       msg: "Pair with ${device.name} successfully",
//                       toastLength: Toast.LENGTH_SHORT,
//                       gravity: ToastGravity.BOTTOM,
//                       timeInSecForIosWeb: 1,
//                       backgroundColor: const Color(0xffDBDBDB),
//                       textColor: const Color(0xff2E2E2E),
//                       fontSize: 16.0
//                     );
//                   }
//                 }
//                 setState(() {
//                   results[index] = BluetoothDiscoveryResult(
//                       device: BluetoothDevice(
//                         name: device.name ?? '',
//                         address: address,
//                         type: device.type,
//                         bondState: bonded
//                             ? BluetoothBondState.bonded
//                             : BluetoothBondState.none,
//                       ),
//                       rssi: result.rssi);
//                 });
//               } catch (ex) {
//                 showDialog(
//                   context: context,
//                   builder: (BuildContext context) {
//                     return AlertDialog(
//                       title: const Text('Error occured while bonding'),
//                       content: Text(ex.toString()),
//                       actions: <Widget>[
//                         TextButton(
//                           child: const Text("Close"),
//                           onPressed: () {
//                             Navigator.of(context).pop();
//                           },
//                         ),
//                       ],
//                     );
//                   },
//                 );
//               }
//             },
//           );
//         },
//       ),
//     );
//   }
// }
