import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class StudentInterface extends StatefulWidget {
  final String studentId;

  StudentInterface({required this.studentId});

  @override
  _StudentInterfaceState createState() => _StudentInterfaceState();
}

class _StudentInterfaceState extends State<StudentInterface> {
  late MqttServerClient client;
  Map<String, int> absences = {};
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _connectToMQTT();
  }

  Future<void> _connectToMQTT() async {
    client = MqttServerClient(
      'broker.hivemq.com',
      'student_${widget.studentId}',
    );
    client.logging(on: false);
    client.keepAlivePeriod = 20;
    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;
    client.onSubscribed = _onSubscribed;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('student_${widget.studentId}')
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
      client.subscribe(
        'students/${widget.studentId}/absences',
        MqttQos.atLeastOnce,
      );
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
    if (event[0].topic == 'students/${widget.studentId}/absences') {
      setState(() {
        absences = {};
        List<String> pairs = pt.split(',');
        for (String pair in pairs) {
          List<String> parts = pair.split(':');
          if (parts.length == 2) {
            absences[parts[0]] = int.tryParse(parts[1]) ?? 0;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalAbsences = absences.values.fold(0, (sum, value) => sum + value);
    return Scaffold(
      appBar: AppBar(title: Text('Student Interface - ${widget.studentId}')),
      body: isConnected
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Total Absences: $totalAbsences',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: absences.length,
                    itemBuilder: (context, index) {
                      String subject = absences.keys.elementAt(index);
                      int count = absences[subject]!;
                      return ListTile(
                        title: Text(subject),
                        trailing: Text('$count absences'),
                      );
                    },
                  ),
                ),
              ],
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
