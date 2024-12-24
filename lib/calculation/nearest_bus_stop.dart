import 'package:latlong2/latlong.dart';
import '../bus/bus_stop_data.dart';

class ClosestBusStopResult {
  final BusStop? busStop;
  final double distance; // Distance in meters
  final double duration; // Duration in minutes
  final LatLng? busStopLocation;

  ClosestBusStopResult({
    required this.busStop,
    required this.distance,
    required this.duration,
    this.busStopLocation,
  });
}

Future<ClosestBusStopResult> findClosestBusStop(LatLng userLocation) async {
  if (busStopsData.isEmpty) {
    return ClosestBusStopResult(
      busStop: null,
      distance: double.infinity,
      duration: double.infinity,
      busStopLocation: null,
    );
  }

  // Instantiate Distance to calculate distances
  final Distance distance = Distance();

  // Find the closest bus stop
  BusStop? closestStop;
  double shortestDistance = double.infinity;

  for (BusStop stop in busStopsData) {
    final double dist = distance.as(
      LengthUnit.Meter,
      userLocation,
      stop.latLng,
    );

    if (dist < shortestDistance) {
      shortestDistance = dist;
      closestStop = stop;
    }
  }

  LatLng? busStopLocation;
  double durationInMinutes = double.infinity;

  if (closestStop != null) {
    // Store latitude and longitude in busStopLocation
    busStopLocation = LatLng(closestStop.latLng.latitude, closestStop.latLng.longitude);

    // Calculate duration (assuming an average walking speed of 5 km/h)
    const double averageWalkingSpeedKmH = 5.0;
    double durationInHours = shortestDistance / 1000 / averageWalkingSpeedKmH;
    durationInMinutes = durationInHours * 60;
  }

  return ClosestBusStopResult(
    busStop: closestStop,
    distance: shortestDistance,
    duration: durationInMinutes,
    busStopLocation: busStopLocation,
  );
}
