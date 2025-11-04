// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';

// class LocationMapScreen extends StatefulWidget {
//   const LocationMapScreen({super.key});

//   @override
//   State<LocationMapScreen> createState() => _LocationMapScreenState();
// }

// class _LocationMapScreenState extends State<LocationMapScreen> {
//   final Completer<GoogleMapController> _controller = Completer();
//   LatLng? _currentLocation;
//   final Set<Marker> _markers = {};

//   @override
//   void initState() {
//     super.initState();
//     _determinePosition();
//   }

//   // 1. Check permissions and get current position
//   Future<void> _determinePosition() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     // Check if location services are enabled
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       // Location services are not enabled, handle this case
//       return Future.error('Location services are disabled.');
//     }

//     // Check location permission status
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return Future.error('Location permissions are denied.');
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       return Future.error(
//           'Location permissions are permanently denied, we cannot request permissions.');
//     }

//     // Get the current position
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);

//     setState(() {
//       _currentLocation = LatLng(position.latitude, position.longitude);
//       _setMarker(_currentLocation!);
//     });

//     // Move the map camera to the current location
//     _goToCurrentLocation();
//   }

//   // 2. Set the marker on the map
//   void _setMarker(LatLng location) {
//     _markers.clear();
//     _markers.add(
//       Marker(
//         markerId: const MarkerId('currentLocation'),
//         position: location,
//         infoWindow: const InfoWindow(title: 'My Current Location'),
//       ),
//     );
//   }

//   // 3. Animate the camera to the new location
//   Future<void> _goToCurrentLocation() async {
//     if (_currentLocation == null) return;

//     final GoogleMapController controller = await _controller.future;
//     controller.animateCamera(
//       CameraUpdate.newCameraPosition(
//         CameraPosition(
//           target: _currentLocation!,
//           zoom: 15, // Adjust zoom level as needed
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Current Location Map'),
//         backgroundColor: Colors.blueGrey,
//       ),
//       body: _currentLocation == null
//           ? const Center(child: CircularProgressIndicator())
//           : GoogleMap(
//               mapType: MapType.normal,
//               initialCameraPosition: CameraPosition(
//                 target: _currentLocation!,
//                 zoom: 15,
//               ),
//               onMapCreated: (GoogleMapController controller) {
//                 _controller.complete(controller);
//               },
//               markers: _markers, // Display the current location marker
//             ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _goToCurrentLocation,
//         child: const Icon(Icons.my_location),
//       ),
//     );
//   }
// }
