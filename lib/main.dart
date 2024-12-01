import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'map_display.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MaterialApp(
    home: ShuttleAideHP(),
  ));
}

/* Old code for reference
void main() {
  runApp(const MaterialApp(
    home: ShuttleAideHP(),
  ));
}
*/

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