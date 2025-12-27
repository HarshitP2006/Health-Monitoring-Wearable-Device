import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/health_data.dart';
import 'ble_constants.dart';

class BleService {
  BluetoothDevice? _device;
  BluetoothCharacteristic? _notifyChar;

  final StreamController<HealthData> _dataController =
      StreamController<HealthData>.broadcast();

  Stream<HealthData> get dataStream => _dataController.stream;

  Future<void> init() async {
    await _requestPermissions();
    await _scanAndConnect();
    await _discoverAndSubscribe();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }

 Future<void> _scanAndConnect() async {
  print("BLE: Starting scan...");

  await FlutterBluePlus.startScan(
    timeout: const Duration(seconds: 8),
  );

  await for (final results in FlutterBluePlus.scanResults) {
    for (final r in results) {
      print("BLE: Found ${r.device.platformName}");

      if (r.device.platformName == deviceName) {
        print("BLE: ESP32 FOUND");

        await FlutterBluePlus.stopScan();
        _device = r.device;

        print("BLE: Connecting to ESP32...");
        await _device!.connect(autoConnect: false);
        print("BLE: CONNECTED");

        return;
      }
    }
  }
}

 Future<void> _discoverAndSubscribe() async {
  print("BLE: Discovering services...");

  final services = await _device!.discoverServices();

  for (final s in services) {
    print("BLE: Service ${s.uuid}");

    if (s.uuid == serviceUUID) {
      print("BLE: Target service found");

      for (final c in s.characteristics) {
        print("BLE: Characteristic ${c.uuid}");

        if (c.uuid == charUUID) {
          print("BLE: Notify characteristic found");

          _notifyChar = c;
          await _notifyChar!.setNotifyValue(true);

          print("BLE: Notifications enabled");
          _notifyChar!.lastValueStream.listen(_onData);

          return;
        }
      }
    }
  }

  throw Exception("BLE: Notify characteristic NOT FOUND");
}


void _onData(List<int> value) {
  final raw = String.fromCharCodes(value);
  print("BLE RAW DATA: $raw");

  try {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final data = HealthData.fromJson(map);
    _dataController.add(data);
  } catch (e) {
    print("BLE PARSE ERROR");
  }
}

  void dispose() {
    _dataController.close();
    _device?.disconnect();
  }
}
