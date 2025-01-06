import 'dart:math';
import 'package:latlong2/latlong.dart';
import '/bus/bus_stop_data.dart';
/*
// Class to hold closest bus stop result
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

// Haversine formula to calculate distance in meters
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double p = 0.017453292519943295; // π/180
  final double a = 0.5 -
      cos((lat2 - lat1) * p) / 2 +
      cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a)) * 1000; // Distance in meters (multiplied by 1000)
}

Future<ClosestBusStopResult> findClosestBusStop(LatLng userLocation) async {
  if (busStopsData.isEmpty) {
    return ClosestBusStopResult(
      busStop: null,
      distance: double.infinity, // Distance in meters
      duration: double.infinity,
      busStopLocation: null,
    );
  }

  BusStop? closestStop;
  double shortestDistance = double.infinity;

  // Find the closest bus stop based on the shortest distance in meters
  for (BusStop stop in busStopsData) {
    final double dist = calculateDistance(
      userLocation.latitude,
      userLocation.longitude,
      stop.latLng.latitude,
      stop.latLng.longitude,
    );

    if (dist < shortestDistance) {
      shortestDistance = dist;
      closestStop = stop;
    }
  }

  LatLng? busStopLocation;
  double durationInMinutes = double.infinity;

  if (closestStop != null) {
    busStopLocation = LatLng(closestStop.latLng.latitude, closestStop.latLng.longitude);

    // Calculate walking duration (assuming an average walking speed of 5 km/h)
    const double averageWalkingSpeedKmH = 5.0;
    double durationInHours = shortestDistance / 1000 / averageWalkingSpeedKmH; // Convert to kilometers for walking speed calculation
    durationInMinutes = durationInHours * 60; // Convert hours to minutes
  }

  return ClosestBusStopResult(
    busStop: closestStop,
    distance: shortestDistance, // Distance in meters
    duration: durationInMinutes, // Duration in minutes
    busStopLocation: busStopLocation,
  );
}*/

// Class to hold closest bus stop result
class ClosestBusStopResult {
  final BusStop? busStop;
  final double distance; // Distance in meters
  final LatLng? busStopLocation;

  ClosestBusStopResult({
    required this.busStop,
    required this.distance,
    this.busStopLocation,
  });
}

// Haversine formula to calculate distance in meters
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double p = 0.017453292519943295; // π/180
  final double a = 0.5 -
      cos((lat2 - lat1) * p) / 2 +
      cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a)) * 1000; // Distance in meters (multiplied by 1000)
}

Future<ClosestBusStopResult> findClosestBusStop(LatLng userLocation) async {
  if (busStopsData.isEmpty) {
    return ClosestBusStopResult(
      busStop: null,
      distance: double.infinity, // Distance in meters
      busStopLocation: null,
    );
  }

  BusStop? closestStop;
  double shortestDistance = double.infinity;

  // Find the closest bus stop based on the shortest distance in meters
  for (BusStop stop in busStopsData) {
    final double dist = calculateDistance(
      userLocation.latitude,
      userLocation.longitude,
      stop.latLng.latitude,
      stop.latLng.longitude,
    );

    if (dist < shortestDistance) {
      shortestDistance = dist;
      closestStop = stop;
    }
  }

  LatLng? busStopLocation;

  if (closestStop != null) {
    busStopLocation = LatLng(closestStop.latLng.latitude, closestStop.latLng.longitude);
  }

  return ClosestBusStopResult(
    busStop: closestStop,
    distance: shortestDistance, // Distance in meters
    busStopLocation: busStopLocation,
  );
}

