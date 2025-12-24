import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kam_wala_app/image%20crud%20hamdeling/worker_tracking_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import 'map_screen.dart'; // Aapka custom map screen jahan route dikhayenge

class WorkerNotificationPage extends StatefulWidget {
  final String requestId;

  const WorkerNotificationPage({super.key, required this.requestId});

  @override
  State<WorkerNotificationPage> createState() => _WorkerNotificationPageState();
}

class _WorkerNotificationPageState extends State<WorkerNotificationPage> {
  Position? workerPosition;
  String? selectedETA;

  @override
  void initState() {
    super.initState();
    _getWorkerLocation();
  }

  Future<void> _getWorkerLocation() async {
    try {
      workerPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {});
    } catch (e) {
      debugPrint("⚠ Could not get worker location: $e");
    }
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371; // km
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

  Future<void> _acceptRequest(Map<String, dynamic> data) async {
    if (selectedETA == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select ETA")));
      return;
    }

    final worker = FirebaseAuth.instance.currentUser!;
    final workerDoc =
        await FirebaseFirestore.instance
            .collection("workers")
            .doc(worker.uid)
            .get();

    await FirebaseFirestore.instance
        .collection("requests")
        .doc(widget.requestId)
        .update({
          "status": "accepted",
          "workerId": worker.uid,
          "workerName": workerDoc["name"],
          "workerPhone": workerDoc["phone"],
          "ETA": selectedETA,
        });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Request Accepted, ETA: $selectedETA")),
    );

    // 🔥 Navigate to map screen with route
    if (workerPosition != null &&
        data["userLat"] != null &&
        data["userLng"] != null) {
      print("going to mappp");
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder:
      //         (_) => 
      //     MapScreen(
      //       workerLat: workerPosition!.latitude,
      //       workerLng: workerPosition!.longitude,
      //       userLat: data["userLat"],
      //       userLng: data["userLng"],
      //     ),
      //   ),
      // );
    }
  }

  void _rejectRequest() async {
    await FirebaseFirestore.instance
        .collection("requests")
        .doc(widget.requestId)
        .update({"status": "rejected"});

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Request Rejected")));
  }

  void _callUser(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Cannot launch phone")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Service Request")),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection("requests")
                .doc(widget.requestId)
                .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());

          final data = snap.data!.data() as Map<String, dynamic>?;

          if (data == null)
            return const Center(child: Text("Request not found"));

          double distance = 0;
          if (workerPosition != null &&
              data["userLat"] != null &&
              data["userLng"] != null) {
            distance = _calculateDistance(
              data["userLat"],
              data["userLng"],
              workerPosition!.latitude,
              workerPosition!.longitude,
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data["serviceName"] ?? "Service",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text("Customer: ${data["userName"] ?? "User"}"),
                    Text("Distance: ${distance.toStringAsFixed(2)} KM"),
                    Text("Charges: Rs. ${data["charges"] ?? "-"}"),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _callUser(data["userPhone"] ?? ""),
                          icon: const Icon(Icons.call),
                          label: const Text("Call"),
                        ),
                        const SizedBox(width: 10),
                        DropdownButton<String>(
                          hint: const Text("Select ETA"),
                          value: selectedETA,
                          items:
                              ["10 mins", "20 mins", "30 mins", "45 mins"]
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedETA = val;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => _acceptRequest(data),
                          child: const Text("Accept"),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: _rejectRequest,
                          child: const Text("Reject"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
