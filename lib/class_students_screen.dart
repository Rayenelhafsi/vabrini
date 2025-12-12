import 'package:flutter/material.dart';

class ClassStudentsScreen extends StatelessWidget {
  final String className;
  final String subject;
  final List<String> students;

  ClassStudentsScreen({
    required this.className,
    required this.subject,
    required this.students,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$className - $subject')),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          return ListTile(
            title: Text(student),
            trailing: Text('Absent'), // Default state
          );
        },
      ),
    );
  }
}
