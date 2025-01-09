// import 'dart:async';

// import 'package:fmecg_mobile/screens/history_screens/bluetooth_classic_data_exchange_screen.dart';
// import 'package:fmecg_mobile/screens/history_screens/bluetooth_classic_discovery_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import 'package:fluttertoast/fluttertoast.dart';

// class BluetoothClassicScreen extends StatefulWidget {
//   const BluetoothClassicScreen({super.key});

//   @override
//   _BluetoothClassicScreen createState() => _BluetoothClassicScreen();
// }

// class _BluetoothClassicScreen extends State<BluetoothClassicScreen> {
//   BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
//   List<BluetoothDevice> bondedDevices = [];
//   String _address = "...";
//   String _name = "...";

//   Timer? _discoverableTimeoutTimer;
//   int _discoverableTimeoutSecondsLeft = 0;

//   @override
//   void initState() {
//     super.initState();

//     // Get current state
//     FlutterBluetoothSerial.instance.state.then((state) {
//       setState(() {
//         _bluetoothState = state;
//       });

//     FlutterBluetoothSerial.instance
//         .getBondedDevices()
//         .then((List<BluetoothDevice> bondedDevices) {
//       setState(() {
//         this.bondedDevices = bondedDevices;
//       });
//     });
//     });

//     Future.doWhile(() async {
//       // Wait if adapter not enabled
//       if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
//         return false;
//       }
//       await Future.delayed(const Duration(milliseconds: 0xDD));
//       return true;
//     }).then((_) {
//       // Update the address field
//       FlutterBluetoothSerial.instance.address.then((address) {
//         setState(() {
//           _address = address!;
//         });
//       });
//     });

//     FlutterBluetoothSerial.instance.name.then((name) {
//       setState(() {
//         _name = name!;
//       });
//     });

//     // Listen for futher state changes
//     FlutterBluetoothSerial.instance
//         .onStateChanged()
//         .listen((BluetoothState state) {
//       setState(() {
//         _bluetoothState = state;

//         // Discoverable mode is disabled when Bluetooth gets disabled
//         _discoverableTimeoutTimer = null;
//         _discoverableTimeoutSecondsLeft = 0;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
//     _discoverableTimeoutTimer?.cancel();
//     super.dispose();
//   }

//   void showToastWarningTurnOnBluetooth() async {
//     Fluttertoast.showToast(
//         msg: "You need to turn on Bluetooth",
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//         timeInSecForIosWeb: 1,
//         backgroundColor: const Color(0xffDBDBDB),
//         textColor: const Color(0xff2E2E2E),
//         fontSize: 16.0);
//   }

//   @override
//   Widget build(BuildContext context) {
//     List<BluetoothDeviceListEntry> list = bondedDevices
//         .map((_device) => BluetoothDeviceListEntry(
//           device: _device,
//           enabled: true,
//           onTap: () async {
//             Navigator.of(context).push(
//               MaterialPageRoute(
//                 builder: (context) {
//                   return ChatPage(server: _device);
//                 },
//               )
//             );
//           },
//         ))
//         .toList();
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Flutter Bluetooth Serial'),
//       ),
//       body: ListView(
//         children: <Widget>[
//           SwitchListTile(
//               title: const Text('Enable Bluetooth'),
//               value: _bluetoothState.isEnabled,
//               onChanged: (bool value) async {
//                 // Do the request and update with the true value then
//                 if (value) {
//                   await FlutterBluetoothSerial.instance.requestEnable();
//                 } else {
//                   await FlutterBluetoothSerial.instance.requestDisable();
//                 }
//               }),
//           ListTile(
//             title: const Text('Bluetooth status'),
//             subtitle: Text(_bluetoothState.toString()),
//             trailing: ElevatedButton(
//               child: const Text('Settings'),
//               onPressed: () {
//                 FlutterBluetoothSerial.instance.openSettings();
//               },
//             ),
//           ),
//           ListTile(
//             title: const Text('Local adapter address'),
//             subtitle: Text(_address),
//           ),
//           ListTile(
//             title: const Text('Local adapter name'),
//             subtitle: Text(_name),
//             onLongPress: null,
//           ),
//           const Divider(),
//           const ListTile(title: Text('Paired devices')),
//           if (bondedDevices.isNotEmpty)
//           ListView(children: list, shrinkWrap: true,),
//           ListTile(
//             title: ElevatedButton(
//               child: const Text('Connect to paired device to chat'),
//               onPressed: () async {
//                 final bool hasOn =
//                     (await FlutterBluetoothSerial.instance.isEnabled) ??
//                         false;
//                 if (!hasOn) {
//                   showToastWarningTurnOnBluetooth();
//                   return;
//                 }
//                 final BluetoothDevice? selectedDevice =
//                     await Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (context) {
//                       return const SelectBondedDevicePage(checkAvailability: false);
//                     },
//                   ),
//                 );
//                 if (selectedDevice != null) {
//                   print('Connect -> selected ' + selectedDevice.address);
//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (context) {
//                         return ChatPage(server: selectedDevice);
//                       },
//                     ),
//                   );
//                 } else {
//                   print('Connect -> no device selected');
//                 }
//               },
//             ),
//           ),
//           const Divider(),
//           ListTile(
//             title: _discoverableTimeoutSecondsLeft == 0
//                 ? const Text("Discoverable")
//                 : Text(
//                     "Discoverable for ${_discoverableTimeoutSecondsLeft}s"),
//             trailing: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Checkbox(
//                   value: _discoverableTimeoutSecondsLeft != 0,
//                   onChanged: null,
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.refresh),
//                   onPressed: () async {
//                     print('Discoverable requested');
//                     final int timeout = (await FlutterBluetoothSerial.instance
//                         .requestDiscoverable(60))!;
//                     if (timeout < 0) {
//                       print('Discoverable mode denied');
//                     } else {
//                       print(
//                           'Discoverable mode acquired for $timeout seconds');
//                     }
//                     setState(() {
//                       _discoverableTimeoutTimer?.cancel();
//                       _discoverableTimeoutSecondsLeft = timeout;
//                       _discoverableTimeoutTimer =
//                           Timer.periodic(const Duration(seconds: 1), (Timer timer) {
//                         setState(() {
//                           if (_discoverableTimeoutSecondsLeft < 0) {
//                             FlutterBluetoothSerial.instance.isDiscoverable
//                                 .then((isDiscoverable) {
//                               if (isDiscoverable ?? false) {
//                                 print(
//                                     "Discoverable after timeout... might be infinity timeout :F");
//                                 _discoverableTimeoutSecondsLeft += 1;
//                               }
//                             });
//                             timer.cancel();
//                             _discoverableTimeoutSecondsLeft = 0;
//                           } else {
//                             _discoverableTimeoutSecondsLeft -= 1;
//                           }
//                         });
//                       });
//                     });
//                   },
//                 )
//               ],
//             ),
//           ),
//           ListTile(
//             title: ElevatedButton(
//                 child: const Text('Explore discovered devices'),
//                 onPressed: () async {
//                   final bool hasOn =
//                       (await FlutterBluetoothSerial.instance.isEnabled) ??
//                           false;
//                   if (!hasOn) {
//                     showToastWarningTurnOnBluetooth();
//                     return;
//                   }
//                   final BluetoothDevice? selectedDevice =
//                       await Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (context) {
//                         return const DiscoveryPage();
//                       },
//                     ),
//                   );
      
//                   if (selectedDevice != null) {
//                     print('Discovery -> selected ' + selectedDevice.address);
//                   } else {
//                     print('Discovery -> no device selected');
//                   }
//                 }),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class BluetoothDeviceListEntry extends ListTile {
//   BluetoothDeviceListEntry({
//     super.key,
//     required BluetoothDevice device,
//     int? rssi,
//     GestureTapCallback? onTap,
//     GestureLongPressCallback? onLongPress,
//     bool enabled = true,
//   }) : super(
//           onTap: onTap,
//           onLongPress: onLongPress,
//           enabled: enabled,
//           leading:
//               const Icon(Icons.devices), // @TODO . !BluetoothClass! class aware icon
//           title: Text(device.name ?? "Unknown device"),
//           subtitle: Text(device.address.toString()),
//           trailing: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               rssi != null
//                   ? Container(
//                       margin: const EdgeInsets.all(8.0),
//                       child: DefaultTextStyle(
//                         style: _computeTextStyle(rssi),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: <Widget>[
//                             Text(rssi.toString()),
//                             const Text('dBm'),
//                           ],
//                         ),
//                       ),
//                     )
//                   : const SizedBox(width: 0, height: 0),
//               device.isConnected
//                   ? const Icon(Icons.abc)
//                   : const SizedBox(width: 0, height: 0),
//               device.isBonded
//                   ? const Icon(Icons.link)
//                   : const SizedBox(width: 0, height: 0),
//             ],
//           ),
//         );

//   static TextStyle _computeTextStyle(int rssi) {
//     /**/ if (rssi >= -35) {
//       return TextStyle(color: Colors.greenAccent[700]);
//     } else if (rssi >= -45) {
//       return TextStyle(
//           color: Color.lerp(
//               Colors.greenAccent[700], Colors.lightGreen, -(rssi + 35) / 10));
//     } else if (rssi >= -55) {
//       return TextStyle(
//           color: Color.lerp(
//               Colors.lightGreen, Colors.lime[600], -(rssi + 45) / 10));
//     } else if (rssi >= -65) {
//       return TextStyle(
//           color: Color.lerp(Colors.lime[600], Colors.amber, -(rssi + 55) / 10));
//     } else if (rssi >= -75) {
//       return TextStyle(
//           color: Color.lerp(
//               Colors.amber, Colors.deepOrangeAccent, -(rssi + 65) / 10));
//     } else if (rssi >= -85) {
//       return TextStyle(
//           color: Color.lerp(
//               Colors.deepOrangeAccent, Colors.redAccent, -(rssi + 75) / 10));
//     } else {
//       return const TextStyle(color: Colors.redAccent);
//     }
//   }
// }

// class SelectBondedDevicePage extends StatefulWidget {
//   /// If true, on page start there is performed discovery upon the bonded devices.
//   /// Then, if they are not avaliable, they would be disabled from the selection.
//   final bool checkAvailability;

//   const SelectBondedDevicePage({super.key, this.checkAvailability = true});

//   @override
//   _SelectBondedDevicePage createState() => _SelectBondedDevicePage();
// }

// enum _DeviceAvailability {
//   no,
//   maybe,
//   yes,
// }

// class _DeviceWithAvailability {
//   BluetoothDevice device;
//   _DeviceAvailability availability;
//   int? rssi;

//   _DeviceWithAvailability(this.device, this.availability);
// }

// class _SelectBondedDevicePage extends State<SelectBondedDevicePage> {
//   List<_DeviceWithAvailability> devices =
//       List<_DeviceWithAvailability>.empty(growable: true);

//   // Availability
//   StreamSubscription<BluetoothDiscoveryResult>? _discoveryStreamSubscription;
//   bool _isDiscovering = false;

//   _SelectBondedDevicePage();

//   @override
//   void initState() {
//     super.initState();

//     _isDiscovering = widget.checkAvailability;

//     if (_isDiscovering) {
//       _startDiscovery();
//     }

//     // Setup a list of the bonded devices
//     FlutterBluetoothSerial.instance
//         .getBondedDevices()
//         .then((List<BluetoothDevice> bondedDevices) {
//       setState(() {
//         devices = bondedDevices
//             .map(
//               (device) => _DeviceWithAvailability(
//                 device,
//                 widget.checkAvailability
//                     ? _DeviceAvailability.maybe
//                     : _DeviceAvailability.yes,
//               ),
//             )
//             .toList();
//       });
//     });
//   }

//   void _restartDiscovery() {
//     setState(() {
//       _isDiscovering = true;
//     });

//     _startDiscovery();
//   }

//   void _startDiscovery() {
//     _discoveryStreamSubscription =
//         FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
//       setState(() {
//         Iterator i = devices.iterator;
//         while (i.moveNext()) {
//           var _device = i.current;
//           if (_device.device == r.device) {
//             _device.availability = _DeviceAvailability.yes;
//             _device.rssi = r.rssi;
//           }
//         }
//       });
//     });

//     _discoveryStreamSubscription?.onDone(() {
//       setState(() {
//         _isDiscovering = false;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _discoveryStreamSubscription?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     List<BluetoothDeviceListEntry> list = devices
//         .map((_device) => BluetoothDeviceListEntry(
//               device: _device.device,
//               rssi: _device.rssi,
//               enabled: _device.availability == _DeviceAvailability.yes,
//               onTap: () {
//                 Navigator.of(context).pop(_device.device);
//               },
//             ))
//         .toList();
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Select device'),
//         actions: <Widget>[
//           _isDiscovering
//               ? FittedBox(
//                   child: Container(
//                     margin: const EdgeInsets.all(16.0),
//                     child: const CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(
//                         Colors.white,
//                       ),
//                     ),
//                   ),
//                 )
//               : IconButton(
//                   icon: const Icon(Icons.replay),
//                   onPressed: _restartDiscovery,
//                 )
//         ],
//       ),
//       body: ListView(children: list),
//     );
//   }
// }
