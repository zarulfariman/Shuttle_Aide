import 'package:latlong2/latlong.dart';
import 'package:osrm/osrm.dart';
import '/calculation/bus_distance.dart';
import '/calculation/nearest_bus_stop.dart';

class RouteInformation {
  final List<LatLng> points;
  final num distance;
  final num duration;

  RouteInformation({
    required this.points,
    required this.distance,
    required this.duration,
  });
}

Future<RouteInformation?> fetchRoute(LatLng from, LatLng to) async {

  final osrm = Osrm();
  final options = RouteRequest(
    coordinates: [
      (from.longitude, from.latitude),
      (to.longitude, to.latitude),
    ],
    overview: OsrmOverview.full,
  );

  final route = await osrm.route(options);
  final points = route.routes.first.geometry!.lineString!.coordinates.map((e) {
    var location = e.toLocation();
    return LatLng(location.lat, location.lng);
  }).toList();

  final distance = route.routes.first.distance!; // distance from user to the bus stop

  // Get the closest bus stop duration (user to bus stop)
  ClosestBusStopResult closestStopResult = await findClosestBusStop(from);
  double userToBusStopDuration = closestStopResult.distance / 1000 / 30 * 60; // Assuming 30 km/h

  // bus to bus stop duration
  BusToNearestStopResult? busToNearestStopResult = await calculateBusToNearestStop();
  double busToBusStopDuration = busToNearestStopResult?.duration ?? 0.0;

  // Sum both durations
  double totalDuration = userToBusStopDuration + busToBusStopDuration; // bus to user ETA

  return RouteInformation(
    points: points,
    distance: distance,
    duration: totalDuration,
  );
}