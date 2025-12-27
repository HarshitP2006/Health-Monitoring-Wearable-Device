class HealthData {
  final double ax, ay, az, acc;
  final bool fall;
  final double hr, spo2, temp;
  final int ecg;

  HealthData({
    required this.ax,
    required this.ay,
    required this.az,
    required this.acc,
    required this.fall,
    required this.hr,
    required this.spo2,
    required this.temp,
    required this.ecg,
  });

  factory HealthData.fromJson(Map<String, dynamic> j) {
    return HealthData(
      ax: (j['ax'] ?? 0).toDouble(),
      ay: (j['ay'] ?? 0).toDouble(),
      az: (j['az'] ?? 0).toDouble(),
      acc: (j['acc'] ?? 0).toDouble(),
      fall: (j['fall'] ?? 0) == 1,
      hr: (j['hr'] ?? 0).toDouble(),
      spo2: (j['spo2'] ?? 0).toDouble(),
      temp: (j['temp'] ?? 0).toDouble(),
      ecg: (j['ecg'] ?? 0).toInt(),
    );
  }
}
