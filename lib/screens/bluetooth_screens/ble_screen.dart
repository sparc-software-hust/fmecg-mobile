import 'dart:async';
import 'dart:io';
import 'package:fmecg_mobile/screens/bluetooth_screens/bluetooth_off_screen.dart';
import 'package:fmecg_mobile/screens/bluetooth_screens/ble_scanning_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

Uuid uartUUID = Uuid.parse("6E400001-B5A3-F393-E0A9-E50E24DCCA9E");
Uuid uartRX = Uuid.parse("6E400002-B5A3-F393-E0A9-E50E24DCCA9E");
Uuid uartTX = Uuid.parse("6E400003-B5A3-F393-E0A9-E50E24DCCA9E");

class BleReactiveScreen extends StatefulWidget {
  const BleReactiveScreen({Key? key}) : super(key: key);

  @override
  _BleReactiveScreenState createState() => _BleReactiveScreenState();
}

class _BleReactiveScreenState extends State<BleReactiveScreen> {
  final flutterReactiveBle = FlutterReactiveBle();
  List<DiscoveredDevice> devices = [];

  @override
  void initState() {
    requestBluetoothPermission();
    super.initState();
  }

  Future<void> requestBluetoothPermission() async {
    final List<Permission> permissionsPlatform =
        Platform.isAndroid
            ? [Permission.bluetoothConnect, Permission.bluetoothScan]
            : Platform.isIOS
            ? [Permission.bluetooth]
            : [];
    final status = await permissionsPlatform.request();
    for (PermissionStatus value in status.values) {
      if (value.isDenied) {
        //show popup
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<BleStatus>(
        stream: flutterReactiveBle.statusStream,
        initialData: BleStatus.unknown,
        builder: (c, snapshot) {
          final state = snapshot.data;
          if (state == BleStatus.ready) {
            return const BleConnectionScreen();
          } else {
            return BluetoothOffScreen(state: state);
          }
        },
      ),
    );
  }
}
