import 'dart:async';
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
  late StreamSubscription _mqttSubscription;



    @override
  void initState() {
    super.initState();

    _mqttSubscription = MQTTService().messageStream.listen(
      (data) {
        _updateEco2(data);
      },
      onError: (error) {
        print("MQTT Error: $error");
        // Handle error as needed
      },
    );
  }

  void _updateEco2(Map<String, dynamic> data) {
    final eco2Value = data['eco2']?.toDouble() ?? 400;  // Extract 'eco2' from data

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
    if (currentEco2 < 800) return Colors.green;
    if (currentEco2 < 1200) return Colors.orange;
    return Colors.red;
  }

  String getEco2Status() {
    if (currentEco2 < 800) return "Good";
    if (currentEco2 < 1200) return "Moderate";
    return "Bad";
  }

  @override
  void dispose() {
    _mqttSubscription.cancel(); // Cancel the subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("eCO2 Visualization")),
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