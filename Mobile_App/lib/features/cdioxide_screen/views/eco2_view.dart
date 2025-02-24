import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:air_quality_iot_app/service/mqtt_service.dart'; // Import your MQTT service

class Eco2VisualizationScreen extends StatefulWidget {
  @override
  _Eco2VisualizationScreenState createState() => _Eco2VisualizationScreenState();
}

class _Eco2VisualizationScreenState extends State<Eco2VisualizationScreen> {
  double currentEco2 = 400; // Initial value
  List<FlSpot> eco2Data = [];
  int time = 0;
  late MQTTService mqttService;


  @override
  void initState() {
    super.initState();

    mqttService = MQTTService(); // Initialize MQTTService
    mqttService.connectAndSubscribe();  // Connect and subscribe to topics


    mqttService.client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final recMsg = c[0].payload as MqttPublishMessage;
      final pt = MqttPublishPayload.bytesToStringAsString(recMsg.payload.message);

      try {
        dynamic jsonData = jsonDecode(pt); // Use dynamic

        double eco2Value;
        if (jsonData is Map) {  // Check if it's a JSON object (Map)
          eco2Value = jsonData['eco2']?.toDouble() ?? 400;
        } else if (jsonData is double || jsonData is int) { // Check if it's a number
          eco2Value = jsonData.toDouble(); 
        } else {
          print("❌ Invalid data format: $jsonData"); // Log the bad data
          eco2Value = 400; // Use a default value
        }

        _updateEco2(eco2Value.toString()); // Update with the correct value

      } catch (e) {
        print("❌ JSON/Data Parsing Error: $e"); // More descriptive error message
      }
    });

  }

  void _updateEco2(String payload) {
    final eco2Value = double.tryParse(payload) ?? 400;
    setState(() {
      currentEco2 = eco2Value;
      eco2Data.add(FlSpot(time.toDouble(), currentEco2));
      if (eco2Data.length > 20) {
        eco2Data.removeAt(0);
      }
      time++;
    });
  }


  Color getEco2Color() {
    // Define your eCO2 color logic here based on currentEco2
    if (currentEco2 < 800)
      return Colors.green;  // Example: Green for good
    else if (currentEco2 < 1200)
      return Colors.orange; // Example: Orange for moderate
    else
      return Colors.red;    // Example: Red for bad

  }

  String getEco2Status() {    
    if (currentEco2 < 800)
      return "Good";  // Example: Green for good
    else if (currentEco2 < 1200)
      return "Moderate"; // Example: Orange for moderate
    else
      return "Bad";    // Example: Red for bad
  }

  @override
  void dispose() {
    mqttService.disconnect(); // Disconnect MQTT in dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("eCO2 Visualization (ENS160 Sensor)")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: getEco2Color(),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text("Current eCO2",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                  Text("${currentEco2.toStringAsFixed(1)} ppm", // Use appropriate units
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                          Text(getEco2Status(),
                      style: TextStyle(fontSize: 20, color: Colors.white)),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: LineChart(
                LineChartData(
                  minX: eco2Data.isNotEmpty ? eco2Data.first.x : 0,
                  maxX: eco2Data.isNotEmpty ? eco2Data.last.x : 10,
                   minY: 0, // Set appropriate min Y
                  maxY: 2000,          // Set appropriate max Y
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                     leftTitles: AxisTitles(
                        sideTitles:
                            SideTitles(showTitles: true, reservedSize: 30)),
                    bottomTitles: AxisTitles(
                        sideTitles:
                            SideTitles(showTitles: true, reservedSize: 40)),
                  ),
                  borderData: FlBorderData(
                      show: true, border: Border.all(color: Colors.black)),
                  lineBarsData: [
                    LineChartBarData(
                      spots: eco2Data,
                      isCurved: true,
                      color: Colors.blue, // Choose a suitable color
                      barWidth: 3,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(
                          show: true, color: Colors.blue.withOpacity(0.3)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}