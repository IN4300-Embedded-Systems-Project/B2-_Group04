import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
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
  bool isConnected = false;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? mqttSubscription;

  @override
  void initState() {
    super.initState();
    _connectMQTT();
  }

  Future<void> _connectMQTT() async {
    client = MqttServerClient(
        'c197f092.ala.us-east-1.emqxsl.com', 'flutter_client'); // Replace with your broker and client ID
    client.port = 8883;
    client.secure = true;
    client.logging(on: true);

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client') // Replace with your client identifier
        .authenticateAs('krishantha', 'krishantha') // Replace with your username/password
        .startClean();
    client.connectionMessage = connMessage;

    try {
      await client.connect();
      setState(() {
        isConnected = true;
      });

      print('✅ MQTT Connected!');

      const temperatureTopic = 'air_quality/temperature'; // Replace with your topic
      client.subscribe(temperatureTopic, MqttQos.atLeastOnce);

      mqttSubscription?.cancel();
      mqttSubscription = client.updates!.listen(
          (List<MqttReceivedMessage<MqttMessage>> messages) {
        for (var message in messages) {
          final recMsg = message.payload as MqttPublishMessage;
          final payload =
              MqttPublishPayload.bytesToStringAsString(recMsg.payload.message);
          print("📩 Temperature Data Received: $payload °C");
          _updateTemperature(payload);
        }
      });
    } catch (e) {
      print('❌ MQTT connection failed: $e');
      // Handle connection errors (e.g., show a snackbar)
    }
  }

  void _updateTemperature(String payload) {
    final tempValue = double.tryParse(payload) ?? 25.0;
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
    mqttSubscription?.cancel();
    client.disconnect();
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