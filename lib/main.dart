import 'package:firebase_core/firebase_core.dart';
import '/data/firebase_options.dart';
import 'package:flutter/material.dart';

import '/pages/schedule.dart';
import 'map_display.dart';

void main() async {
  //WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MaterialApp(
    home: ShuttleAideHP(),
  ));
}

class ShuttleAideHP extends StatelessWidget {
  const ShuttleAideHP({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ShuttleAide'),
        backgroundColor: Colors.white.withOpacity(0.5),
        elevation: 0,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.schedule, color: Colors.green),
            label: const Text('Schedule', style: TextStyle(color: Colors.black)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SchedulePage()),
              );
            },
          ),
        ],
      ),
      body: const MapDisplay(),
    );
  }
}