// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// class WorkerTrackingPage extends StatefulWidget {
//   final String workerId;
//   final String workerName;
//   final String workerPhone;
//   final String eta;
//   final String serviceName;
//   final String charges;

//   const WorkerTrackingPage({
//     super.key,
//     required this.workerId,
//     required this.workerName,
//     required this.workerPhone,
//     required this.eta,
//     required this.serviceName,
//     required this.charges,
//   });

//   @override
//   State<WorkerTrackingPage> createState() => _WorkerTrackingPageState();
// }

// class _WorkerTrackingPageState extends State<WorkerTrackingPage> {
//   GoogleMapController? _mapController;
//   LatLng _workerLocation = const LatLng(24.8607, 67.0011); // Karachi default
//   LatLng _userLocation = const LatLng(
//     24.9207,
//     67.0300,
//   ); // user dummy (fetch from Firestore)
//   final Set<Marker> _markers = {};

//   @override
//   void initState() {
//     super.initState();
//     _startTracking();
//   }

//   void _startTracking() {
//     // Worker ki location Firestore se real-time
//     FirebaseFirestore.instance
//         .collection("workersLocation")
//         .doc(widget.workerId)
//         .snapshots()
//         .listen((doc) {
//           if (doc.exists) {
//             final data = doc.data()!;
//             final lat = data["lat"] ?? 24.8607;
//             final lng = data["lng"] ?? 67.0011;
//             setState(() {
//               _workerLocation = LatLng(lat, lng);
//               _setMarkers();
//             });
//             _mapController?.animateCamera(
//               CameraUpdate.newLatLngZoom(_workerLocation, 14),
//             );
//           }
//         });

//     // User location (Firestore se fetch karo, dummy rakh diya abhi)
//     FirebaseFirestore.instance
//         .collection("usersLocation")
//         .doc("USER_ID") // 👈 isko actual userId se replace karo
//         .snapshots()
//         .listen((doc) {
//           if (doc.exists) {
//             final data = doc.data()!;
//             final lat = data["lat"] ?? 24.9207;
//             final lng = data["lng"] ?? 67.0300;
//             setState(() {
//               _userLocation = LatLng(lat, lng);
//               _setMarkers();
//             });
//           }
//         });
//   }

//   void _setMarkers() {
//     _markers.clear();
//     // Worker Marker
//     _markers.add(
//       Marker(
//         markerId: const MarkerId("worker"),
//         position: _workerLocation,
//         infoWindow: InfoWindow(title: widget.workerName),
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
//       ),
//     );
//     // User Marker
//     _markers.add(
//       Marker(
//         markerId: const MarkerId("user"),
//         position: _userLocation,
//         infoWindow: const InfoWindow(title: "You"),
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//       ),
//     );
//   }

//   Future<void> _launchCaller() async {
//     final Uri url = Uri(scheme: 'tel', path: widget.workerPhone);
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url);
//     }
//   }

//   Future<void> _launchSMS() async {
//     final Uri url = Uri(scheme: 'sms', path: widget.workerPhone);
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url);
//     }
//   }

//   Future<void> _launchWhatsApp() async {
//     final Uri url = Uri.parse("https://wa.me/${widget.workerPhone}");
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url, mode: LaunchMode.externalApplication);
//     }
//   }

//   void _markJobDone() async {
//     await FirebaseFirestore.instance.collection("orders").add({
//       "workerId": widget.workerId,
//       "workerName": widget.workerName,
//       "serviceName": widget.serviceName,
//       "charges": widget.charges,
//       "status": "completed",
//       "timestamp": FieldValue.serverTimestamp(),
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Text("Job marked as done ✅"),
//         backgroundColor: Colors.green.shade600,
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(12),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     );
//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xfff1f7fe),
//       appBar: AppBar(
//         elevation: 4,
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xff00c6ff), Color(0xff0072ff)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//         title: const Text(
//           "Worker Tracking",
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//             color: Colors.white,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           // Google Map
//           Expanded(
//             child: ClipRRect(
//               borderRadius: const BorderRadius.only(
//                 bottomLeft: Radius.circular(22),
//                 bottomRight: Radius.circular(22),
//               ),
//               child: GoogleMap(
//                 initialCameraPosition: CameraPosition(
//                   target: _workerLocation,
//                   zoom: 13,
//                 ),
//                 onMapCreated: (controller) => _mapController = controller,
//                 markers: _markers,
//                 myLocationEnabled: true,
//                 myLocationButtonEnabled: true,
//               ),
//             ),
//           ),

//           // Worker Details Card
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(18),
//             margin: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(18),
//               gradient: LinearGradient(
//                 colors: [Colors.white, Colors.blue.shade50],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.08),
//                   blurRadius: 8,
//                   spreadRadius: 2,
//                   offset: const Offset(0, 3),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     CircleAvatar(
//                       radius: 28,
//                       backgroundColor: Colors.blue.shade100,
//                       child: Text(
//                         widget.workerName[0].toUpperCase(),
//                         style: const TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 14),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           widget.workerName,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 17,
//                           ),
//                         ),
//                         Text("ETA: ${widget.eta}"),
//                         Text("Charges: Rs. ${widget.charges}"),
//                       ],
//                     ),
//                   ],
//                 ),
//                 const Divider(height: 25),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     ElevatedButton.icon(
//                       onPressed: _launchCaller,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color.fromARGB(
//                           255,
//                           133,
//                           146,
//                           244,
//                         ),
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 12,
//                           horizontal: 16,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       icon: const Icon(Icons.call),
//                       label: const Text("Call"),
//                     ),

//                     ElevatedButton.icon(
//                       onPressed: _launchWhatsApp,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color.fromARGB(
//                           255,
//                           139,
//                           239,
//                           88,
//                         ),
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 12,
//                           horizontal: 16,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       icon: const FaIcon(FontAwesomeIcons.whatsapp),
//                       label: const Text("WhatsApp"),
//                     ),
//                     ElevatedButton.icon(
//                       onPressed: _markJobDone,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color.fromARGB(
//                           255,
//                           252,
//                           237,
//                           102,
//                         ),
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 12,
//                           horizontal: 16,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       icon: const Icon(Icons.check_circle),
//                       label: const Text("Job Done"),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'dart:async';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';

// class WorkerTrackingPage extends StatefulWidget {
//   final String workerId;
//   String workerName; // 🔹 ab mutable banaya
//   final String workerPhone;
//   final String eta;
//   final String serviceName;
//   final String charges;

//   WorkerTrackingPage({
//     super.key,
//     required this.workerId,
//     required this.workerName,
//     required this.workerPhone,
//     required this.eta,
//     required this.serviceName,
//     required this.charges,
//   });

//   @override
//   State<WorkerTrackingPage> createState() => _WorkerTrackingPageState();
// }

// class _WorkerTrackingPageState extends State<WorkerTrackingPage> {
//   GoogleMapController? _mapController;
//   LatLng _workerLocation = const LatLng(24.8607, 67.0011); // Karachi default
//   LatLng _userLocation = const LatLng(24.9207, 67.0300); // dummy user
//   final Set<Marker> _markers = {};
//   final List<LatLng> _polylineCoords = [];
//   PolylinePoints polylinePoints = PolylinePoints();

//   @override
//   void initState() {
//     super.initState();
//     _getWorkerDetails();
//     _startTracking();
//   }

//   /// 🔹 Worker ka real naam Firestore se fetch
//   void _getWorkerDetails() {
//     FirebaseFirestore.instance
//         .collection("workers") // 👈 apni collection ka naam
//         .doc(widget.workerId)
//         .snapshots()
//         .listen((doc) {
//           if (doc.exists) {
//             final data = doc.data()!;
//             setState(() {
//               widget.workerName = data["name"] ?? widget.workerName;
//             });
//             _setMarkers();
//           }
//         });
//   }

//   /// 🔹 Worker + User ki location real-time track karo
//   void _startTracking() {
//     FirebaseFirestore.instance
//         .collection("workersLocation")
//         .doc(widget.workerId)
//         .snapshots()
//         .listen((doc) {
//           if (doc.exists) {
//             final data = doc.data()!;
//             final lat = data["lat"] ?? 24.8607;
//             final lng = data["lng"] ?? 67.0011;
//             setState(() {
//               _workerLocation = LatLng(lat, lng);
//               _setMarkers();
//               _setPolyline();
//             });
//             _mapController?.animateCamera(
//               CameraUpdate.newLatLngZoom(_workerLocation, 14),
//             );
//           }
//         });

//     FirebaseFirestore.instance
//         .collection("usersLocation")
//         .doc("USER_ID") // 👈 apni app ke user id ke hisaab se
//         .snapshots()
//         .listen((doc) {
//           if (doc.exists) {
//             final data = doc.data()!;
//             final lat = data["lat"] ?? 24.9207;
//             final lng = data["lng"] ?? 67.0300;
//             setState(() {
//               _userLocation = LatLng(lat, lng);
//               _setMarkers();
//               _setPolyline();
//             });
//           }
//         });
//   }

//   /// 🔹 Markers set karna
//   void _setMarkers() {
//     _markers.clear();

//     // Worker Marker
//     _markers.add(
//       Marker(
//         markerId: const MarkerId("worker"),
//         position: _workerLocation,
//         infoWindow: InfoWindow(title: widget.workerName),
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
//       ),
//     );

//     // User Marker
//     _markers.add(
//       Marker(
//         markerId: const MarkerId("user"),
//         position: _userLocation,
//         infoWindow: const InfoWindow(title: "You"),
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//       ),
//     );
//   }

//   /// 🔹 Worker aur User ke beech route line
//   Future<void> _setPolyline() async {
//     _polylineCoords.clear();

//     // PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//     //   "YOUR_GOOGLE_MAPS_API_KEY", // 👈 apni API key yahan
//     //   PointLatLng(_workerLocation.latitude, _workerLocation.longitude),
//     //   PointLatLng(_userLocation.latitude, _userLocation.longitude),
//     // );

//     // if (result.points.isNotEmpty) {
//     //   for (var point in result.points) {
//     //     _polylineCoords.add(LatLng(point.latitude, point.longitude));
//     //   }
//     //   setState(() {});
//     // }
//   }

//   Future<void> _launchCaller() async {
//     final Uri url = Uri(scheme: 'tel', path: widget.workerPhone);
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url);
//     }
//   }

//   Future<void> _launchWhatsApp() async {
//     final Uri url = Uri.parse("https://wa.me/${widget.workerPhone}");
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url, mode: LaunchMode.externalApplication);
//     }
//   }

//   void _markJobDone() async {
//     await FirebaseFirestore.instance.collection("orders").add({
//       "workerId": widget.workerId,
//       "workerName": widget.workerName,
//       "serviceName": widget.serviceName,
//       "charges": widget.charges,
//       "status": "completed",
//       "timestamp": FieldValue.serverTimestamp(),
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Text("Job marked as done ✅"),
//         backgroundColor: Colors.green.shade600,
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(12),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     );
//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xfff1f7fe),
//       appBar: AppBar(
//         elevation: 4,
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xff00c6ff), Color(0xff0072ff)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//         title: const Text(
//           "Worker Tracking",
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//             color: Colors.white,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           // Google Map
//           Expanded(
//             child: ClipRRect(
//               borderRadius: const BorderRadius.only(
//                 bottomLeft: Radius.circular(22),
//                 bottomRight: Radius.circular(22),
//               ),
//               child: GoogleMap(
//                 initialCameraPosition: CameraPosition(
//                   target: _workerLocation,
//                   zoom: 13,
//                 ),
//                 onMapCreated: (controller) => _mapController = controller,
//                 markers: _markers,
//                 myLocationEnabled: true,
//                 myLocationButtonEnabled: true,
//                 polylines: {
//                   Polyline(
//                     polylineId: const PolylineId("route"),
//                     points: _polylineCoords,
//                     color: Colors.blue,
//                     width: 5,
//                   ),
//                 },
//               ),
//             ),
//           ),

//           // Worker Details Card
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(18),
//             margin: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(18),
//               gradient: LinearGradient(
//                 colors: [Colors.white, Colors.blue.shade50],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.08),
//                   blurRadius: 8,
//                   spreadRadius: 2,
//                   offset: const Offset(0, 3),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     CircleAvatar(
//                       radius: 28,
//                       backgroundColor: Colors.blue.shade100,
//                       child: Text(
//                         widget.workerName.isNotEmpty
//                             ? widget.workerName[0].toUpperCase()
//                             : "?",
//                         style: const TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 14),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           widget.workerName,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 17,
//                           ),
//                         ),
//                         Text("ETA: ${widget.eta}"),
//                         Text("Charges: Rs. ${widget.charges}"),
//                       ],
//                     ),
//                   ],
//                 ),
//                 const Divider(height: 25),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     ElevatedButton.icon(
//                       onPressed: _launchCaller,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blueAccent,
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 12,
//                           horizontal: 16,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       icon: const Icon(Icons.call),
//                       label: const Text("Call"),
//                     ),
//                     ElevatedButton.icon(
//                       onPressed: _launchWhatsApp,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 12,
//                           horizontal: 16,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       icon: const FaIcon(FontAwesomeIcons.whatsapp),
//                       label: const Text("WhatsApp"),
//                     ),
//                     ElevatedButton.icon(
//                       onPressed: _markJobDone,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.amber,
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 12,
//                           horizontal: 16,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       icon: const Icon(Icons.check_circle),
//                       label: const Text("Job Done"),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

class WorkerTrackingPage extends StatefulWidget {
  final String workerId;
  final String workerName;
  final String workerPhone;
  final String eta;
  final String serviceName;
  final String charges;

  const WorkerTrackingPage({
    super.key,
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
  Circle? _workerAccuracyCircle;

  String _distance = "";
  String _duration = "";
  String _workerSpeed = "N/A";

  MapType _mapType = MapType.normal;
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  void _startTracking() {
    FirebaseFirestore.instance
        .collection("workersLocation")
        .doc(widget.workerId)
        .snapshots()
        .listen((doc) {
          if (doc.exists) {
            final data = doc.data()!;
            final lat = data["lat"] ?? 24.8607;
            final lng = data["lng"] ?? 67.0011;
            final speed = data["speed"]?.toString() ?? "N/A";
            final accuracy = (data["accuracy"] ?? 30).toDouble();

            setState(() {
              _workerLocation = LatLng(lat, lng);
              _workerSpeed = speed;
              _setMarkers();
              _setAccuracyCircle(accuracy);
              _getRoute();
            });

            _animateTo(_workerLocation);
          }
        });

    FirebaseFirestore.instance
        .collection("usersLocation")
        .doc("USER_ID") // replace with actual userId
        .snapshots()
        .listen((doc) {
          if (doc.exists) {
            final data = doc.data()!;
            final lat = data["lat"] ?? 24.9207;
            final lng = data["lng"] ?? 67.0300;
            setState(() {
              _userLocation = LatLng(lat, lng);
              _setMarkers();
              _getRoute();
            });
          }
        });
  }

  void _animateTo(LatLng target) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: 15)),
    );
  }

  void _setMarkers() {
    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId("worker"),
        position: _workerLocation,
        infoWindow: InfoWindow(title: widget.workerName),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );
    _markers.add(
      Marker(
        markerId: const MarkerId("user"),
        position: _userLocation,
        infoWindow: const InfoWindow(title: "You"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
  }

  void _setAccuracyCircle(double accuracy) {
    _workerAccuracyCircle = Circle(
      circleId: const CircleId("accuracy"),
      center: _workerLocation,
      radius: accuracy,
      strokeWidth: 1,
      strokeColor: Colors.blueAccent,
      fillColor: Colors.blueAccent.withOpacity(0.2),
    );
  }

  Future<void> _getRoute() async {
    const apiKey = "YOUR_GOOGLE_MAPS_API_KEY"; // Replace with your key
    final url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${_workerLocation.latitude},${_workerLocation.longitude}&destination=${_userLocation.latitude},${_userLocation.longitude}&key=$apiKey";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data["routes"].isNotEmpty) {
        final points = data["routes"][0]["overview_polyline"]["points"];
        final polylineCoords = _decodePolyline(points);

        setState(() {
          _polylines.clear();
          _polylines.add(
            Polyline(
              polylineId: const PolylineId("route"),
              points: polylineCoords,
              color: Colors.blue,
              width: 5,
            ),
          );
          _distance = data["routes"][0]["legs"][0]["distance"]["text"] ?? "N/A";
          _duration = data["routes"][0]["legs"][0]["duration"]["text"] ?? "N/A";
        });
      }
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return polyline;
  }

  Future<void> _launchCaller() async {
    final Uri url = Uri(scheme: 'tel', path: widget.workerPhone);
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  Future<void> _launchWhatsApp() async {
    final Uri url = Uri.parse("https://wa.me/${widget.workerPhone}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _markJobDone() async {
    final confirm = await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Confirm Job Completion"),
            content: const Text("Are you sure the job is done?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text("Yes, Done"),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection("orders").add({
        "workerId": widget.workerId,
        "workerName": widget.workerName,
        "serviceName": widget.serviceName,
        "charges": widget.charges,
        "status": "completed",
        "timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Job marked as done ✅"),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  void _toggleMapType() {
    setState(() {
      if (_mapType == MapType.normal) {
        _mapType = MapType.satellite;
      } else if (_mapType == MapType.satellite) {
        _mapType = MapType.terrain;
      } else {
        _mapType = MapType.normal;
      }
    });
  }

  void _toggleDarkMode() {
    setState(() {
      _darkMode = !_darkMode;
    });
    _mapController?.setMapStyle(_darkMode ? _darkMapStyle : null);
  }

  final String _darkMapStyle = '''
  [
    {"elementType": "geometry","stylers": [{"color": "#212121"}]},
    {"elementType": "labels.text.fill","stylers": [{"color": "#ffffff"}]}
  ]
  ''';

  void _sendSOS() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("🚨 SOS Sent to Admin!"),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff1f7fe),
      appBar: AppBar(
        elevation: 4,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff00c6ff), Color(0xff0072ff)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          "Worker Tracking",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _toggleMapType, icon: const Icon(Icons.layers)),
          IconButton(
            onPressed: _toggleDarkMode,
            icon: Icon(_darkMode ? Icons.dark_mode : Icons.light_mode),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _workerLocation,
              zoom: 13,
            ),
            onMapCreated: (controller) => _mapController = controller,
            markers: _markers,
            circles:
                _workerAccuracyCircle != null ? {_workerAccuracyCircle!} : {},
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: _mapType,
          ),

          // Bottom sliding card
          DraggableScrollableSheet(
            initialChildSize: 0.28,
            minChildSize: 0.2,
            maxChildSize: 0.45,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: ListView(
                  controller: scrollController,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          widget.workerName[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        widget.workerName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "ETA: ${widget.eta} | Charges: Rs. ${widget.charges}\n"
                        "Distance: $_distance | Time: $_duration\n"
                        "Speed: $_workerSpeed km/h",
                      ),
                      trailing: IconButton(
                        onPressed: _launchCaller,
                        icon: const Icon(Icons.call, color: Colors.green),
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _launchWhatsApp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          icon: const FaIcon(FontAwesomeIcons.whatsapp),
                          label: const Text("WhatsApp"),
                        ),
                        ElevatedButton.icon(
                          onPressed: _markJobDone,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          icon: const Icon(Icons.check_circle),
                          label: const Text("Job Done"),
                        ),
                        ElevatedButton.icon(
                          onPressed: _sendSOS,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              244,
                              105,
                              105,
                            ),
                          ),
                          icon: const Icon(Icons.warning_amber_rounded),
                          label: const Text("SOS"),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
