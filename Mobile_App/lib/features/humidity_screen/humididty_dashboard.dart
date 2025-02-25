import 'dart:async';
import 'package:air_quality_iot_app/service/mqtt_service.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HumidityPage extends StatefulWidget {
  @override
  _HumidityPageState createState() => _HumidityPageState();
}

class _HumidityPageState extends State<HumidityPage> {
  double currentHumidity = 50; // Initial humidity value
  List<FlSpot> humidityData = [];
  int time = 0;
  late StreamSubscription _mqttSubscription;


  @override
  void initState() {
    super.initState();
    _mqttSubscription = MQTTService().messageStream.listen(
      (data) {
        _updateHumidity(data);
      },
      onError: (error) {
        print("MQTT Error: $error");
      },
    );
  }
  

   void _updateHumidity(Map<String, dynamic> data) {
    final humidityValue = data['humidity']?.toDouble() ?? 50; 
    setState(() {
      currentHumidity = humidityValue;
      humidityData.add(FlSpot(time.toDouble(), currentHumidity));

      if (humidityData.length > 20) {
        humidityData.removeAt(0);
      }
      time++;
    });
  }

  Color getHumidityColor() {
    if (currentHumidity < 40) return Colors.orange;
    if (currentHumidity < 60) return Colors.green;
    return Colors.blue;
  }

  String getHumidityStatus() {
    if (currentHumidity < 40) return "Dry";
    if (currentHumidity < 60) return "Normal";
    return "Humid";
  }

   @override
  void dispose() {
    _mqttSubscription.cancel(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Humidity Visualization")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: getHumidityColor(),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text("Current Humidity",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                  Text("${currentHumidity.toStringAsFixed(1)}%",
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Text(getHumidityStatus(),
                      style: TextStyle(fontSize: 20, color: Colors.white)),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: LineChart(
                LineChartData(
                  minX: humidityData.isNotEmpty ? humidityData.first.x : 0,
                  maxX: humidityData.isNotEmpty ? humidityData.last.x : 10,
                  minY: 20,
                  maxY: 90,
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
                      spots: humidityData,
                      isCurved: true,
                      color: Colors.blue,
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
