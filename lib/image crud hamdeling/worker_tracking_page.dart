import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

class WorkerTrackingPage extends StatefulWidget {
  final String requestId;
  final String workerId;
  final String workerName;
  final String workerPhone;
  final String eta;
  final String serviceName;
  final String charges;

  const WorkerTrackingPage({
    super.key,
    required this.requestId,
    required this.workerId,
    required this.workerName,
    required this.workerPhone,
    required this.eta,
    required this.serviceName,
    required this.charges,
  });

  @override
  State<WorkerTrackingPage> createState() => _WorkerTrackingPageState();
}

class _WorkerTrackingPageState extends State<WorkerTrackingPage> {
  GoogleMapController? _mapController;

  LatLng _workerLocation = const LatLng(24.8607, 67.0011);
  LatLng _userLocation = const LatLng(24.9207, 67.0300);

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  Circle? _accuracyCircle;

  String _distance = "--";
  String _duration = "--";
  String _speed = "0";

  @override
  void initState() {
    super.initState();
    _listenWorkerLocation();
    _listenUserLocationFromRequest();
  }

  // ================= WORKER LOCATION =================
  void _listenWorkerLocation() {
    FirebaseFirestore.instance
        .collection("workersLocation")
        .doc(widget.workerId)
        .snapshots()
        .listen((doc) {
      if (!doc.exists || doc.data() == null) return;

      final d = doc.data()!;
      setState(() {
        _workerLocation = LatLng(
          (d["lat"] ?? 0).toDouble(),
          (d["lng"] ?? 0).toDouble(),
        );
        _speed = d["speed"]?.toString() ?? "0";
        _accuracyCircle = Circle(
          circleId: const CircleId("acc"),
          center: _workerLocation,
          radius: (d["accuracy"] ?? 30).toDouble(),
          fillColor: Colors.blue.withOpacity(.2),
          strokeWidth: 1,
          strokeColor: Colors.blue,
        );
        _updateMarkers();
        _drawRoute();
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLng(_workerLocation),
      );
    });
  }

  // ================= USER LOCATION =================
  void _listenUserLocationFromRequest() {
    FirebaseFirestore.instance
        .collection("requests")
        .doc(widget.requestId)
        .snapshots()
        .listen((doc) {
      if (!doc.exists || doc.data() == null) return;

      final loc = doc.data()!["location"];
      if (loc == null) return;

      setState(() {
        _userLocation = LatLng(
          (loc["lat"] ?? 0).toDouble(),
          (loc["lng"] ?? 0).toDouble(),
        );
        _updateMarkers();
        _drawRoute();
      });
    });
  }

  // ================= MAP HELPERS =================
  void _updateMarkers() {
    _markers.clear();
    _markers.addAll([
      Marker(
        markerId: const MarkerId("worker"),
        position: _workerLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(title: widget.workerName),
      ),
      Marker(
        markerId: const MarkerId("user"),
        position: _userLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: "You"),
      ),
    ]);
  }

  Future<void> _drawRoute() async {
    const apiKey = "YOUR_GOOGLE_MAPS_API_KEY";
    final url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${_workerLocation.latitude},${_workerLocation.longitude}&destination=${_userLocation.latitude},${_userLocation.longitude}&key=$apiKey";

    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) return;

    final data = jsonDecode(res.body);
    if (data["routes"].isEmpty) return;

    final poly = _decode(data["routes"][0]["overview_polyline"]["points"]);
    setState(() {
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId("route"),
          points: poly,
          width: 5,
          color: Colors.blue,
        ),
      );
      _distance = data["routes"][0]["legs"][0]["distance"]["text"];
      _duration = data["routes"][0]["legs"][0]["duration"]["text"];
    });
  }

  List<LatLng> _decode(String encoded) {
    List<LatLng> points = [];
    int i = 0, lat = 0, lng = 0;

    while (i < encoded.length) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(i++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : result >> 1;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(i++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : result >> 1;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  // ================= ACTIONS =================
  Future<void> _call() async =>
      launchUrl(Uri(scheme: 'tel', path: widget.workerPhone));

  Future<void> _whatsapp() async =>
      launchUrl(Uri.parse("https://wa.me/${widget.workerPhone}"),
          mode: LaunchMode.externalApplication);

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: _workerLocation, zoom: 14),
            onMapCreated: (c) => _mapController = c,
            markers: _markers,
            polylines: _polylines,
            circles: _accuracyCircle != null ? {_accuracyCircle!} : {},
            myLocationEnabled: true,
          ),

          // ===== Bottom Card =====
          DraggableScrollableSheet(
            initialChildSize: .30,
            minChildSize: .25,
            maxChildSize: .45,
            builder: (_, controller) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(22)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black.withOpacity(.15),
                  )
                ],
              ),
              child: ListView(
                controller: controller,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.blue.shade100,
                      child: Text(widget.workerName[0]),
                    ),
                    title: Text(widget.workerName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      "ETA: ${widget.eta}\nDistance: $_distance | Time: $_duration\nSpeed: $_speed km/h",
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.call, color: Colors.green),
                      onPressed: _call,
                    ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _whatsapp,
                        icon: const FaIcon(FontAwesomeIcons.whatsapp),
                        label: const Text("WhatsApp"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.check_circle),
                        label: const Text("Job Done"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
