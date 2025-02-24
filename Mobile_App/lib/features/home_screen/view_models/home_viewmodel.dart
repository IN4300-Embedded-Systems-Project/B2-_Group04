import 'package:air_quality_iot_app/service/mqtt_service.dart';
import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  double humidity = 50.0;
  double temperature = 25.0;
  double tvoc = 100.0;
  double eco2 = 400.0;

  late MQTTService mqttService;

  HomeViewModel() {
    mqttService = MQTTService(onMessageReceived: _updateSensorData);
    mqttService.connectAndSubscribe();
  }

  void _updateSensorData(String topic, String message) {
    double value = double.tryParse(message) ?? 0.0;

    if (topic == "air_quality/humidity") {
      humidity = value;
    } else if (topic == "air_quality/temperature") {
      temperature = value;
    } else if (topic == "air_quality/tvoc") {
      tvoc = value;
    } else if (topic == "air_quality/eco2") {
      eco2 = value;
    }

    notifyListeners(); // Update UI
  }
}
