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
            child: ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return ListTile(
                  title: Text(student),
                  trailing: const Text('Absent'), // Default state
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
