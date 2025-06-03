
import 'package:flutter/material.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Courses')),
      body: ListView(
        children: List.generate(3, (index) {
          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              title: Text('Course \$index'),
              subtitle: const LinearProgressIndicator(value: 0.5),
              trailing: const Icon(Icons.play_arrow),
            ),
          );
        }),
      ),
    );
  }
}
