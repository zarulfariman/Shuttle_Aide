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
    case 'SL161 Aikol':
      return 'assets/sl161.png';
    case 'KICT Gazebo':
      return 'assets/kict.png';
    case 'Mahallah Pickup/Drop 1':
      return 'assets/mahallah1.png';
    case 'Mahallah Pickup/Drop 2':
      return 'assets/mahallah2.png';
    case 'Mahallah Pickup/Drop 3':
      return 'assets/mahallah3.png';
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
  BusStop(
    name: 'SL161 Aikol',
    description: 'This is the Library & AIKOL faculty bus stop.',
    latLng: const LatLng(3.252328016224476, 101.73870026354851),
  ),
  BusStop(
    name: 'KICT Gazebo',
    description: 'This is the KICT bus pickup/drop point.',
    latLng: const LatLng(3.25430969603212, 101.7288319783508),
  ),
  BusStop(
    name: 'Mahallah Pickup/Drop 1',
    description: 'This is the bus pickup/drop point for Mahallah Aminah, Hafsah & Asma',
    latLng: const LatLng(3.2556577727551512, 101.73320916635936),
  ),
  BusStop(
    name: 'Mahallah Pickup/Drop 2',
    description: 'This is the bus pickup/drop point for Mahallah Asiah',
    latLng: const LatLng(3.2580733451288224, 101.73360457765988),
  ),
  BusStop(
    name: 'Mahallah Pickup/Drop 3',
    description: 'This is the bus pickup/drop point for Mahallah Ruqayyah, Halimah and Maryam',
    latLng: const LatLng(3.259233924760964, 101.73443386890928),
  ),
];