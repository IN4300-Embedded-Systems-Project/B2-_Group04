import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTService {
  late MqttServerClient client;

  MQTTService() {
    client = MqttServerClient('c197f092.ala.us-east-1.emqxsl.com', 'flutter_client');
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
      print('MQTT Connected!');

      const topic = 'air_quality/eco2';
      client.subscribe(topic, MqttQos.atLeastOnce);

      client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
        final recMsg = messages[0].payload as MqttPublishMessage;
        final payload =
            MqttPublishPayload.bytesToStringAsString(recMsg.payload.message);
        print('Received: $payload from ${messages[0].topic}');
      });
    } catch (e) {
      print('MQTT connection failed: $e');
    }
  }

  void publishEco2(double value) {
    const topic = 'air_quality/eco2';
    final builder = MqttClientPayloadBuilder();
    builder.addString(value.toString());
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  void disconnect() {
    client.disconnect();
  }
}
