import 'package:flutter/material.dart';

class SchedulePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Flexible(
          child: Image.asset(
            'assets/shuttleAideLogo.png',
            fit: BoxFit.contain,
            height: 160,),
        ),
        centerTitle: true,
      ),
      body: const SingleChildScrollView(
        child:
        Center(
          child: Text("Bus Schedules"),
        )
      ),
    );
  }
}