import 'dart:async';
import 'package:air_quality_iot_app/service/mqtt_service.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TVOCDashboard extends StatefulWidget {
  @override
  _TVOCDashboardState createState() => _TVOCDashboardState();
}

class _TVOCDashboardState extends State<TVOCDashboard> {
   double currentTVOC = 50; // Initial TVOC value
  List<FlSpot> tvocData = [];
  int time = 0;
  late StreamSubscription _mqttSubscription;

  @override
  void initState() {
    super.initState();
    _mqttSubscription = MQTTService().messageStream.listen(
      (data) {
        _updateTVOC(data);
      },
      onError: (error) {
        print("MQTT Error: $error");
        // Handle error as needed
      },
    );
  }


  void _updateTVOC(Map<String, dynamic> data) {
    final tvocValue = data['tvoc']?.toDouble() ?? 50; // Extract 'tvoc' from data
    setState(() {
      currentTVOC = tvocValue;
      tvocData.add(FlSpot(time.toDouble(), currentTVOC));

      if (tvocData.length > 20) {
        tvocData.removeAt(0);
      }
      time++;
    });
  }


  Color getTVOCColor() {
    if (currentTVOC < 150) return Colors.green;  // Example thresholds
    if (currentTVOC < 300) return Colors.yellow;
    return Colors.red;
  }

  String getTVOCStatus() {
    if (currentTVOC < 150) return "Good";  // Example thresholds
    if (currentTVOC < 300) return "Moderate";
    return "Unhealthy";
  }



   @override
  void dispose() {
    _mqttSubscription.cancel(); // Cancel the subscription
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("TVOC Visualization")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Current TVOC Value Display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: getTVOCColor(),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text("Current TVOC",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                  Text("${currentTVOC.toStringAsFixed(1)} ppb",
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Text(getTVOCStatus(),
                      style: const TextStyle(fontSize: 20, color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Line Chart
            Expanded( // Use Expanded for the chart to fill available space
              child: LineChart(
                LineChartData(
                  minX: tvocData.isNotEmpty ? tvocData.first.x : 0,
                  maxX: tvocData.isNotEmpty ? tvocData.last.x : 10,
                  minY: 0, // Set appropriate min Y
                  maxY: 500, // Set appropriate max Y
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
                      spots: tvocData,
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