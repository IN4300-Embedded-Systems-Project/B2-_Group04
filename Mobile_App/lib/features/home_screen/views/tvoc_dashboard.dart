import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:fl_chart/fl_chart.dart';

class TVOCDashboard extends StatefulWidget {
  @override
  _TVOCDashboardState createState() => _TVOCDashboardState();
}

class _TVOCDashboardState extends State<TVOCDashboard> {
  late MqttServerClient client;
  double currentTVOC = 50; // Initial TVOC value
  List<FlSpot> tvocData = [];
  int time = 0;
  bool isConnected = false;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? mqttSubscription;

  @override
  void initState() {
    super.initState();
    _connectMQTT();
  }

  Future<void> _connectMQTT() async {
     client =
        MqttServerClient('c197f092.ala.us-east-1.emqxsl.com', 'flutter_client'); // Replace with your broker and client ID
    client.port = 8883; 
    client.secure = true;
    client.logging(on: true);

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client') // Replace with your client identifier
        .authenticateAs('krishantha', 'krishantha') // Replace with your username and password
        .startClean();
    client.connectionMessage = connMessage;

    try {
      await client.connect();
      setState(() {
        isConnected = true;
      });

      print('✅ MQTT Connected!');

      const tvocTopic = 'air_quality/tvoc'; // Replace with your topic
      client.subscribe(tvocTopic, MqttQos.atLeastOnce);

      mqttSubscription?.cancel();
      mqttSubscription = client.updates!
          .listen((List<MqttReceivedMessage<MqttMessage>> messages) {
        for (var message in messages) {
          final recMsg = message.payload as MqttPublishMessage;
          final payload =
              MqttPublishPayload.bytesToStringAsString(recMsg.payload.message);
          print("📩 TVOC Data Received: $payload ppb");
          _updateTVOC(payload);
        }
      });
    } catch (e) {
      print('❌ MQTT connection failed: $e');
      // Handle connection errors appropriately (e.g., show a snackbar)
    }
  }

  void _updateTVOC(String payload) {
    final tvocValue = double.tryParse(payload) ?? 50; // Handle parsing errors
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
    mqttSubscription?.cancel();
    client.disconnect();
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