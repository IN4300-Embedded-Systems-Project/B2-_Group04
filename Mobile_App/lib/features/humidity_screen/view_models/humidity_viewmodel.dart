import 'dart:async';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HumidityProvider extends ChangeNotifier {
  List<FlSpot> humidityData = [];
  double currentHumidity = 50; // Initial humidity value
  int time = 0;
  Timer? _timer;

  HumidityProvider() {
    _startFetchingData();
  }

  void _startFetchingData() {
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      _fetchHumidity();
    });
  }

  void _fetchHumidity() {
    // Simulating sensor data (Replace with actual AHT21 sensor reading)
    currentHumidity = 30 + Random().nextDouble() * 50; // Random humidity 30-80%
    humidityData.add(FlSpot(time.toDouble(), currentHumidity));
    time++;

    if (humidityData.length > 10) {
      humidityData.removeAt(0); // Keep only the last 10 readings
    }

    notifyListeners();
  }

  String getHumidityStatus() {
    if (currentHumidity < 40) return "Dry";
    if (currentHumidity < 60) return "Normal";
    return "Humid";
  }

  Color getHumidityColor() {
    if (currentHumidity < 40) return Colors.orange;
    if (currentHumidity < 60) return Colors.green;
    return Colors.blue;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
