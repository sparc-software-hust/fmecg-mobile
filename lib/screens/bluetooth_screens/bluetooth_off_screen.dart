import 'dart:io';

import 'package:fmecg_mobile/constants/color_constant.dart';
import 'package:fmecg_mobile/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key? key, this.state}) : super(key: key);

  final BleStatus? state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.quaternary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              S.current.bluetoothStatusDes(state != null ? state.toString().substring(10) : 'not available'),
              style: Theme.of(context)
                  .primaryTextTheme
                  .titleSmall
                  ?.copyWith(color: Colors.white),
            ),
            // Text('Vui lòng bật Bluetooth để tiếp tục'),
            ElevatedButton(
              child: Text('${S.current.turnOn} Bluetooth'),
              onPressed: Platform.isAndroid
                  ? () => FlutterBluePlus.turnOn()
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
