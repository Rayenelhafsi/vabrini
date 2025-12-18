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

    // Use existing Node-RED topics without changing Node-RED
    // Both professor and student use vabrih topic (existing in Node-RED flow)
    // Node-RED will echo to vabrini topic
    mqttService.publish('vabrih', scannedId!, MqttQos.atLeastOnce);

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
          title: const Text('Scan QR Code'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                _isScanning = false;
              });
            },
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.9, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: MobileScanner(
                    controller: cameraController,
                    onDetect: _onDetect,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.95, end: 1.0),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Card(
                  color: Colors.white,
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Select User Type',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
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
                                const Text('Professor'),
                              ],
                            ),
                            const SizedBox(width: 24),
                            Row(
                              children: [
                                Radio<UserType>(
                                  value: UserType.student,
                                  groupValue: _selectedUserType,
                                  onChanged: (UserType? value) {
                                    setState(() {
                                      _selectedUserType = value!;
                                    });
                                  },
                                ),
                                const Text('Student'),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _scanQRCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Scan QR Code'),
                          ),
                        ),
                        AnimatedOpacity(
                          opacity: scannedId != null ? 1 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: scannedId != null
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: Text(
                                    'Scanned ID: $scannedId',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: mqttService.isConnected ? _login : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                            child: const Text('Login'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (!mqttService.isConnected)
                          Text(
                            'Connecting to MQTT...',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey[200]),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
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
