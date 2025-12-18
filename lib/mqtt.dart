import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  late MqttServerClient client;
  bool isConnected = false;
  Function(List<MqttReceivedMessage<MqttMessage>>)? onMessageReceived;

  Future<void> connect(
    String clientId, {
    Function(List<MqttReceivedMessage<MqttMessage>>)? onMessage,
  }) async {
    // Use localhost if MQTT broker is on same computer
    // Or replace with your computer's IP address if Flutter app runs on phone
    // Find your IP with: ipconfig (Windows) or ifconfig (Linux/Mac)
    client = MqttServerClient('192.168.137.1:1883', clientId);
    client.logging(on: false);
    client.keepAlivePeriod = 20;
    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;
    client.onSubscribed = _onSubscribed;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMessage;

    try {
      await client.connect();
      if (client.connectionStatus!.state == MqttConnectionState.connected) {
        isConnected = true;
        onMessageReceived = onMessage;
        if (onMessage != null) {
          client.updates!.listen(onMessage);
        }
      }
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }
  }

  void _onConnected() {
    print('Connected');
  }

  void _onDisconnected() {
    print('Disconnected');
    isConnected = false;
  }

  void _onSubscribed(String topic) {
    print('Subscribed to $topic');
  }

  void subscribe(String topic, MqttQos qos) {
    if (isConnected) {
      client.subscribe(topic, qos);
    }
  }

  void publish(String topic, String message, MqttQos qos) {
    if (isConnected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      client.publishMessage(topic, qos, builder.payload!);
    }
  }

  void disconnect() {
    client.disconnect();
  }
}
