import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kam_wala_app/image%20crud%20hamdeling/workerMapPage.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkerNotificationPage extends StatefulWidget {
  final String requestId;

  const WorkerNotificationPage({super.key, required this.requestId});

  @override
  State<WorkerNotificationPage> createState() => _WorkerNotificationPageState();
}

class _WorkerNotificationPageState extends State<WorkerNotificationPage> {
  Position? workerPosition;
  String? selectedETA;

  final List<String> etaList = ["10 mins", "20 mins", "30 mins", "45 mins"];

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
      debugPrint("Location error: $e");
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _deg2rad(double deg) => deg * (pi / 180);

Future<void> _acceptRequest(Map<String, dynamic> data) async {
  if (selectedETA == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please select ETA")),
    );
    return;
  }

  if (!data.containsKey("location") || data["location"] == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("User location missing in request")),
    );
    return;
  }

  // 1. Calculate 20% Commission
  final double serviceCharges = (data["charges"] as num).toDouble();
  final double commission = serviceCharges * 0.20;

  final String workerUid = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    // 2. Start Transaction for Wallet Check and Update
    await firestore.runTransaction((transaction) async {
      // Get Worker Document
      DocumentReference workerRef = firestore.collection("users").doc(workerUid);
      DocumentSnapshot workerSnap = await transaction.get(workerRef);

      if (!workerSnap.exists) throw "Worker account not found";

      double currentWallet = (workerSnap.get("walletAmount") ?? 0).toDouble();

      // 3. Balance Check
      if (currentWallet < commission) {
        throw "Insufficient balance. You need Rs ${commission.toStringAsFixed(0)} (20% commission) in your wallet to accept this request.";
      }

      // 4. Find Admin Document
      QuerySnapshot adminQuery = await firestore
          .collection("users")
          .where("role", isEqualTo: "admin")
          .limit(1)
          .get();

      if (adminQuery.docs.isEmpty) throw "Admin account not configured";
      DocumentReference adminRef = adminQuery.docs.first.reference;

      // 5. Perform Wallet Updates
      transaction.update(workerRef, {"walletAmount": currentWallet - commission});
      transaction.update(adminRef, {"walletAmount": FieldValue.increment(commission)});

      // 6. Update Request Status
      transaction.update(firestore.collection("requests").doc(widget.requestId), {
        "status": "accepted",
        "workerId": workerUid,
        "workerName": workerSnap.get("name"),
        "workerPhone": workerSnap.get("phone"),
        "eta": selectedETA,
        "commissionDeducted": commission,
      });
      
      // 7. Add History Record
      DocumentReference historyRef = firestore.collection("wallet_history").doc();
      transaction.set(historyRef, {
        "workerId": workerUid,
        "amount": commission,
        "type": "commission_deduction",
        "requestId": widget.requestId,
        "timestamp": FieldValue.serverTimestamp(),
      });
    });

    // 8. Navigation after successful transaction
    final location = Map<String, dynamic>.from(data["location"]);
    final double userLat = (location["lat"] as num).toDouble();
    final double userLng = (location["lng"] as num).toDouble();

    final userDoc = await firestore.collection("users").doc(data["userId"]).get();
    final userData = userDoc.data()!;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkerMapPage(
          workerLat: workerPosition!.latitude,
          workerLng: workerPosition!.longitude,
          userLat: userLat,
          userLng: userLng,
          userName: userData["name"] ?? "Customer",
          userPhone: userData["phone"] ?? "",
          requestId: widget.requestId,
        ),
      ),
    );

  } catch (e) {
    _showError(e.toString());
  }
}

// Utility function for error snackbar
void _showError(String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 4),
    ),
  );
}
// Future<void> _acceptRequest(Map<String, dynamic> data) async {
//   if (selectedETA == null) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Please select ETA")),
//     );
//     return;
//   }

//   // 🔥 SAFE location fetch
//   if (!data.containsKey("location") || data["location"] == null) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("User location missing in request")),
//     );
//     return;
//   }

//   final location = Map<String, dynamic>.from(data["location"]);

//   final double userLat = (location["lat"] as num).toDouble();
//   final double userLng = (location["lng"] as num).toDouble();

//   final worker = FirebaseAuth.instance.currentUser!;
//   final workerDoc = await FirebaseFirestore.instance
//       .collection("workers")
//       .doc(worker.uid)
//       .get();

//   await FirebaseFirestore.instance
//       .collection("requests")
//       .doc(widget.requestId)
//       .update({
//     "status": "accepted",
//     "workerId": worker.uid,
//     "workerName": workerDoc["name"],
//     "workerPhone": workerDoc["phone"],
//     "eta": selectedETA,
//   });

//   final userDoc = await FirebaseFirestore.instance
//       .collection("users")
//       .doc(data["userId"])
//       .get();

//   final userData = userDoc.data()!;

//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (_) => WorkerMapPage(
//         workerLat: workerPosition!.latitude,
//         workerLng: workerPosition!.longitude,
//         userLat: userLat,
//         userLng: userLng,
//         userName: userData["name"] ?? "Customer",
//         userPhone: userData["phone"] ?? "",
//         requestId: widget.requestId,
//       ),
//     ),
//   );
// }

  void _rejectRequest() async {
    await FirebaseFirestore.instance
        .collection("requests")
        .doc(widget.requestId)
        .update({"status": "rejected"});

    Navigator.pop(context);
  }

  void _callUser(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("New Service Request"),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("requests")
            .doc(widget.requestId)
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snap.data!.data() as Map<String, dynamic>?;

          if (data == null) {
            return const Center(child: Text("Request not found"));
          }

          double distance = 0;

Map<String, dynamic>? loc;

if (workerPosition != null &&
    data.containsKey("location") &&
    data["location"] != null) {

  loc = Map<String, dynamic>.from(data["location"]);

  distance = _calculateDistance(
    workerPosition!.latitude,
    workerPosition!.longitude,
    (loc["lat"] as num).toDouble(),
    (loc["lng"] as num).toDouble(),
  );
}


          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// 🔹 MAIN CARD
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Service Name + Distance
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              data["serviceName"] ?? "Service",
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "${distance.toStringAsFixed(1)} km",
                                style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),

                        const SizedBox(height: 12),

                        /// Customer
                        ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(data["userName"] ?? "Customer"),
                          subtitle: const Text("Customer Name"),
                          trailing: IconButton(
                            icon: const Icon(Icons.call, color: Colors.green),
                            onPressed: () =>
                                _callUser(data["userPhone"] ?? ""),
                          ),
                        ),

                        const Divider(),

                        /// Charges
                        Row(
                          children: [
                            const Icon(Icons.attach_money),
                            const SizedBox(width: 8),
                            Text(
                              "Charges: Rs ${data["charges"] ?? "-"}",
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        /// ETA Dropdown
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: "Estimated Arrival Time",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          value: selectedETA,
                          items: etaList
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedETA = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                /// 🔹 ACTION BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _rejectRequest,
                        child: const Text("Reject"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _acceptRequest(data),
                        child: const Text("Accept"),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
