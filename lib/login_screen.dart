import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mqtt.dart';
import 'professor_interface.dart';
import 'student_interface.dart';

enum UserType { professor, student }

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  UserType _selectedUserType = UserType.professor;
  String? scannedId;
  late MqttService mqttService;
  bool _isScanning = false;
  MobileScannerController cameraController = MobileScannerController();

  @override
  void initState() {
    super.initState();
    mqttService = MqttService();
    _connectToMQTT();
  }

  Future<void> _connectToMQTT() async {
    await mqttService.connect('login_client');
    setState(() {});
  }

  void _scanQRCode() {
    setState(() {
      _isScanning = true;
    });
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      debugPrint('Barcode found! ${barcode.rawValue}');
      setState(() {
        scannedId = barcode.rawValue;
        _isScanning = false;
      });
    }
  }

  void _login() async {
    if (scannedId == null || scannedId!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please scan your ID')));
      return;
    }

    String topic = _selectedUserType == UserType.professor
        ? 'professor/login'
        : 'student/login';

    // TODO: Adjust topic and message for Node-RED MQTT integration

    mqttService.publish(topic, scannedId!, MqttQos.atLeastOnce);

    // Save professorId locally if professor
    if (_selectedUserType == UserType.professor) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('professorId', scannedId!);
    }

    // Navigate to the appropriate interface
    if (_selectedUserType == UserType.professor) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProfessorInterface(professorId: scannedId!),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => StudentInterface(studentId: scannedId!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isScanning) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Scan QR Code'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                _isScanning = false;
              });
            },
          ),
        ),
        body: MobileScanner(controller: cameraController, onDetect: _onDetect),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: Text('Login')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Select User Type',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio<UserType>(
                    value: UserType.professor,
                    groupValue: _selectedUserType,
                    onChanged: (UserType? value) {
                      setState(() {
                        _selectedUserType = value!;
                      });
                    },
                  ),
                  Text('Professor'),
                  SizedBox(width: 20),
                  Radio<UserType>(
                    value: UserType.student,
                    groupValue: _selectedUserType,
                    onChanged: (UserType? value) {
                      setState(() {
                        _selectedUserType = value!;
                      });
                    },
                  ),
                  Text('Student'),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _scanQRCode,
                child: Text('Scan QR Code'),
              ),
              if (scannedId != null) Text('Scanned ID: $scannedId'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: mqttService.isConnected ? _login : null,
                child: Text('Login'),
              ),
              if (!mqttService.isConnected) Text('Connecting to MQTT...'),
            ],
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    mqttService.disconnect();
    super.dispose();
  }
}
