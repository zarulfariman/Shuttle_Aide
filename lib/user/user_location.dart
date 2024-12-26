import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shuttle_aide/calculation/calculate_eta.dart';
import 'package:shuttle_aide/calculation/nearest_bus_stop.dart';

class RouteService {
  LatLng? _from;
  LatLng? _to;
  LatLng? userLocation;
  double? userLatitude;
  double? userLongitude;
  bool hasLocationPermission = false;
  List<LatLng> routePoints = [];

  // Method to update `from` or `to`
  void updateRoutePoint(LatLng point, bool isFrom) {
    if (isFrom) {
      _from = point;
    } else {
      _to = point;
    }
  }

  // Method to initialize and fetch route
  Future<bool> initializeLocationAndRoute() async {
    if (_from != null && _to != null) {
      final permissionGranted = await initializeLocation(_to!);
      return permissionGranted;
    }
    return false;
  }

  // Existing initializeLocation method
  Future<bool> initializeLocation(LatLng destination) async {
    final status = await Permission.location.request();
    if (status == PermissionStatus.granted) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      userLatitude = position.latitude;
      userLongitude = position.longitude;

      if (userLatitude != null && userLongitude != null) {
        userLocation = LatLng(userLatitude!, userLongitude!);

        ClosestBusStopResult closestBusStopResult = await findClosestBusStop(userLocation!);
        LatLng? closestStopLocation = closestBusStopResult.busStopLocation;

        _from ??= userLocation; // Use user location as `from`
        _to ??= closestStopLocation; // Use nearest bus stop as `to`

        final routeInfo = await fetchRoute(_from!);

        if (routeInfo != null) {
          routePoints = routeInfo.points;
        }
        hasLocationPermission = true;
      }
    } else {
      hasLocationPermission = false;
    }
    return hasLocationPermission;
  }

// Method to get the user's location
  LatLng? getUserLocation() {
    return userLocation;
  }
}