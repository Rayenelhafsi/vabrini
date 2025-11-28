import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class ProfessorInterface extends StatefulWidget {
  @override
  _ProfessorInterfaceState createState() => _ProfessorInterfaceState();
}

class _ProfessorInterfaceState extends State<ProfessorInterface> {
  late MqttServerClient client;
  List<String> presentStudents = [];
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _connectToMQTT();
  }

  Future<void> _connectToMQTT() async {
    client = MqttServerClient(
      'broker.hivemq.com',
      'flutter_client',
    ); // Use a public MQTT broker for demo
    client.logging(on: false);
    client.keepAlivePeriod = 20;
    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;
    client.onSubscribed = _onSubscribed;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMessage;

    try {
      await client.connect();
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('MQTT client connected');
      setState(() {
        isConnected = true;
      });
      client.subscribe('students/present', MqttQos.atLeastOnce);
      client.updates!.listen(_onMessage);
    } else {
      print(
        'MQTT client connection failed - disconnecting, state is ${client.connectionStatus!.state}',
      );
      client.disconnect();
    }
  }

  void _onConnected() {
    print('Connected');
  }

  void _onDisconnected() {
    print('Disconnected');
    setState(() {
      isConnected = false;
    });
  }

  void _onSubscribed(String topic) {
    print('Subscribed to $topic');
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> event) {
    final recMess = event[0].payload as MqttPublishMessage;
    final pt = MqttPublishPayload.bytesToStringAsString(
      recMess.payload.message,
    );
    print('Received message: $pt from topic: ${event[0].topic}');
    if (event[0].topic == 'students/present') {
      setState(() {
        presentStudents = pt.split(',');
      });
    }
  }

  void _vibrateStudent(String studentId) {
    final builder = MqttClientPayloadBuilder();
    builder.addString('vibrate');
    client.publishMessage(
      'students/$studentId/vibrate',
      MqttQos.exactlyOnce,
      builder.payload!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Professor Interface')),
      body: isConnected
          ? ListView.builder(
              itemCount: presentStudents.length,
              itemBuilder: (context, index) {
                final student = presentStudents[index];
                return ListTile(
                  title: Text(student),
                  trailing: ElevatedButton(
                    onPressed: () => _vibrateStudent(student),
                    child: Text('Vibrate'),
                  ),
                );
              },
            )
          : Center(child: Text('Connecting to MQTT...')),
    );
  }

  @override
  void dispose() {
    client.disconnect();
    super.dispose();
  }
}
