import 'dart:async';
import 'package:air_quality_iot_app/service/mqtt_service.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:fl_chart/fl_chart.dart';

class TemperatureDashboard extends StatefulWidget {
  @override
  _TemperatureDashboardState createState() => _TemperatureDashboardState();
}

class _TemperatureDashboardState extends State<TemperatureDashboard> {
  late MqttServerClient client;
  double currentTemperature = 25.0; // Initial temperature value
  List<FlSpot> temperatureData = [];
  int time = 0;
  late StreamSubscription _mqttSubscription;

 @override
    @override
  void initState() {
    super.initState();
    _mqttSubscription = MQTTService().messageStream.listen(
      (data) {          // Correct parameter name here: data
        _updateTemperature(data);
      },
      onError: (error) {
        print("MQTT Error: $error");
        // Handle error as needed
      },
    );
  }


 

  void _updateTemperature(Map<String, dynamic> data) {  // Correct parameter name
    final tempValue = data['temperature']?.toDouble() ?? 25.0;  // Access 'temperature' from data
    setState(() {
      currentTemperature = tempValue;
      temperatureData.add(FlSpot(time.toDouble(), currentTemperature));

      if (temperatureData.length > 20) {
        temperatureData.removeAt(0);
      }
      time++;
    });
  }

  Color getTemperatureColor() {
    if (currentTemperature < 15) return Colors.blue;
    if (currentTemperature < 30) return Colors.green;
    return Colors.red;
  }

  String getTemperatureStatus() {
    if (currentTemperature < 15) return "Cold";
    if (currentTemperature < 30) return "Comfortable";
    return "Hot";
  }

  @override
  void dispose() {
    _mqttSubscription.cancel(); // Cancel the subscription!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Temperature Visualization")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: getTemperatureColor(),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text("Current Temperature",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                  Text("${currentTemperature.toStringAsFixed(1)} °C",
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Text(getTemperatureStatus(),
                      style: const TextStyle(fontSize: 20, color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: LineChart(
                LineChartData(
                  minX: temperatureData.isNotEmpty ? temperatureData.first.x : 0,
                  maxX: temperatureData.isNotEmpty ? temperatureData.last.x : 10,
                  minY: -10,  // Set as per your expected range
                  maxY: 50,   // Set as per your expected range
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: true, reservedSize: 40),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.black),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: temperatureData,
                      isCurved: true,
                      color: Colors.orange,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.orange.withOpacity(0.3),
                      ),
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