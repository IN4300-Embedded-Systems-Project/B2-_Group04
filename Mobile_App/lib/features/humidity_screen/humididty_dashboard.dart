import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:fl_chart/fl_chart.dart';

class HumidityPage extends StatefulWidget {
  @override
  _HumidityPageState createState() => _HumidityPageState();
}

class _HumidityPageState extends State<HumidityPage> {
  late MqttServerClient client;
  double currentHumidity = 50; // Initial humidity value
  List<FlSpot> humidityData = [];
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
        MqttServerClient('c197f092.ala.us-east-1.emqxsl.com', 'flutter_client');
    client.port = 8883; // Use 1883 for TCP, 8883 for SSL/TLS
    client.secure = true;
    client.logging(on: true);

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client')
        .authenticateAs('krishantha', 'krishantha')
        .startClean();
    client.connectionMessage = connMessage;

    try {
      await client.connect();
      setState(() {
        isConnected = true;
      });

      print('✅ MQTT Connected!');

      const humidityTopic = 'air_quality/humidity';
      client.subscribe(humidityTopic, MqttQos.atLeastOnce);

      mqttSubscription?.cancel(); // Cancel previous listeners if any
      mqttSubscription = client.updates!
          .listen((List<MqttReceivedMessage<MqttMessage>> messages) {
        for (var message in messages) {
          final recMsg = message.payload as MqttPublishMessage;
          final payload =
              MqttPublishPayload.bytesToStringAsString(recMsg.payload.message);
          print("📩 Humidity Data Received: $payload%");
          _updateHumidity(payload);
        }
      });
    } catch (e) {
      print('❌ MQTT connection failed: $e');
    }
  }

  void _updateHumidity(String payload) {
    final humidityValue = double.tryParse(payload) ?? 50;
    setState(() {
      currentHumidity = humidityValue;
      humidityData.add(FlSpot(time.toDouble(), currentHumidity));

      if (humidityData.length > 20) {
        humidityData.removeAt(0); // Keep only the last 20 readings
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
    mqttSubscription?.cancel();
    client.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Humidity Visualization (AHT21 Sensor)")),
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
