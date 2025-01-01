import 'package:flutter/material.dart';

class PanelInfo {
  static Widget buildPanelContent({
    required double distance,
    required double duration,
    required bool isBusSelected, // Boolean to determine if Bus 1 is selected
  }) {
    // Determine if distance should be displayed in meters or kilometers
    String formattedDistance;
    if (distance > 1000) {
      formattedDistance = '${(distance / 1000).toStringAsFixed(2)} km'; // in kilometers
    } else {
      formattedDistance = '${distance.round()} m'; // in meters
    }

    if (isBusSelected) {
      // Display when Bus 1 is selected
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bus Icon and Name
          const Row(
            children: [
              Icon(
                Icons.directions_bus,
                color: Color.fromARGB(255, 0, 0, 139),
              ),
              SizedBox(width: 10),
              Text(
                "Bus 1",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Bus Details
          const Text(
            "Plate Number: ABC 123",
            style: TextStyle(fontSize: 16),
          ),
          const Text(
            "Route: Ruqayyah Route",
            style: TextStyle(fontSize: 16),
          ),
          const Text(
            "Description: This bus serves the Ruqayyah route, ensuring timely and comfortable rides.",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          // Distance and ETA
          Row(
            children: [
              const Icon(Icons.timer, color: Colors.green),
              const SizedBox(width: 10),
              Text(
                "ETA: ${duration.round()} min",
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.map, color: Colors.blue),
              const SizedBox(width: 10),
              Text(
                "Distance: $formattedDistance",
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      );
    } else {
      // General Display
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bus 1 Container
          _buildBusBox(
            iconColor: const Color.fromARGB(255, 0, 0, 139),
            busName: "Bus 1",
            distance: formattedDistance,
            duration: duration,
          ),
          const SizedBox(height: 20),
          // Bus 2 Container
          _buildBusBox(
            iconColor: Colors.green,
            busName: "Bus 2",
            additionalInfo: "To be implemented",
          ),
          const SizedBox(height: 20),
          // Bus 3 Container
          _buildBusBox(
            iconColor: Colors.red,
            busName: "Bus 3",
            additionalInfo: "To be implemented",
          ),
          const SizedBox(height: 20),
        ],
      );
    }
  }

  static Widget _buildBusBox({
    required Color iconColor,
    required String busName,
    String? additionalInfo,
    String? distance,
    double? duration,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.directions_bus, color: iconColor),
              const SizedBox(width: 10),
              Text(
                busName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (distance != null && duration != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.timer, color: Colors.green),
                const SizedBox(width: 10),
                Text(
                  "ETA: ${duration.round()} min",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.map, color: Colors.blue),
                const SizedBox(width: 10),
                Text(
                  "Distance: $distance",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
          if (additionalInfo != null) ...[
            const SizedBox(height: 10),
            Text(
              additionalInfo,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
