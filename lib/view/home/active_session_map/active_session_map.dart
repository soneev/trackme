import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_location_traker_app/view_model/tracking_viewmodel.dart';
import 'package:provider/provider.dart';

import 'dart:math';

class ActiveSessionMapScreen extends StatefulWidget {
  final String sessionId;
  const ActiveSessionMapScreen({super.key, required this.sessionId});

  @override
  State<ActiveSessionMapScreen> createState() => _ActiveSessionMapScreenState();
}

class _ActiveSessionMapScreenState extends State<ActiveSessionMapScreen> {
  GoogleMapController? _mapController;
  bool _isLoading = true;
  LatLng? _lastCameraTarget;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<TrackingProvider>(context, listen: false);
      // await provider.restoreActiveSession();

      provider
          .startAutoRefresh(widget.sessionId); // start live location refresh
    });

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  /// Animate camera smoothly toward latest location with rotation
  void _animateToLatest(LatLng target) {
    if (_mapController == null) return;

    // If this is the first point, just move without rotation
    if (_lastCameraTarget == null) {
      _lastCameraTarget = target;
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: target,
            zoom: 18,
            bearing: 0,
            tilt: 45,
          ),
        ),
      );
      return;
    }

    // Calculate bearing (angle) between previous and new points
    final bearing = _calculateBearing(_lastCameraTarget!, target);

    // Only move camera if distance is significant
    final distance = Geolocator.distanceBetween(
      _lastCameraTarget!.latitude,
      _lastCameraTarget!.longitude,
      target.latitude,
      target.longitude,
    );

    if (distance > 2) {
      _lastCameraTarget = target;
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: target,
            zoom: 18,
            bearing: bearing, //  Rotate map to match travel direction
            tilt: 45,
          ),
        ),
      );
    }
  }

  /// Helper: Compute bearing (angle) between two LatLng points
  double _calculateBearing(LatLng start, LatLng end) {
    final lat1 = start.latitude * (pi / 180.0);
    final lon1 = start.longitude * (pi / 180.0);
    final lat2 = end.latitude * (pi / 180.0);
    final lon2 = end.longitude * (pi / 180.0);

    final dLon = lon2 - lon1;
    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    final brng = atan2(y, x);

    return (brng * 180.0 / pi + 360.0) % 360.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<TrackingProvider>(
              builder: (context, trackingVM, _) {
                final path = trackingVM.currentPath;

                if (path.isEmpty) {
                  return const Center(
                    child: Column(
                      children: [
                        CupertinoActivityIndicator(
                          color: Colors.grey,
                          animating: true,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text('Waiting for live location updates...'),
                      ],
                    ),
                  );
                }

                final start = path.first;
                final current = path.last;

                // Smooth animation
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _animateToLatest(current);
                });

                // --- Polyline between all tracked points ---
                final polyline = Polyline(
                  polylineId: PolylineId("${widget.sessionId}_${path.length}"),
                  color: Colors.amber,
                  width: 6,
                  points: path,
                  jointType: JointType.round,
                  startCap: Cap.roundCap,
                  endCap: Cap.roundCap,
                  geodesic: true,
                );

                // --- Start Marker ---
                final startMarker = Marker(
                  markerId: const MarkerId('start_marker'),
                  position: start,
                  infoWindow: const InfoWindow(title: 'Start Point'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueAzure,
                  ),
                );

                // --- Current Marker ---
                final currentMarker = Marker(
                  markerId: const MarkerId('current_marker'),
                  position: current,
                  infoWindow: const InfoWindow(title: 'Current Location'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueCyan,
                  ),
                );

                return GoogleMap(
                  key: ValueKey(widget.sessionId),
                  initialCameraPosition: CameraPosition(
                    target: current,
                    zoom: 18,
                  ),
                  polylines: {polyline},
                  markers: {startMarker, currentMarker},
                  onMapCreated: (controller) => _mapController = controller,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: true,
                  tiltGesturesEnabled: true,
                  compassEnabled: true,
                  rotateGesturesEnabled: true,
                );
              },
            ),
    );
  }
}
