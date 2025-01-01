import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:latlong2/latlong.dart';

class BusMovementService {
  final DatabaseReference databaseReference;

  late Timer _timer;
  LatLng _currentPosition;
  LatLng _nextPosition;
  final Duration updateInterval;

  final StreamController<LatLng> _positionStreamController = StreamController<LatLng>.broadcast();

  BusMovementService({
    required this.databaseReference,
    this.updateInterval = const Duration(seconds: 3),
  })  : _currentPosition = LatLng(3.249590, 101.733724),
        _nextPosition = LatLng(3.249590, 101.733724);

  Stream<LatLng> get positionStream => _positionStreamController.stream;

  void startTracking({bool followBus = false, Function(LatLng)? onPositionUpdate}) {
    _listenToFirebase();

    _timer = Timer.periodic(updateInterval, (timer) {
      _currentPosition = _nextPosition;

      if (followBus) {
        onPositionUpdate?.call(_currentPosition);
      }

      // Notify listeners with the updated position
      _positionStreamController.add(_currentPosition);
    });
  }

  void _listenToFirebase() {
    databaseReference.limitToLast(1).onValue.listen((event) {
      final dataSnapshot = event.snapshot;
      final data = dataSnapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        final latestReading = data.entries.last.value;

        // Update nextPosition with Firebase values
        double newLatitude = double.parse(latestReading['latitude'].toString());
        double newLongitude = double.parse(latestReading['longitude'].toString());

        // Update current and next positions
        _currentPosition = _nextPosition;
        _nextPosition = LatLng(newLatitude, newLongitude);

        // Notify listeners with the updated position
        _positionStreamController.add(_nextPosition);
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
