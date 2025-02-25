// home_viewmodel.dart
import 'dart:async';  // Import for StreamSubscription
import 'package:air_quality_iot_app/service/mqtt_service.dart';
import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  double humidity = 50.0;
  double temperature = 25.0;
  double tvoc = 100.0;
  double eco2 = 400.0;
  late StreamSubscription _mqttSubscription;

  HomeViewModel() {
    _mqttSubscription = MQTTService().messageStream.listen(
      (data) {
        _updateSensorData(data);
      },
      onError: (error) {
        print("MQTT Error in HomeViewModel: $error");
      },
    );
  }

  void _updateSensorData(Map<String, dynamic> data) {
     if (data.containsKey('humidity')) {
      humidity = data['humidity']?.toDouble() ?? humidity;
    }
    if (data.containsKey('temperature')) {
      temperature = data['temperature']?.toDouble() ?? temperature;
    }
    if (data.containsKey('tvoc')) {
      tvoc = data['tvoc']?.toDouble() ?? tvoc;
    }
    if (data.containsKey('eco2')) {
      eco2 = data['eco2']?.toDouble() ?? eco2;
    }

    notifyListeners(); // Update UI
  }


  @override
  void dispose() {
    _mqttSubscription.cancel();  
    super.dispose();
  }
}
