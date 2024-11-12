import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'dart:async';

import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'station_popup.dart';
import 'data/bus_stop_data.dart';

import 'package:firebase_database/firebase_database.dart';

class MapDisplay extends StatefulWidget {
  const MapDisplay({super.key});

  @override
  State<MapDisplay> createState() => _MapDisplayState();
}

class _MapDisplayState extends State<MapDisplay> {
  
  //Testing Database fetching
  DatabaseReference databaseReference = FirebaseDatabase.instance
      .ref()
      .child('UsersData/3MkbQmmrGtUJlmUZPdXPk5NhkRg1/gps_readings');

  String latitude = '';
  String longitude = '';

  final List<LatLng> busRoute = [
    const LatLng(3.249590, 101.733724),
    const LatLng(3.250176, 101.732586),
    const LatLng(3.250715, 101.731209),
    const LatLng(3.251905, 101.730243),
  ];

// List of markers for bus stops 
late List<Marker> busStops;

  late Timer _timer;
  int _currentIndex = 0;
  LatLng _currentPosition = const LatLng(3.249590, 101.733724);
  LatLng _nextPosition = const LatLng(3.249590, 101.733724);

  // Create controllers for the map and popups
  final MapController mapController = MapController();
  final PopupController popupController = PopupController();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _currentIndex++;
        if (_currentIndex >= busRoute.length) _currentIndex = 0;
        _currentPosition = _nextPosition;
        _nextPosition = busRoute[_currentIndex];
      });
    });

    // Initialize the bus stop markers from busStopsData
    busStops = _createBusStopMarkers(busStopsData);

    // Fetch data from Firebase
    readData();
    }

    // Function to read data from Firebase
    void readData() {
      databaseReference.limitToLast(1).onValue.listen((event) {
        final dataSnapshot = event.snapshot;
        final data = dataSnapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          final latestReading = data.entries.first.value;
          setState(() {
            latitude = latestReading['latitude'].toString();
            longitude = latestReading['longitude'].toString();
          });
        }
      });
    }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      minHeight: MediaQuery.of(context).size.height * 0.1,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      parallaxEnabled: true,
      body: Stack(
        children: [
          _buildMap(),
          Positioned(
            top: 20,
            left: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Latitude: $latitude'),
                Text('Longitude: $longitude'),
              ],
            ),
          ),
        ],
      ),
      panelBuilder: (controller) {
        return SingleChildScrollView(
          controller: controller,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 15),
                  height: 6,
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Panel Content: Bus Route Info',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        );
      },
    );
  }



/*
  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      minHeight: MediaQuery.of(context).size.height * 0.1,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      parallaxEnabled: true,
      body: _buildMap(), // Map as the background
      panelBuilder: (controller) {
        return SingleChildScrollView(
          controller: controller,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 15),
                  height: 6,
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Panel Content: Bus Route Info',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
*/
  Widget _buildMap() {
    return FlutterMap(
      mapController: mapController, // Attach the map controller here
      options: MapOptions(
        initialCenter: const LatLng(3.2525, 101.7345),
        initialZoom: 17.00,
        onTap: (_, __) => popupController.hideAllPopups(), // Hide popups on map tap
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        TweenAnimationBuilder<LatLng>(
          tween: LatLngTween(begin: _currentPosition, end: _nextPosition),
          duration: const Duration(seconds: 3),
          builder: (context, position, child) {
            return MarkerLayer(
              markers: [
                Marker(
                  point: position,
                  width: 25,
                  height: 25,
                  child: const Icon(Icons.directions_bus, color: Colors.red),
                ),
                // Add all the bus stop markers
                ...busStops,
              ],
            );
          },
        ),
        PopupMarkerLayer(
          options: PopupMarkerLayerOptions(
            markers: busStops,
            popupController: popupController,
            markerTapBehavior: MarkerTapBehavior.togglePopupAndHideRest(),
            popupDisplayOptions: PopupDisplayOptions(
              builder: (BuildContext context, Marker marker){
                // Find the associated bus stop information for the marker
                final BusStop busStop = busStopsData.firstWhere(
                  (stop) => stop.latLng == marker.point
                );

                // Pass the image path corresponding to the bus stop
                String imagePath = 'assets/stopdefault.png'; //Default image
                
                if (busStop.name == 'SL157 Kuliyah Engineering') {
                  imagePath = 'assets/sl157.png';
                } else if (busStop.name == 'SL158 Kuliyah Education') {
                  imagePath = 'assets/sl158.png';
                } else if (busStop.name == 'SL159 UIAM (Utara)') {
                  imagePath = 'assets/sl159.png';
                } else if (busStop.name == 'SL160 Irkhs') {
                  imagePath = 'assets/sl160.png';
                }

                return StationPopup(
                    marker: marker,
                    stopName: busStop.name,
                    description: busStop.description,
                    imagePath: imagePath,
                  );
              },
              // Use the PopupSnap enum you defined for controlling the popup position
              snap: PopupSnap.markerTop,  // Centers popup on the marker

              // Use the PopupAnimation.fade for the fade-in effect
              animation: const PopupAnimation.fade(
              duration: Duration(milliseconds: 400),  // Custom duration
              curve: Curves.easeInOut,  // Custom animation curve
              ),
            ),

            selectedMarkerBuilder: (context, marker) => const Icon(
              Icons.location_on,
              size: 22,
              color: Colors.blue
            ),
            markerCenterAnimation: const MarkerCenterAnimation(
              duration: Duration(milliseconds: 500),
            )
          )
        )
      ],
    );
  }

  List<Marker> _createBusStopMarkers(List<BusStop> stops) {
    return stops.map((stop) {
      return Marker(
        point: stop.latLng,
        width: 40,
        height: 40,
        child: const Icon(Icons.location_on, color: Colors.green),  // Default marker color
      );
    }).toList();
  }

}