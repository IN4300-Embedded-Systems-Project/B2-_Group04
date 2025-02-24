import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTService {
  static final MQTTService _instance = MQTTService._internal();

  factory MQTTService() => _instance;

  late MqttServerClient _client;
  final _messageStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messageStream =>
      _messageStreamController.stream;

  MQTTService._internal() {
    _client = MqttServerClient(
        'c197f092.ala.us-east-1.emqxsl.com', 'flutter_client'); // Your broker and client ID
    _client.port = 8883;
    _client.secure = true;
    _client.logging(on: true);

    final connMess = MqttConnectMessage()
        .withClientIdentifier('flutter_client') // Your client ID
        .authenticateAs('krishantha', 'krishantha') // Your username/password
        .startClean();
    _client.connectionMessage = connMess;
  }

  Future<void> connect() async {
    try {
      await _client.connect();
      print('✅ MQTT Connected!');
      _subscribeToTopics();
    } catch (e) {
      print('❌ MQTT connection failed: $e');
      // Handle connection errors, maybe retry logic?
    }
  }

  void _subscribeToTopics() {
    const topics = [
      'air_quality/eco2',
      'air_quality/humidity',
      'air_quality/tvoc',
      'air_quality/temperature',
    ];
    for (final topic in topics) {
      _client.subscribe(topic, MqttQos.atLeastOnce);
      print('Subscribed to: $topic');
    }

    _client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final recMsg = c[0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(recMsg.payload.message);
      final topic = c[0].topic;

      try {
        dynamic data = jsonDecode(payload);
        if (data is! Map) {
          data = {topic.split('/').last: data};
        }
        _messageStreamController.add(Map<String, dynamic>.from(data));
      } catch (e) {
        print('Error decoding JSON: $e');
        _messageStreamController.addError(e); // Add error to the stream
      }
    });
  }


  void disconnect() {
    _client.disconnect();
    print('🔌 MQTT Disconnected.');
  }
}