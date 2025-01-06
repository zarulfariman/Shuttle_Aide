import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '/pages/schedule.dart';
import '/pages/announcement.dart';

import '/bus/bus_movement.dart';
import '/bus/bus_stop_data.dart';
import '/bus/station_popup.dart';

import '/calculation/calculate_eta.dart';

import '/data/route.dart';
import '/user/user_location.dart';

//Trial for nearest bus stop
import 'calculation/nearest_bus_stop.dart';
import 'package:geolocator/geolocator.dart';
//Trial for ETA
import 'package:osrm/osrm.dart';

class MapDisplay extends StatefulWidget {
  const MapDisplay({super.key});

  @override
  State<MapDisplay> createState() => _MapDisplayState();
}

class _MapDisplayState extends State<MapDisplay> with TickerProviderStateMixin {

  ClosestBusStopResult? closestBusStop;
  Timer? _timer;
  num etaToNearestBusStop = 0.0;
  num distanceToNearestBusStop  = 0.0;

  bool _hasLocationPermission = false; // Tracks whether the user granted location permission.
  bool _followBus = false; // Bool variable when bus is pressed.
  bool _visible = false;

  final RouteService routeService = RouteService();
  late BusMovementService busMovementService;
  // bus to bus stop duration
  // for route and polypoints punya
  LatLng? userLocation;
  var points = <LatLng>[]; // Initialize points as an empty list
  num distance = 0.0;
  num duration = 0.0;
  bool isPairly = false; // Declare and initialize isPairly untuk polyline marker

  double totalDistance = 0.0;

  // List of markers for bus stops
  late List<Marker> busStops;

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

  @override
  void initState() {
    super.initState();
    //Trial
    _startUpdatingNearestBusStop();
    _alignPositionStreamController = StreamController<double?>();
    busMovementService = BusMovementService(
        databaseReference : FirebaseDatabase.instance
        .ref()
        .child('UsersData/3MkbQmmrGtUJlmUZPdXPk5NhkRg1/gps_readings'),
    );

    busMovementService.startTracking(
      followBus: _followBus,
      onPositionUpdate: (position) {
        if (_followBus) {
          animatedMapController.centerOnPoint(
            position,
            curve: Curves.easeInOut,
            duration: const Duration(seconds: 1),
          );
        }
      },
    );

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

    // // Initialize the bus stop markers from busStopsData
    busStops = _createBusStopMarkers(busStopsData);

    _initializeLocation();
  }

  
  Future<void> _initializeLocation() async {
    const destination = LatLng(3.2542205231421407, 101.73347585303627); // adjust bila integrate dengan firebase

    final permissionGranted = await routeService.initializeLocation(destination);
  
    if (permissionGranted) {
      final userLoc = routeService
          .userLocation; // Fetch user location from routeService

      if (userLoc != null) {
        // Calculate distance and duration using fetchRoute
        final routeInfo = await fetchRoute(userLoc);

        if (routeInfo != null) {
          setState(() {
            _hasLocationPermission = routeService.hasLocationPermission;
            userLocation = routeService.userLocation;

            // Set only distance and duration from fetchRoute
            distance = routeInfo.distance;
            duration = routeInfo.duration;

            // Polyline
            points = routeService.routePoints;
          });
        }
      }
    }
  }
  

  @override
  void dispose() {
    super.dispose();
    //Trial
    _timer?.cancel();
    _heightAnimationController.dispose();
    busMovementService.stopTracking();
  }
  
  //Function to fetch nearest bus stop, and update eta+distance every 15 seconds
  void _startUpdatingNearestBusStop() {
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        LatLng userLocation = LatLng(position.latitude, position.longitude);

        ClosestBusStopResult result = await findClosestBusStop(userLocation);

        if (result.busStopLocation != null) {
          LatLng busLocation = busMovementService.currentPosition;
          LatLng closestStopCoordinates = result.busStopLocation!; // Safe null check

          Map<String, num> etaDistance =
              await calculateETADistance(busLocation, closestStopCoordinates);

          setState(() {
            closestBusStop = result;
            etaToNearestBusStop = etaDistance["eta"] ?? 0.0; // Save ETA value
            distanceToNearestBusStop = etaDistance["distance"] ?? 0.0; // Save Distance value
          });
        } else {
          debugPrint('No closest bus stop found.');
          setState(() {
            closestBusStop = result;
            etaToNearestBusStop = 0.0; // Reset ETA if no bus stop is found
            distanceToNearestBusStop = 0.0; // Reset Distance
          });
        }
      } catch (e) {
        // Handle location fetch error
        debugPrint('Error fetching user location: $e');
      }
    });
  }

  //Request function os OSRM for routing to obtain ETA and Distance
  Future<Map<String, num>> calculateETADistance(LatLng from, LatLng to) async {
    try {
      final osrm = Osrm();
      final options = RouteRequest(
        coordinates: [
          (from.longitude, from.latitude),
          (to.longitude, to.latitude),
        ],
        continueStraight: OsrmContinueStraight.true_,
        profile: OsrmRequestProfile.bike,
        overview: OsrmOverview.full,
      );

      final route = await osrm.route(options);

      final duration = route.routes.first.duration!; // Duration in seconds
      final distance = route.routes.first.distance!; // Distance in meters

      return {
        "eta": duration,
        "distance": distance,
      };
    } catch (e) {
      debugPrint('Error calculating ETA or Distance: $e');
      return {
        "eta": -1,
        "distance": -1,
      }; // Return -1 for both in case of error
    }
  }


  /*
  //Function to get the nearest bus stop to user location and calculate the ETA
  void _startUpdatingNearestBusStop() {
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        LatLng userLocation = LatLng(position.latitude, position.longitude);

        ClosestBusStopResult result = await findClosestBusStop(userLocation);

        if (result.busStopLocation != null) {
          LatLng busLocation = busMovementService.currentPosition;
          LatLng closestStopCoordinates = result.busStopLocation!; // Safe null check

          num eta = await calculateETA(busLocation, closestStopCoordinates);

          setState(() {
            closestBusStop = result;
            etaToNearestBusStop = eta; // Save ETA value
          });
        } else {
          debugPrint('No closest bus stop found.');
          setState(() {
            closestBusStop = result;
            etaToNearestBusStop = 0.0; // Reset ETA if no bus stop is found
          });
        }
      } catch (e) {
        // Handle location fetch error
        debugPrint('Error fetching user location: $e');
      }
    });
  }

  Future<num> calculateETA(LatLng from, LatLng to) async {
    try {
      final osrm = Osrm();
      final options = RouteRequest(
        coordinates: [
          (from.longitude, from.latitude),
          (to.longitude, to.latitude),
        ],
        continueStraight: OsrmContinueStraight.true_,
        profile: OsrmRequestProfile.car,
        overview: OsrmOverview.full,
      );

      final route = await osrm.route(options);
      return route.routes.first.duration!; // Duration in seconds
    } catch (e) {
      debugPrint('Error calculating ETA: $e');
      return -1; // Return -1 if there's an error
    }
  }
  */

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
            ],
          ),
          panelBuilder: (controller) {
            return SingleChildScrollView(
              controller: controller,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Draggable handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 12.0),
                      height: 6,
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),

                  // Card under the draggable handle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: PanelInfo.buildPanelContent(
                          duration: etaToNearestBusStop,  // Directly passing the value
                          distance: distanceToNearestBusStop, // Directly passing the value
                          isBusSelected: _followBus, // Pass the boolean value here
                        ),
                      ),
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

  //Build main map
  Widget _buildMap() {
    return FlutterMap(
      mapController: animatedMapController.mapController,
      options: MapOptions(
        initialCenter: const LatLng(3.2525, 101.7345),
        initialZoom: 17.00,
        onTap: (_, __) {
          if (_followBus) {
            setState(() {
              _followBus = false; // Dismiss the popup immediately when tapping anywhere on the map
              _visible = false;
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

        StreamBuilder<LatLng>(
          stream: busMovementService.positionStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Container(); // Handle no data gracefully

            final newPosition = snapshot.data!;

            if (_followBus) {
              animatedMapController.centerOnPoint(
                newPosition,
                curve: Curves.easeInOut,
                duration: const Duration(seconds: 1), // Smooth animation
              );
            }
            
            return TweenAnimationBuilder<LatLng>(
              tween: LatLngTween(
                begin: busMovementService.currentPosition,
                end: newPosition,
              ),
              duration: const Duration(seconds: 3), // Adjust duration as needed
              builder: (context, position, child) {
                return PopupMarkerLayer(
                  options: PopupMarkerLayerOptions(
                    markers: [
                      Marker(
                        point: position,
                        width: 30,
                        height: 30,
                        child: Container(
                          decoration: ShapeDecoration(
                            color: _followBus
                                ? Colors.blue.shade100
                                : Colors.grey.shade100,
                            shape: CircleBorder(
                              eccentricity: 1.0,
                              side: BorderSide(
                                color: _followBus
                                    ? Colors.teal.shade400
                                    : Colors.teal.shade200,
                                width: 2,
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
                        //busStopsPopupController.showPopupsOnlyForSpecs([popupSpec]);
                        /*animatedMapController.centerOnPoint(
                          position,
                          curve: Curves.easeInOut,
                          duration: Duration(milliseconds: 800),
                        ); */
                        busStopsPopupController.hideAllPopups();
                        setState(() {
                          _followBus = true;
                          _visible = true;
                        });
                        _heightAnimationController.forward(); 
                      },
                    ),
                    popupDisplayOptions: PopupDisplayOptions(
                      builder: (BuildContext context, Marker marker) {
                        return const Align();
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),

        //Popup Marker Layer for Bus Stops
        PopupMarkerLayer(
          options: PopupMarkerLayerOptions(
            markers: busStops,
            popupController: busStopsPopupController,
            //markerTapBehavior: MarkerTapBehavior.togglePopupAndHideRest(),
            markerTapBehavior: MarkerTapBehavior.custom(
              (popupSpec, popupState, popupController) {
                setState(() {
                  _followBus = false;
                  _visible = false;
                });
                _heightAnimationController.reverse();
                if (popupState.selectedPopupSpecs.contains(popupSpec)) {
                  popupController.hideAllPopups();
                } else {
                  popupController.showPopupsOnlyForSpecs([popupSpec]);
                }
              }
            ),
            popupDisplayOptions: PopupDisplayOptions(
              builder: (BuildContext context, Marker marker) {
                final BusStop busStop = busStopsData.firstWhere(
                      (stop) => stop.latLng == marker.point,
                );

                // Use the getImagePath method to get the image path
                String imagePath = busStop.getImagePath();
                return StationPopup(
                  marker: marker,
                  stopName: busStop.name,
                  description: busStop.description,
                  imagePath: imagePath,
                );
              },
              snap: PopupSnap.markerTop,
              animation: const PopupAnimation.fade(
                duration: Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              ),
            ),
            selectedMarkerBuilder: (context, marker) => const Icon(
              Icons.location_on,
              size: 22,
              color: Colors.blue,
            ),
            markerCenterAnimation: const MarkerCenterAnimation(
              duration: Duration(milliseconds: 500),
            ),
          ),
        ),

        //"Tap anywhere to stop following bus" text (Tap-able)
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

        //Updates button code
        Positioned(
          top: 200,
          right: 16,
          child: CircleAvatar(
            radius: 30,
            backgroundColor: const Color.fromARGB(255, 20, 124, 27),
            child: IconButton(
              icon: Image.asset(
                'assets/updatesButtonBW.png',
                fit: BoxFit.cover,
                width: 40,
                height: 40,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UpdatesPage()),
                );
              },
            ),
          ),
        ),

        //Conditional "center map to user's current position" button, is only displayed if user allows location permission
        if (_hasLocationPermission)
          Stack(
            children: [
              Positioned(
                top: 300,
                right: 16,
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color.fromARGB(255, 20, 124, 27),
                  child: IconButton(
                    icon: const Icon(
                      Icons.my_location,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _followBus = false;
                        _visible = false;
                      });
                      _heightAnimationController.reverse();
                      _alignPositionStreamController.add(null);
                      animatedMapController.animatedRotateReset(
                        curve: Curves.easeInOut,
                        duration: const Duration(milliseconds: 500),
                      );
                    },
                  ),
                ),
              ),
              // Add the CurrentLocationLayer here if needed
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
                  accuracyCircleColor: Colors.blue.withOpacity(0.05),
                  headingSectorColor: Colors.blue.withOpacity(0.8),
                  headingSectorRadius: 120,
                ),
              ),
            ],
          ),
/*
        if (closestBusStop != null)
          Positioned(
            bottom: 300,
            left: 50,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nearest Bus Stop:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    closestBusStop?.busStop?.name ?? 'Unknown',
                  ),
                  Text(
                    'Distance: ${closestBusStop?.distance.toStringAsFixed(1) ?? '--'} m',
                  ),
                  if(etaToNearestBusStop > 60)
                    Text(
                      'ETA to nearest bus stop: ${(etaToNearestBusStop/60).round()} minutes',
                    ),
                  if(etaToNearestBusStop < 60)
                    Text(
                      'ETA to nearest bus stop: ${etaToNearestBusStop.round()} seconds',
                    ),
                  if(etaToNearestBusStop < 0)
                    const Text(
                      'Calculating ETA...',
                    ),
                ],
              ),
            ),
          ),
*/
        //Polyline for routing, currently set as transparent but can be modified if want to view routing
        PolylineLayer(
          polylines: [
            Polyline(
              points: points,
              strokeWidth: 4.0,
              color: Colors.transparent,
            ),
          ],
        ),
      ],
    );
  }

  //Create bus stop markers based on the latitude and longitude with the same template
  List<Marker> _createBusStopMarkers(List<BusStop> stops) {
    return stops.map((stop) {
      return Marker(
        key: ValueKey(stop.latLng),
        point: stop.latLng,
        width: 40,
        height: 40,
        child: const Icon(Icons.location_on, color: Colors.green),
      );
    }).toList();
  }
}