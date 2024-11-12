import 'package:flutter/material.dart';

class SchedulePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade300,
        title: const Text(
          'Bus Schedules',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context), // Back button
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context), // Close button
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/shuttle_icon.png', // Replace with your image path
                  height: 50,
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'ShuttleAide',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              _buildBusButtons(),
              const SizedBox(height: 16),
              _buildScheduleSection('Monday to Friday', [
                ['7:30 AM', '8:55 AM', '7:45 PM'],
                ['7:45 AM', '9:15 AM', '8:15 PM'],
                ['8:05 AM', '9:25 AM', '8:45 PM'],
              ]),
              const SizedBox(height: 16),
              _buildScheduleSection('Saturday', [
                ['8:00 AM', '-', '-'],
                ['9:30 AM', '-', '-'],
              ]),
              const SizedBox(height: 16),
              _buildBusButton('VWA 333', Colors.blue.shade700),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Clinic Stop to Ruqayyah/Salahuddin',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
              const SizedBox(height: 16),
              _buildScheduleSection('Monday to Friday', [
                ['7:30 AM', '8:55 AM', '7:45 PM'],
                ['7:45 AM', '9:15 AM', '8:15 PM'],
                ['8:05 AM', '9:25 AM', '8:45 PM'],
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build the two bus buttons (VWA 111 and VWA 222)
  Widget _buildBusButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildBusButton('VWA 111', Colors.green),
        const SizedBox(width: 8),
        _buildBusButton('VWA 222', Colors.black),
      ],
    );
  }

  // Helper method to build a button with a specific label and color
  Widget _buildBusButton(String label, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onPressed: () {},
      child: Text(label),
    );
  }

  // Helper method to build a schedule section with a title and a table of times
  Widget _buildScheduleSection(String title, List<List<String>> times) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Table(
          border: TableBorder.all(color: Colors.grey.shade300),
          children: times.map((row) {
            return TableRow(
              children: row.map((time) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      time,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ],
    );
  }
}