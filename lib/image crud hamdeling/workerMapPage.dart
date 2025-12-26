import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkerMapPage extends StatefulWidget {
  final double workerLat;
  final double workerLng;
  final double userLat;
  final double userLng;
  final String userName;
  final String userPhone;
  final String requestId;

  const WorkerMapPage({
    super.key,
    required this.workerLat,
    required this.workerLng,
    required this.userLat,
    required this.userLng,
    required this.userName,
    required this.userPhone,
    required this.requestId,
  });

  @override
  State<WorkerMapPage> createState() => _WorkerMapPageState();
}

class _WorkerMapPageState extends State<WorkerMapPage> {
  GoogleMapController? mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  double distanceKm = 0;

  @override
  void initState() {
    super.initState();
    _setupMap();
    _drawRoute();
  }

  void _setupMap() {
    LatLng worker = LatLng(widget.workerLat, widget.workerLng);
    LatLng user = LatLng(widget.userLat, widget.userLng);

    _markers.add(
      Marker(
        markerId: const MarkerId("worker"),
        position: worker,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueBlue,
        ),
        infoWindow: const InfoWindow(title: "You"),
      ),
    );

    _markers.add(
      Marker(
        markerId: const MarkerId("user"),
        position: user,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed,
        ),
        infoWindow: InfoWindow(title: widget.userName),
      ),
    );

    distanceKm = _calculateDistance(
      widget.workerLat,
      widget.workerLng,
      widget.userLat,
      widget.userLng,
    );
  }

  Future<void> _drawRoute() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result =
        await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(widget.workerLat, widget.workerLng),
        destination: PointLatLng(widget.userLat, widget.userLng),
        mode: TravelMode.driving,
      ),
      googleApiKey: "YOUR_GOOGLE_MAPS_API_KEY",
    );

    if (result.points.isNotEmpty) {
      List<LatLng> routePoints = result.points
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();

      setState(() {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId("route"),
            color: Colors.blue,
            width: 5,
            points: routePoints,
          ),
        );
      });
    }
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371;
    double dLat = _deg2rad(lat2 - lat1);
    double dLon = _deg2rad(lon2 - lon1);
    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  void _callCustomer() async {
    final uri = Uri(scheme: 'tel', path: widget.userPhone);
    await launchUrl(uri);
  }

  void _openInGoogleMaps() async {
    final url =
        "https://www.google.com/maps/dir/?api=1&origin=${widget.workerLat},${widget.workerLng}&destination=${widget.userLat},${widget.userLng}&travelmode=driving";
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Future<void> _cancelRequest() async {
    await FirebaseFirestore.instance
        .collection("requests")
        .doc(widget.requestId)
        .update({"status": "cancelled"});

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.workerLat, widget.workerLng),
              zoom: 14,
            ),
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (c) => mapController = c,
            myLocationEnabled: true,
          ),

          // 🔥 Bottom Card (Bykea Style)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 10)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Distance: ${distanceKm.toStringAsFixed(2)} KM",
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _callCustomer,
                          icon: const Icon(Icons.call),
                          label: const Text("Call"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _openInGoogleMaps,
                          icon: const Icon(Icons.navigation),
                          label: const Text("Navigate"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: _cancelRequest,
                    child: const Text("Cancel Request"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
