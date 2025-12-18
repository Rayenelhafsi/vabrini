import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'mqtt.dart';
import 'dart:convert';

class ClassStudentsScreen extends StatefulWidget {
  final String className;
  final String subject;
  final List<String> students;

  ClassStudentsScreen({
    required this.className,
    required this.subject,
    required this.students,
  });

  @override
  _ClassStudentsScreenState createState() => _ClassStudentsScreenState();
}

class _ClassStudentsScreenState extends State<ClassStudentsScreen> {
  late MqttService mqttService;
  List<Map<String, dynamic>> studentsList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialize with passed students
    studentsList = widget.students.map((s) => {
      'nom': s,
      'prenom': '',
      'present': 0,
    }).toList();
    mqttService = MqttService();
    _connectToMQTT();
  }

  Future<void> _connectToMQTT() async {
    await mqttService.connect(
      'class_${widget.className}_client',
      onMessage: _onMessage,
    );
    // Subscribe to give_me_etudiant topic (Node-RED publishes here)
    mqttService.subscribe(
      '${widget.className}/give_me_etudiant',
      MqttQos.atLeastOnce,
    );
    setState(() {
      isLoading = false;
    });
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> event) {
    final recMess = event[0].payload as MqttPublishMessage;
    final pt = MqttPublishPayload.bytesToStringAsString(
      recMess.payload.message,
    );
    print('Received message: $pt from topic: ${event[0].topic}');
    
    if (event[0].topic == '${widget.className}/give_me_etudiant') {
      try {
        final Map<String, dynamic> data = jsonDecode(pt);
        setState(() {
          if (data.containsKey('etudiants')) {
            studentsList = (data['etudiants'] as List<dynamic>).map((s) => {
              'nom': s['nom'] ?? '',
              'prenom': s['prenom'] ?? '',
              'present': s['present'] ?? 0,
            }).toList();
          }
          isLoading = false;
        });
      } catch (e) {
        print('Error parsing students data: $e');
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.className} - ${widget.subject}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
            child: isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : studentsList.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            'No students found for this class.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: studentsList.length,
                        itemBuilder: (context, index) {
                          final student = studentsList[index];
                          final fullName = '${student['prenom']} ${student['nom']}'.trim();
                          final isPresent = student['present'] == 1;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Text(
                                fullName.isNotEmpty
                                    ? fullName[0].toUpperCase()
                                    : '?',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                            title: Text(fullName.isNotEmpty ? fullName : student['nom'] ?? 'Unknown'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isPresent
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isPresent ? 'Present' : 'Absent',
                                style: TextStyle(
                                  color: isPresent ? Colors.green : Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    mqttService.disconnect();
    super.dispose();
  }
}
