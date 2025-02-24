import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTService {
  late MqttServerClient client;
  Function(String topic, String message)?
      onMessageReceived; // Callback for updates

  MQTTService({this.onMessageReceived}) {
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
  }

  Future<void> connectAndSubscribe() async {
    try {
      await client.connect();
      print('✅ MQTT Connected!');

      // Topics to subscribe
      const eco2Topic = 'air_quality/eco2';
      const humidityTopic = 'air_quality/humidity';
      const tvocTopic = 'air_quality/tvoc';
      const temperatureTopic =
          'air_quality/temperature'; // Added Temperature Support

      client.subscribe(eco2Topic, MqttQos.atLeastOnce);
      client.subscribe(humidityTopic, MqttQos.atLeastOnce);
      client.subscribe(tvocTopic, MqttQos.atLeastOnce);
      client.subscribe(
          temperatureTopic, MqttQos.atLeastOnce); // Subscribe to Temperature

      client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
        for (var message in messages) {
          final recMsg = message.payload as MqttPublishMessage;
          final payload =
              MqttPublishPayload.bytesToStringAsString(recMsg.payload.message);
          final topic = message.topic;

          print('📩 Data Received on $topic: $payload');

          // Pass received data to the UI callback
          if (onMessageReceived != null) {
            onMessageReceived!(topic, payload);
          }
        }
      });
    } catch (e) {
      print('❌ MQTT connection failed: $e');
    }
  }

  void publishData(String topic, double value) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(value.toString());
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    print('📤 Published $value to $topic');
  }

  void disconnect() {
    client.disconnect();
    print('🔌 MQTT Disconnected.');
  }
}
