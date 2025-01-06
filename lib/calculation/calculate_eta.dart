import 'package:latlong2/latlong.dart';
import 'package:osrm/osrm.dart';
import '/calculation/bus_distance.dart';
import '/calculation/nearest_bus_stop.dart';

class ETAInformation {
  final List<LatLng> points;
  final num distance; // Distance in meters
  final num duration;

  ETAInformation({
    required this.points,
    required this.distance,
    required this.duration,
  });
}

Future<ETAInformation?> fetchRoute(LatLng userLocation) async {
  // Find the nearest bus stop to the user's location
  ClosestBusStopResult closestStopResult = await findClosestBusStop(userLocation);

  if (closestStopResult.busStop == null) {
    return null; // Return null if no bus stop is found
  }

  // Set `from` as the user's location and `to` as the nearest bus stop
  LatLng from = userLocation;
  LatLng to = closestStopResult.busStop!.latLng;

  // Calculate the distance in meters
  double distanceInMeters = calculateDistance(
    from.latitude,
    from.longitude,
    to.latitude,
    to.longitude,
  );

  // Calculate walking duration in minutes (walking speed assumed 5 km/h)
  const double walkingSpeedKmH = 5.0;
  double durationInHours = distanceInMeters / 1000 / walkingSpeedKmH;
  double walkingDurationInMinutes = durationInHours * 60;

  // Create an OSRM instance and request route details
  final osrm = Osrm();
  final options = RouteRequest(
    coordinates: [
      (from.longitude, from.latitude),
      (to.longitude, to.latitude),
    ],
    overview: OsrmOverview.full,
  );

  final route = await osrm.route(options);

  // Extract route details (points along the route)
  final points = route.routes.first.geometry!.lineString!.coordinates.map((e) {
    var location = e.toLocation();
    return LatLng(location.lat, location.lng);
  }).toList();

  // Bus to nearest stop duration (calculated by the bus movement service)
  BusToNearestStopResult? busToStopResult = await calculateBusToNearestStop();
  if (busToStopResult == null) {
    return null; // Return null if bus to stop duration is not available
  }

  double busToBusStopDuration = busToStopResult.duration;

  // Return route information with distance in meters and total duration
  double totalDuration = walkingDurationInMinutes + busToBusStopDuration;

  return ETAInformation(
    points: points,
    distance: distanceInMeters, // Distance in meters
    duration: totalDuration, // Total duration in minutes
  );
}