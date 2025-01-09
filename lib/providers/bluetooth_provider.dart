import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BluetoothProvider extends ChangeNotifier {
  DiscoveredDevice? deviceConnected;
  QualifiedCharacteristic? characteristicToReceiveData;

  void setDeviceConnected(DiscoveredDevice device) {
    deviceConnected = device;
    notifyListeners();
  }

  void setQualifiedCharacteristic(QualifiedCharacteristic characteristic) {
    characteristicToReceiveData = characteristic;
    notifyListeners();
  }
}