import 'package:latlong2/latlong.dart';
import '../bus/bus_stop_data.dart';

class ClosestBusStopResult {
  final BusStop? busStop;
  final double distance;
  final double? latitude;
  final double? longitude;
  final LatLng? busStopLocation;

  ClosestBusStopResult({required this.busStop, required this.distance, this.latitude, this.longitude, this.busStopLocation});
}

Future<ClosestBusStopResult> findClosestBusStop(LatLng userLocation) async {
  if (busStopsData.isEmpty) {
    return ClosestBusStopResult(
      busStop: null,
      distance: double.infinity,
      latitude: null,
      longitude: null,
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
  if (closestStop != null) {
    // Store latitude and longitude masuk busStopLocation
    busStopLocation = LatLng(closestStop.latLng.latitude, closestStop.latLng.longitude);
  }

  return ClosestBusStopResult(
    busStop: closestStop,
    distance: shortestDistance,
    busStopLocation: busStopLocation, // Directly store LatLng here
  );
}


