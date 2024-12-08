import 'package:permission_handler/permission_handler.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'dart:async';

import '/pages/schedule.dart';

import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'station_popup.dart';
import 'data/bus_stop_data.dart';

import 'package:firebase_database/firebase_database.dart';

class MapDisplay extends StatefulWidget {
  const MapDisplay({super.key});

  @override
  State<MapDisplay> createState() => _MapDisplayState();
}

class _MapDisplayState extends State<MapDisplay> with TickerProviderStateMixin {
  
  bool _hasLocationPermission = false; // Tracks whether the user granted location permission.

  bool _followBus = false; // Bool variable when bus is pressed.
  bool _visible = false;
  String panelContent = 'Bus Route Info'; // Default content of the sliding panel.

  // Bus information (dummy values for now; replace with actual data)
  String selectedBusInfo = "Bus ID: 001\nDriver: John Doe\nRoute: A to B";

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
  late final StreamController<double?> _alignPositionStreamController; // For aligning map to user's current position
  // Animated map controller
  late final animatedMapController = AnimatedMapController(
    vsync: this,
  );
  //Animation controller
  late AnimationController _heightAnimationController;
  late Animation<double> _minHeightAnimation;

  // Function to check and request location permissions
  Future<void> _checkLocationPermission() async {
    final status = await Permission.location.request();
    if (status == PermissionStatus.granted) {
      setState(() {
        _hasLocationPermission = true; // Permission granted
      });
    } else {
      setState(() {
        _hasLocationPermission = false; // Permission denied
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLocationPermission(); // Check and request location permission on app start.
    _alignPositionStreamController = StreamController<double?>();
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
            curve: Curves.easeInOut,
            duration: const Duration(seconds: 2)
          );
        } 
      });

    });

    // Initialize the animation controller
    _heightAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Set default animation for minHeight
    _minHeightAnimation = Tween<double>(
      begin: 0.1, // Default minHeight
      end: 0.2, // Increased minHeight
    ).animate(CurvedAnimation(
      parent: _heightAnimationController,
      curve: Curves.easeInOut,
    ));

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
    _heightAnimationController.dispose();
  }
  /*
  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      minHeight: MediaQuery.of(context).size.height * _minHeightAnimation.value,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      parallaxEnabled: true,
      body: Stack(
        children: [
          _buildMap(),
          //Button to stop following bus (only appears when bus is pressed)
          if(_followBus)
            Positioned(
              top: 400,
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
                      panelContent = 'Bus Route Info'; // Reset to default content
                    });
                    _heightAnimationController.reverse(); // Animate back to default minHeight
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
          Positioned(
            top: 300,
            right: 16,
            child: CircleAvatar(
              radius: 30, // Adjust size
              backgroundColor: const Color.fromARGB(255, 20, 124, 27),
              child: IconButton(
                icon: Image.asset(
                  'assets/rotateResetBW.png',
                  fit: BoxFit.cover,
                  width: 40,
                  height: 40,
                ),
                onPressed: () {
                  animatedMapController.animatedRotateReset(
                    curve: Curves.easeIn,
                    duration: const Duration(milliseconds: 700),
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
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  //'Panel Content: Bus Route Info',
                  _followBus ? selectedBusInfo : panelContent,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        );
      },
    );
  }*/

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _heightAnimationController,
      builder: (context, child) {
        return SlidingUpPanel(
          minHeight: MediaQuery.of(context).size.height * _minHeightAnimation.value,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          parallaxEnabled: true,
          body: Stack(
            children: [
              _buildMap(),
              //if (_followBus)
              //Tap anywhere to stop following bus text (Tap-able)
                AnimatedOpacity(
                  opacity: _visible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 250,
                        left: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _followBus = false;
                              _visible = false;
                            });
                          },
                          child: const Text(
                            "Tap anywhere to stop following",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              shadows: [
                                Shadow(
                                  blurRadius: 8.0,
                                  color: Color.fromARGB(255, 162, 168, 163),
                                  offset: Offset(2.0, 2.0)
                                )
                              ]
                            ),
                          ),
                        )
                      ),
                    ], 
                  ),
                ),
              //Schedule button code
              Positioned(
                top: 100,
                right: 16,
                child: CircleAvatar(
                  radius: 30,
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
                        MaterialPageRoute(builder: (context) => const SchedulePage()),
                      );
                    },
                  ),
                ),
              ),
              //Conditional "center map to user's current position" button
              if(_hasLocationPermission)
                Positioned(
                  top: 200, // Position the button at the bottom
                  right: 16,   // Position the button to the right
                  child: CircleAvatar(
                    radius: 30, // Adjust size
                    backgroundColor: const Color.fromARGB(255, 20, 124, 27),
                    child: IconButton(
                      icon: const Icon(Icons.my_location, color: Colors.white), // My location icon
                      onPressed: () {
                        _alignPositionStreamController.add(null);
                        animatedMapController.animatedRotateReset(
                          curve: Curves.easeInOut,
                          duration: const Duration(milliseconds: 500),
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
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _followBus ? selectedBusInfo : panelContent,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            );
          },
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
        onTap: (_, __) {
          if (_followBus) {
            setState(() {
              _followBus = false; // Dismiss the popup immediately when tapping anywhere on the map
              //_visible = !_visible;
              _visible = false;
              panelContent = 'Bus Route Info'; // Reset to default content
            });
            _heightAnimationController.reverse(); // Animate back to default minHeight
          }
          busStopsPopupController.hideAllPopups();
          busPopupController.hideAllPopups();
        },
        onPositionChanged: (MapCamera camera, bool hasGesture) {
          animatedMapController.cancelPreviousAnimations;
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        // Conditionally display the CurrentLocationLayer
        if (_hasLocationPermission)
          CurrentLocationLayer(
            alignPositionStream: _alignPositionStreamController.stream,
            alignPositionAnimationCurve: Curves.easeInOut,
            alignPositionAnimationDuration: const Duration(milliseconds: 500),
            style: LocationMarkerStyle(
              marker: const Icon(
                Icons.circle_rounded,
                color: Colors.blue,
                size: 30,
              ),
              accuracyCircleColor: Colors.blue.withOpacity(0.1),
              headingSectorColor: Colors.blue.withOpacity(0.8),
              headingSectorRadius: 120,
            ),
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
                    /*child: Icon(
                      Icons.directions_bus,
                      color: _followBus ? Colors.blue : Colors.red,
                    ),
                    child: CircleAvatar(
                      backgroundColor: _followBus ?const Color.fromARGB(255, 49, 168, 75) : const Color.fromARGB(255, 146, 209, 160),
                      child: const Icon(
                        Icons.directions_bus, 
                        color: Color.fromARGB(255, 219, 9, 33)
                      ),
                    )*/
                    child: Container(
                      decoration: ShapeDecoration(
                        color: _followBus ? Colors.blue.shade100 : Colors.grey.shade100, // Subtle light background
                        shape: CircleBorder(
                          eccentricity: 1.0,
                          side: BorderSide(
                            color: _followBus ? Colors.teal.shade400 : Colors.teal.shade200, // Calming green/teal for the border
                            width: 2, // Slightly thicker for better visibility
                          ),
                        ),
                      ),
                      child: const Icon(
                        Icons.directions_bus,
                        color: Color.fromARGB(255, 0, 0, 139),
                      ),
                    ),
                  ),
                ],
                popupController: busPopupController,
                markerTapBehavior: MarkerTapBehavior.custom(
                  (popupSpec, popupState, popupController) {
                    setState(() {
                      // Toggle follow mode when the bus marker is tapped
                      _followBus = true;
                      _visible = true;
                      panelContent = selectedBusInfo; // Update content with bus info
                    });
                    _heightAnimationController.forward(); // Animate to higher minHeight
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