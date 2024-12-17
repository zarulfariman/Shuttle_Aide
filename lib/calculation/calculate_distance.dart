import 'package:latlong2/latlong.dart';
import '../bus/bus_stop_data.dart';

class ClosestBusStopResult {
  final BusStop? busStop;
  final double distance;

  ClosestBusStopResult({required this.busStop, required this.distance});
}

Future<ClosestBusStopResult> findClosestBusStop(LatLng userLocation, List<BusStop> busStops) async {
  if (busStops.isEmpty) ClosestBusStopResult(busStop: null, distance: double.infinity);

  // Instantiate Distance to calculate distances
  final Distance distance = Distance();

  // Find the closest bus stop
  BusStop? closestStop;
  double shortestDistance = double.infinity;

  for (BusStop stop in busStops) {
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

  return ClosestBusStopResult(busStop: closestStop, distance: shortestDistance); // will call the name and description of the bus stop nearest
}

