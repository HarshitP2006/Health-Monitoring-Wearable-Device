import 'package:flutter/material.dart';

import 'ble/ble_service.dart';
import 'models/health_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final BleService ble = BleService();

  HealthData? latest;
  bool connected = false;

  @override
  void initState() {
    super.initState();

    ble.init();

    ble.dataStream.listen((data) {
      setState(() {
        latest = data;
        connected = true; // ONLY set true when real data arrives
      });

      debugPrint(
        "HR:${data.hr} | "
        "SpO2:${data.spo2} | "
        "Temp:${data.temp} | "
        "Fall:${data.fall} | "
        "ECG:${data.ecg}",
      );
    });
  }

  @override
  void dispose() {
    ble.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Health Monitor"),
          centerTitle: true,
        ),
        body: Center(
          child: connected && latest != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "CONNECTED",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text("HR: ${latest!.hr}"),
                    Text("SpO₂: ${latest!.spo2}"),
                    Text("Temp: ${latest!.temp} °C"),
                    Text("ECG: ${latest!.ecg}"),
                    Text(
                      "Fall: ${latest!.fall ? "YES" : "NO"}",
                      style: TextStyle(
                        color: latest!.fall ? Colors.red : Colors.black,
                        fontWeight: latest!.fall ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                )
              : const Text(
                  "Connecting to ESP32...",
                  style: TextStyle(fontSize: 16),
                ),
        ),
      ),
    );
  }
}
