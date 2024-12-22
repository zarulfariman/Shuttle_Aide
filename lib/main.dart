import 'package:firebase_core/firebase_core.dart';
import '/data/firebase_options.dart';
import 'package:flutter/material.dart';

import 'map_display.dart';

void main() async {
  //WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ShuttleAideHP(),
  ));
}

class ShuttleAideHP extends StatelessWidget {
  const ShuttleAideHP({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        //title: Image.asset('shuttleAideLogo.png', height: 200,),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Image.asset(
              'assets/shuttleAideLogo.png',  // Update path as per your assets folder
              fit: BoxFit.contain,
              height: 160,  // Adjust height as needed
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white.withOpacity(0),
        elevation: 0,
      ),
      body: const MapDisplay(),
    );
  }
}