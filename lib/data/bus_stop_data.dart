// bus_stop_data.dart

import 'package:latlong2/latlong.dart';

// BusStop data model
class BusStop {
  final String name;
  final String description;
  final LatLng latLng;

  BusStop({
    required this.name,
    required this.description,
    required this.latLng,
  });
}

// List of bus stops data
final List<BusStop> busStopsData = [
  BusStop(
    name: 'SL157 Kuliyah Engineering',
    description: 'This is the engineering faculty bus stop.',
    latLng: const LatLng(3.254389214292341, 101.73218843951012),
  ),
  BusStop(
    name: 'SL158 Kuliyah Education',
    description: 'This is the education faculty bus stop.',
    latLng: const LatLng(3.2542205231421407, 101.73347585303627),
  ),
  BusStop(
    name: 'SL159 UIAM (Utara)',
    description: 'This is the northern entrance bus stop.',
    latLng: const LatLng(3.2541868287142095, 101.73428100650314),
  ),
  BusStop(
    name: 'SL160 Irkhs',
    description: 'This is the Irkhs faculty bus stop.',
    latLng: const LatLng(3.253111390523607, 101.73603089082691),
  ),
];