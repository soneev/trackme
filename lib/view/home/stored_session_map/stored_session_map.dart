import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_location_traker_app/view_model/tracking_viewmodel.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class StoredSessionMapScreen extends StatefulWidget {
  final String sessionId;
  const StoredSessionMapScreen({super.key, required this.sessionId});

  @override
  State<StoredSessionMapScreen> createState() => _StoredSessionMapScreenState();
}

class _StoredSessionMapScreenState extends State<StoredSessionMapScreen> {
  GoogleMapController? _mapController;
  bool _isLoading = true;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _loadStoredLocations();
  }

  Future<void> _loadStoredLocations() async {
    final provider = Provider.of<TrackingProvider>(context, listen: false);
    await provider.loadSessionLocations(id: widget.sessionId);
    if (mounted) setState(() => _isLoading = false);
  }

  void _fitToPolylineBounds(List<LatLng> path) {
    if (_mapController == null || path.isEmpty) return;
    final bounds = _calculateBounds(path);
    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
  }

  LatLngBounds _calculateBounds(List<LatLng> path) {
    double minLat = path.first.latitude;
    double maxLat = path.first.latitude;
    double minLng = path.first.longitude;
    double maxLng = path.first.longitude;

    for (final p in path) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
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
                    child: Text('No stored location data found.'),
                  );
                }

                final start = path.first;
                final end = path.last;

                final polyline = Polyline(
                  polylineId: PolylineId(widget.sessionId),
                  color: Colors.deepPurple,
                  width: 5,
                  points: path,
                  jointType: JointType.round,
                  endCap: Cap.roundCap,
                  startCap: Cap.roundCap,
                  geodesic: true,
                );

                final startMarker = Marker(
                  markerId: const MarkerId('start_marker'),
                  position: start,
                  infoWindow: const InfoWindow(title: 'Start Point'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen),
                );

                final endMarker = Marker(
                  markerId: const MarkerId('end_marker'),
                  position: end,
                  infoWindow: const InfoWindow(title: 'End Point'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed),
                );

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_isMapReady) _fitToPolylineBounds(path);
                });

                return Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: start,
                        zoom: 14, // temporary zoom before bounds fit
                      ),
                      polylines: {polyline},
                      markers: {startMarker, endMarker},
                      onMapCreated: (controller) {
                        _mapController = controller;
                        _isMapReady = true;
                        _fitToPolylineBounds(path);
                      },
                      zoomControlsEnabled: false,
                      myLocationEnabled: false,
                      myLocationButtonEnabled: false,
                      tiltGesturesEnabled: true,
                      rotateGesturesEnabled: true,
                      scrollGesturesEnabled: true,
                      zoomGesturesEnabled: true,
                    ),

                    // Top route info overlay
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.route, color: Colors.deepPurple),
                                SizedBox(width: 8),
                                Text(
                                  "Stored Route Preview",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.pin_drop_outlined,
                                    color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  "Points: ${path.length}",
                                  style: const TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Floating recenter button
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: FloatingActionButton(
                        backgroundColor: Colors.deepPurple,
                        child: const Icon(Icons.center_focus_strong),
                        onPressed: () => _fitToPolylineBounds(path),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
