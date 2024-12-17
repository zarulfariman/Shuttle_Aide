import 'package:latlong2/latlong.dart';
import 'package:osrm/osrm.dart';

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

// Function to fetch route details
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

  final distance = route.routes.first.distance!;
  final duration = route.routes.first.duration!;

  return RouteInformation(
    points: points,
    distance: distance,
    duration: duration,
  );
}
