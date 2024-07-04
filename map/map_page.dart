import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'map_page_model.dart';
export 'map_page_model.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'package:geolocator/geolocator.dart'; // Import geolocator package
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/flutter_flow/flutter_flow_google_map.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:car_roz/revenue_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MapPageWidget extends StatefulWidget {
  const MapPageWidget({Key? key}) : super(key: key);

  @override
  State<MapPageWidget> createState() => _MapPageWidgetState();
}

class _MapPageWidgetState extends State<MapPageWidget> {
  late MapPageModel _model;

  // Define hotspots
  final List<LatLng> hotspots = [
    LatLng(33.6844, 73.0551), // G-9
    LatLng(33.6799, 73.0125), // G-11
    LatLng(33.6822, 73.0388), // F-10
    LatLng(33.6834, 73.0229), // G-10 Service Road
    // Add more hotspots as needed
  ];

  final scaffoldKey = GlobalKey<ScaffoldState>();
  LatLng? currentUserLocationValue;
  LatLng? previousLocation;
  double totalDistance = 0.0;
  int totalTravelTime = 0;
  double totalRevenue = 0.0;
  double totalBonus = 0.0;
  bool passedHotspot = false;
  DateTime? rideStartTime;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MapPageModel());

    getCurrentUserLocation(defaultLocation: LatLng(0.0, 0.0), cached: true)
        .then((loc) => setState(() {
              currentUserLocationValue = loc;
              previousLocation = loc;
            }));

    // Start location updates
    startLocationUpdates();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<double> calculateDistance(LatLng start, LatLng end) async {
    // Use Directions API to calculate distance
    // Make HTTP request to Directions API
    // Replace YOUR_API_KEY with your actual API key
    String apiKey = "AIzaSyC62CM06c2XbTIoMj_kLKDfSfW8ySWcMS4";
    String apiUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=$apiKey";

    // Send request and parse JSON response
    http.Response response = await http.get(Uri.parse(apiUrl));
    Map<String, dynamic> data = json.decode(response.body);
    if (data['status'] == 'OK') {
      return data['routes'][0]['legs'][0]['distance']['value'] / 1000.0;
    } else {
      print('Error calculating distance: ${data['error_message']}');
      return 0.0;
    }
  }

  void handleLocationUpdate(Position newLocation) async {
    if (isRideStarted && previousLocation != null) {
      // Ensure the location accuracy is within a reasonable range, for example, < 100 meters.
      // You can adjust this threshold based on the typical accuracy you observe in your app.
      if (newLocation.accuracy != null && newLocation.accuracy > 100) {
        // Skip processing this location update due to poor accuracy.
        return;
      }

      double distanceInMeters = Geolocator.distanceBetween(
        previousLocation!.latitude,
        previousLocation!.longitude,
        newLocation.latitude,
        newLocation.longitude,
      );

      // Calculate speed in km/h. Since distanceInMeters is in meters and elapsedTimeInHours is in hours,
      // the speed (distanceInMeters / 1000) / elapsedTimeInHours gives us km/h.
      final currentTime = DateTime.now();
      final elapsedTimeInHours =
          currentTime.difference(rideStartTime!).inSeconds / 3600.0;
      final speed = (distanceInMeters / 1000) / elapsedTimeInHours;

      // Adjust the speed threshold to a maximum expected speed, say 120 km/h, considering highway speeds.
      // This helps in filtering out unrealistic jumps due to GPS glitches.
      if (speed > 120) {
        // You might adjust this based on the maximum expected speed of your drivers.
        // Ignore this update as it suggests an unrealistic movement speed.
        return;
      }

      double distanceInKm = distanceInMeters / 1000.0;
      // Accumulate total distance only if the speed is within a realistic range.
      totalDistance += distanceInKm;

      // Update travel time based on the ride start time.
      final elapsedMinutes = currentTime.difference(rideStartTime!).inMinutes;
      totalTravelTime = elapsedMinutes;

      // Check if the new location is within 0.5km of any hotspot
      for (LatLng hotspot in hotspots) {
        double distanceToHotspot = Geolocator.distanceBetween(
          newLocation.latitude,
          newLocation.longitude,
          hotspot.latitude,
          hotspot.longitude,
        );
        if (distanceToHotspot <= 500) {
          // 0.5km radius check
          passedHotspot = true;
          break; // No need to check other hotspots if one is already found
        }
      }

      // Recalculate revenue with the updated distance and time.
      totalRevenue = calculateRevenue(totalDistance, totalTravelTime);
    }

    // Update the previous location with the new location for the next calculation.
    previousLocation = LatLng(newLocation.latitude, newLocation.longitude);
  }

  Future<LatLng> getCurrentUserLocation(
      {required LatLng defaultLocation, bool cached = true}) async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting user location: $e');
      return defaultLocation;
    }
  }

  void startLocationUpdates() {
    Geolocator.getPositionStream(
      distanceFilter: 10,
      desiredAccuracy: LocationAccuracy.high,
    ).listen((Position currentLocation) {
      setState(() {
        print("Location update: $currentLocation");
        handleLocationUpdate(currentLocation);
      });
    });
  }

  double calculateRevenue(double distance, int time) {
    double baseRatePerKm = 1; // Base rate per kilometer
    double timeRatePerMinute = 0.1; // Rate per minute of travel time
    double bonusAmount = 5.0; // Bonus amount for passing through hotspot

    double revenue = distance * baseRatePerKm + time * timeRatePerMinute;

    if (passedHotspot) {
      revenue += bonusAmount;
      totalBonus = bonusAmount;
      passedHotspot = false; // Reset after applying bonus
    }

    return revenue;
  }

  bool isRideStarted = false;

  @override
  Widget build(BuildContext context) {
    if (currentUserLocationValue == null) {
      return Container(
        color: FlutterFlowTheme.of(context).primaryBackground,
        child: Center(
          child: SizedBox(
            width: 50.0,
            height: 50.0,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                FlutterFlowTheme.of(context).primary,
              ),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: Color(0xFFF54E4E),
          automaticallyImplyLeading: false,
          title: Text(
            'Let\'s Go!',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontSize: 22.0,
                  fontWeight: FontWeight.w600,
                ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: FlutterFlowGoogleMap(
                  controller: _model.googleMapsController,
                  onCameraIdle: (latLng) => _model.googleMapsCenter = latLng,
                  initialLocation: _model.googleMapsCenter ??=
                      currentUserLocationValue!,
                  markerColor: GoogleMarkerColor.violet,
                  mapType: MapType.normal,
                  style: GoogleMapStyle.standard,
                  initialZoom: 14.0,
                  allowInteraction: true,
                  allowZoom: true,
                  showZoomControls: true,
                  showLocation: true,
                  showCompass: false,
                  showMapToolbar: false,
                  showTraffic: false,
                  centerMapOnMarkerTap: true,
                ),
              ),
              Container(
                color: Colors.transparent,
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors
                            .deepOrangeAccent, // Set the button color to orange
                        padding: EdgeInsets.symmetric(
                            horizontal: 92,
                            vertical: 14), // Increase button size
                      ),
                      onPressed: () {
                        if (isRideStarted) {
                          stopRide();

                          // Show total revenue
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Ride Summary'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                        'Total Distance: ${totalDistance.toStringAsFixed(2)} km'),
                                    Text(
                                        'Total Travel Time: $totalTravelTime min'),
                                    Text(
                                        'Total Bonus: \$${totalBonus.toStringAsFixed(2)}'),
                                    Text(
                                        'Total Revenue: \$${totalRevenue.toStringAsFixed(2)}'),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Close'),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          startRide();
                        }
                      },
                      child: Text(isRideStarted ? 'Stop Ride' : 'Start Ride',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void startRide() {
    setState(() {
      isRideStarted = true;
      totalDistance = 0.0;
      totalTravelTime = 0;
      totalRevenue = 0.0;
      totalBonus = 0.0;
      previousLocation = currentUserLocationValue;
      rideStartTime = DateTime.now(); // Track ride start time
    });
  }

  void stopRide() async {
    setState(() {
      isRideStarted = false;
    });

    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    double _revenue = 0.0;
    var walletDoc =
        await FirebaseFirestore.instance.collection('wallet').doc(userId).get();
    if (walletDoc.exists) {
      _revenue = (walletDoc.data()?['revenue'] ?? 0.0);
    }

    await FirebaseFirestore.instance.collection('wallet').doc(userId).set({
      'revenue': totalRevenue.toDouble() + _revenue,
    }, SetOptions(merge: true));
  }
}
