import 'package:firebase_database/firebase_database.dart';
import 'package:latlong2/latlong.dart';
import '/bus/bus_movement.dart';
import '/calculation/nearest_bus_stop.dart';

class BusToNearestStopResult {
  final double distance; // Distance in meters
  final double duration; // Duration in minutes

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
    // Get the distance in meters
    double distanceInMeter = distance.as(
      LengthUnit.Meter,
      busLocation,
      nearestBusStopLocation,
    );

    // Calculate duration (assuming an average bus speed of 30 km/h)
    const double averageBusSpeedKmH = 30.0;
    double distanceInKm = distanceInMeter / 1000; // Convert distance to kilometers for duration calculation
    double durationInHours = distanceInKm / averageBusSpeedKmH;
    double durationInMinutes = durationInHours * 60;

    // Return the result as an object with distance in meters
    return BusToNearestStopResult(
      distance: distanceInMeter, // Return distance in meters
      duration: durationInMinutes, // Duration in minutes
    );
  }
  return null;
}