//import 'dart:js_util';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'dart:async';

import '/pages/schedule.dart';

import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'station_popup.dart';
import 'data/bus_stop_data.dart';

import 'package:firebase_database/firebase_database.dart';

class MapDisplay extends StatefulWidget {
  const MapDisplay({super.key});

  @override
  State<MapDisplay> createState() => _MapDisplayState();
}

class _MapDisplayState extends State<MapDisplay> with TickerProviderStateMixin {
  
  bool _followBus = false; // Bool variable when bus is pressed.

  //Testing Database fetching
  DatabaseReference databaseReference = FirebaseDatabase.instance
      .ref()
      .child('UsersData/3MkbQmmrGtUJlmUZPdXPk5NhkRg1/gps_readings');

  String latitude = '';
  String longitude = '';

  final List<LatLng> busRoute = [
    const LatLng(3.249590, 101.733724),
    const LatLng(3.249790, 101.733324),
    const LatLng(3.249990, 101.732824),
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
  final PopupController busStopsPopupController = PopupController();
  final PopupController busPopupController = PopupController();
  // Animated map controller
  late final animatedMapController = AnimatedMapController(
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _currentIndex++;
        if (_currentIndex >= busRoute.length) _currentIndex = 0;
        _currentPosition = _nextPosition;
        _nextPosition = busRoute[_currentIndex];
        
      
        if (_followBus) {
          //mapController.move(_currentPosition, _currentZoom); // Move the map to follow the bus
          animatedMapController.centerOnPoint(
            _currentPosition,
            curve: Curves.fastEaseInToSlowEaseOut,
            duration: const Duration(seconds: 3)
          );
        } 
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
          //Button to stop following bus (only appears when bus is pressed)
          if(_followBus)
            Positioned(
              bottom: 100,
              right: 16,
              child: CircleAvatar(
                radius: 30, // Adjust size
                backgroundColor: const Color.fromARGB(255, 218, 222, 230),
                child: IconButton(
                  icon: Image.asset(
                    'assets/stopFollowingBus.png',
                    fit: BoxFit.cover,
                    width: 40,
                    height: 40,
                  ),
                  onPressed: () {
                    setState(() {
                      _followBus = false;
                    });
                  },
                ),
              ),
            ),
          // Firebase data display
          Positioned(
            top: 100,
            left: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Latitude: $latitude'),
                Text('Longitude: $longitude'),
              ],
            ),
          ),
          // Schedule Page Button
          Positioned(
            top: 100,
            right: 16,
            child: CircleAvatar(
              radius: 30, // Adjust size
              backgroundColor: const Color.fromARGB(255, 20, 124, 27),
              child: IconButton(
                icon: Image.asset(
                  'assets/scheduleButtonBW.png',
                  fit: BoxFit.cover,
                  width: 40,
                  height: 40,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SchedulePage()),
                  );
                },
              ),
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
                    //color: Colors.grey.shade300,
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

  Widget _buildMap() {
    return FlutterMap(
      //mapController: mapController, // Attach the map controller here
      mapController: animatedMapController.mapController,
      options: MapOptions(
        initialCenter: const LatLng(3.2525, 101.7345),
        initialZoom: 17.00,
        //onTap: (_, __) => popupController.hideAllPopups(), // Hide popups on map tap
        onTap: (_, __) {
          // Dismiss the popup immediately when tapping anywhere on the map
          if (_followBus) {
            setState(() {
              _followBus = false;
            });
          }
          busStopsPopupController.hideAllPopups();
          busPopupController.hideAllPopups();
          //_followBus = false; // Disable follow mode
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        /* Old code for reference
        TweenAnimationBuilder<LatLng>(
          tween: LatLngTween(begin: _currentPosition, end: _nextPosition),
          duration: const Duration(seconds: 3),
          builder: (context, position, child) {
             return MarkerLayer(
              //Bus moving marker (Bus 1)
              markers: [
                //Bus moving marker (Original Coding)
                Marker(
                  point: position,
                  width: 25,
                  height: 25,
                  child: const Icon(Icons.directions_bus, color: Colors.red),
                ), 
                // Add all the bus stop markers
                ...busStops,
                //Converting location from database to marker
                Marker(
                  point: LatLng(
                    //double.parse(latitude),
                    //double.parse(longitude)
                    double.tryParse(latitude) ?? 0.0,
                    double.tryParse(longitude) ?? 0.0,
                    ),
                  child: const Icon(Icons.directions_bus, color: Colors.blueAccent)
                  ),
              ],
            ); 
          },
        ),
        */
        TweenAnimationBuilder<LatLng>(
          tween: LatLngTween(begin: _currentPosition, end: _nextPosition),
          duration: const Duration(seconds: 3),
          builder: (context, position, child) {
            return PopupMarkerLayer(
              options: PopupMarkerLayerOptions(
                markers: [
                  // Moving bus as a popup marker
                  Marker(
                    point: position,
                    width: 30,
                    height: 30,
                    //child: const Icon(Icons.directions_bus, color: Colors.red),
                    child: Icon(
                      Icons.directions_bus,
                      color: _followBus ? Colors.blue : Colors.red,
                    ),
                  ),
                ],
                popupController: busPopupController,
                markerTapBehavior: MarkerTapBehavior.custom(
                  (popupSpec, popupState, popupController) {
                    
                    if (_followBus == false) {
                      // Show the popup for the bus marker
                      //popupController.togglePopup(popupSpec.marker);
                    }
                    
                    setState(() {
                      // Toggle follow mode when the bus marker is tapped
                      _followBus = true;
                    });
                  },
                ),
                popupDisplayOptions: PopupDisplayOptions(
                  builder: (BuildContext context, Marker marker) {
                    return const Align(

                    );
                  },
                  snap: PopupSnap.markerTop,
                  animation: const PopupAnimation.fade(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                ),
              ),
            );
          },
        ),

        PopupMarkerLayer(
          options: PopupMarkerLayerOptions(
            markers: busStops,
            popupController: busStopsPopupController,
            markerTapBehavior: MarkerTapBehavior.togglePopupAndHideRest(),
            popupDisplayOptions: PopupDisplayOptions(
              builder: (BuildContext context, Marker marker){
                // Find the associated bus stop information for the marker
                final BusStop busStop = busStopsData.firstWhere(
                  (stop) => stop.latLng == marker.point,
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
        key: ValueKey(stop.latLng), // Use the bus stop location as a unique key
        point: stop.latLng,
        width: 40,
        height: 40,
        child: const Icon(Icons.location_on, color: Colors.green),
      );
    }).toList();
  }

}