import 'package:latlong2/latlong.dart';

class BusStop {
  final String name;
  final String description;
  final LatLng latLng;

  BusStop({
    required this.name,
    required this.description,
    required this.latLng,
  });

// Method to get the corresponding image path based on the bus stop name
String getImagePath() {
  switch (name) {
    case 'SL152 UIAM Timur':
      return 'assets/sl152.png';
    case 'SL153 KENMS':
      return 'assets/sl153.png';
    case 'SL154 Mahallah Safiyyah':
      return 'assets/sl154.png';
    case 'SL155 OSEM':
      return 'assets/sl155.png';
    case 'SL156 KAED':
      return 'assets/sl156.png';
    case 'SL157 Kuliyah Engineering':
      return 'assets/sl157.png';
    case 'SL158 Kuliyah Education':
      return 'assets/sl158.png';
    case 'SL159 UIAM (Utara)':
      return 'assets/sl159.png';
    case 'SL160 IRKHS':
      return 'assets/sl160.png';
    default:
      return 'assets/stopdefault.png';
    }
  }
}

// List of bus stops data
final List<BusStop> busStopsData = [
  BusStop(
    name: 'SL152 UIAM Timur',
    description: 'This is the eastern entrance bus stop.',
    latLng: const LatLng(3.249735, 101.738928),
  ),
  BusStop(
    name: 'SL153 KENMS',
    description: 'This is the KENMS faculty bus stop.',
    latLng: const LatLng(3.249143, 101.736764),
  ),
  BusStop(
    name: 'SL154 Mahallah Safiyyah',
    description: 'This is the Mahallah Safiyyah bus stop.',
    latLng: const LatLng(3.249411, 101.734706),
  ),
  BusStop(
    name: 'SL155 OSEM',
    description: 'This is the OSEM bus stop.',
    latLng: const LatLng(3.24959052365000, 101.7337247523525),
  ),
  BusStop(
    name: 'SL156 KAED',
    description: 'This is the Architecture Faculty bus stop.',
    latLng: const LatLng(3.250648, 101.731186),
  ),
  BusStop(
    name: 'SL157 Kuliyah Engineering',
    description: 'This is the Engineering Faculty bus stop.',
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
    name: 'SL160 IRKHS',
    description: 'This is the Irkhs faculty bus stop.',
    latLng: const LatLng(3.253111390523607, 101.73603089082691),
  ),
];