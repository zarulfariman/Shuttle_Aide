import 'package:firebase_database/firebase_database.dart';
import 'package:latlong2/latlong.dart';
import '/bus/bus_movement.dart'; // Adjust the import path as needed
import '/calculation/nearest_bus_stop.dart'; // Your `findClosestBusStop` file

class BusToNearestStopResult {
  final double distance; // Distance in m
  final double duration; // Duration in mins

  BusToNearestStopResult({required this.distance, required this.duration});
}

// Singleton Instance of BusMovementService
final BusMovementService busMovementService = BusMovementService(
  databaseReference: FirebaseDatabase.instance.ref('bus-movement'),
);

Future<BusToNearestStopResult?> calculateBusToNearestStop() async {
  // Access the singleton instance directly
  LatLng busLocation = busMovementService.currentPosition;

  // Call stored location of nearest bus stop
  ClosestBusStopResult closestStopResult = await findClosestBusStop(busLocation);

  if (closestStopResult.busStop != null && closestStopResult.busStopLocation != null) {
    LatLng nearestBusStopLocation = closestStopResult.busStopLocation!;

    final Distance distance = Distance();
    double distanceInMeter = distance.as(
      LengthUnit.Meter,
      busLocation,
      nearestBusStopLocation,
    );

    // Calculate duration (assuming an average bus speed of 30 km/h)
    const double averageBusSpeedKmH = 30.0; // You can adjust this value
    double durationInHours = distanceInMeter / 1000 / averageBusSpeedKmH;
    double durationInMinutes = durationInHours * 60;

    // Return the result as an object
    return BusToNearestStopResult(
      distance: distanceInMeter,
      duration: durationInMinutes,
    );
  }
  return null;
}
