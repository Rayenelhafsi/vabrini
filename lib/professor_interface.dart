import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'mqtt.dart';
import 'models/professor.dart';
import 'class_students_screen.dart';
import 'dart:convert';

class ProfessorInterface extends StatefulWidget {
  final String professorId;

  ProfessorInterface({required this.professorId});

  @override
  _ProfessorInterfaceState createState() => _ProfessorInterfaceState();
}

class _ProfessorInterfaceState extends State<ProfessorInterface> {
  late MqttService mqttService;
  Professor? professor;
  List<Map<String, dynamic>> classes = [];
  bool isDeleteMode = false;

  @override
  void initState() {
    super.initState();
    mqttService = MqttService();
    _connectToMQTT();
    // Initialize with default professor data, will be updated from MQTT
    professor = Professor(
      professorId: widget.professorId,
      name: '',
      firstName: '',
      departmentId: 'CS',
      imageUrl: null,
    );
  }

  Future<void> _connectToMQTT() async {
    await mqttService.connect('professor_client', onMessage: _onMessage);
    // Subscribe to give_me_class topic
    mqttService.subscribe(
      '${widget.professorId}/give_me_class',
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
    if (event[0].topic == '${widget.professorId}/give_me_class') {
      try {
        final Map<String, dynamic> data = jsonDecode(pt);
        setState(() {
          professor = Professor(
            professorId: data['idprof'],
            name: data['name'],
            firstName: data['firstname'],
            departmentId: professor?.departmentId ?? 'CS',
            imageUrl: professor?.imageUrl,
          );
          classes = (data['classes'] as List<dynamic>)
              .map(
                (item) => {
                  'className': item['classe'],
                  'subject': item['matiere'],
                  'students': [],
                },
              )
              .toList();
        });
      } catch (e) {
        print('Error parsing professor data: $e');
      }
    }
  }

  void _addClass() {
    showDialog(
      context: context,
      builder: (context) {
        String className = '';
        String subject = '';
        return AlertDialog(
          title: Text('Add Class'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => className = value,
                decoration: InputDecoration(labelText: 'Class Name'),
              ),
              TextField(
                onChanged: (value) => subject = value,
                decoration: InputDecoration(labelText: 'Subject'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (className.isNotEmpty && subject.isNotEmpty) {
                  final message = jsonEncode({
                    'className': className,
                    'subject': subject,
                    'students': [],
                  });
                  // TODO: Adjust topic for Node-RED MQTT integration
                  mqttService.publish(
                    'professor/${widget.professorId}/addClass',
                    message,
                    MqttQos.atLeastOnce,
                  );
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _removeClass(String className) {
    // TODO: Adjust topic for Node-RED MQTT integration
    mqttService.publish(
      'professor/${widget.professorId}/removeClass',
      className,
      MqttQos.atLeastOnce,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Professor details widget
          Container(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: professor!.imageUrl != null
                      ? NetworkImage(professor!.imageUrl!)
                      : null,
                  child: professor!.imageUrl == null
                      ? Icon(Icons.person, size: 30)
                      : null,
                ),
                SizedBox(width: 16),
                Text(
                  '${professor!.firstName} ${professor!.name}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // Classes grid
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
              ),
              itemCount: classes.length,
              itemBuilder: (context, index) {
                final classData = classes[index];
                return Card(
                  child: InkWell(
                    onTap: isDeleteMode
                        ? () => _removeClass(classData['className'])
                        : () {
                            // Publish to "This_is_the_class" topic
                            final message = jsonEncode({
                              'idprof': professor!.professorId,
                              'classe_name': classData['className'],
                              'matiere_name': classData['subject'],
                            });
                            mqttService.publish(
                              'This_is_the_class',
                              message,
                              MqttQos.atLeastOnce,
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClassStudentsScreen(
                                  className: classData['className'],
                                  subject: classData['subject'],
                                  students: List<String>.from(
                                    classData['students'] ?? [],
                                  ),
                                ),
                              ),
                            );
                          },
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            classData['className'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            classData['subject'],
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => setState(() => isDeleteMode = !isDeleteMode),
            child: Icon(isDeleteMode ? Icons.cancel : Icons.delete),
            tooltip: isDeleteMode ? 'Cancel Delete' : 'Delete Mode',
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _addClass,
            child: Icon(Icons.add),
            tooltip: 'Add Class',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    mqttService.disconnect();
    super.dispose();
  }
}
