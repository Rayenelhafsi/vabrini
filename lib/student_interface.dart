import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'mqtt.dart';

class StudentInterface extends StatefulWidget {
  final String studentId;

  StudentInterface({required this.studentId});

  @override
  _StudentInterfaceState createState() => _StudentInterfaceState();
}

class _StudentInterfaceState extends State<StudentInterface> {
  late MqttService mqttService;
  Map<String, int> absences = {};

  @override
  void initState() {
    super.initState();
    mqttService = MqttService();
    _connectToMQTT();
  }

  Future<void> _connectToMQTT() async {
    await mqttService.connect(
      'student_${widget.studentId}',
      onMessage: _onMessage,
    );
    // TODO: Adjust topic for Node-RED MQTT integration
    mqttService.subscribe(
      'students/${widget.studentId}/absences',
      MqttQos.atLeastOnce,
    );
    setState(() {});
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
      appBar: AppBar(
        title: Text('Student - ${widget.studentId}'),
      ),
      body: mqttService.isConnected
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    color: Colors.blue.shade50,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.analytics_outlined, size: 28),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Absences',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$totalAbsences',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.97, end: 1.0),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Transform.scale(scale: value, child: child);
                      },
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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
                    ),
                  ),
                ],
              ),
            )
          : const Center(child: Text('Connecting to MQTT...')),
    );
  }

  @override
  void dispose() {
    mqttService.disconnect();
    super.dispose();
  }
}
