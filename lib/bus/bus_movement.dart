import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:latlong2/latlong.dart';

class BusMovementService {
  final DatabaseReference databaseReference;
  final List<LatLng> busRoute;

  late Timer _timer;
  int _currentIndex = 0;
  LatLng _currentPosition;
  LatLng _nextPosition;
  final Duration updateInterval;

  final StreamController<LatLng> _positionStreamController = StreamController<LatLng>.broadcast();

  BusMovementService({
    required this.databaseReference,
    required this.busRoute,
    this.updateInterval = const Duration(seconds: 3),
  })  : _currentPosition = busRoute.first,
        _nextPosition = busRoute.first;

  Stream<LatLng> get positionStream => _positionStreamController.stream;

  void startTracking({bool followBus = false, Function(LatLng)? onPositionUpdate}) {
    _timer = Timer.periodic(updateInterval, (timer) {
      _currentIndex++;
      if (_currentIndex >= busRoute.length) _currentIndex = 0;
      _currentPosition = _nextPosition;
      _nextPosition = busRoute[_currentIndex];

      if (followBus) {
        onPositionUpdate?.call(_currentPosition);
      }

      _positionStreamController.add(_currentPosition);
    });

    _listenToFirebase();
  }

  void _listenToFirebase() {
    databaseReference.limitToLast(1).onValue.listen((event) {
      final dataSnapshot = event.snapshot;
      final data = dataSnapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        final latestReading = data.entries.first.value;
        double newLatitude = double.parse(latestReading['latitude'].toString());
        double newLongitude = double.parse(latestReading['longitude'].toString());

        _nextPosition = LatLng(newLatitude, newLongitude);
      }
    });
  }

  void stopTracking() {
    _timer.cancel();
    _positionStreamController.close();
  }

  LatLng get currentPosition => _currentPosition;

  LatLng get nextPosition => _nextPosition;
}
