import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkerNotificationPage extends StatelessWidget {

final String? requestId;

  const WorkerNotificationPage({
    super.key,
    this.requestId,
  });



// void _acceptRequest(BuildContext context, String orderId) {
//   showModalBottomSheet(
//     context: context,
//     builder: (_) => Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Text("Select ETA",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 10),
//           Wrap(
//             spacing: 10,
//             children: ["15 mins", "30 mins", "1 hr"].map((eta) {
//               return ElevatedButton(
//                 child: Text(eta),
//                 onPressed: () async {
//                   await FirebaseFirestore.instance
//                       .collection("orders")
//                       .doc(orderId)
//                       .update({
//                     "status": "accepted",
//                     // "workerId": workerId,
//                     // "workerName": workerName,
//                     // "workerPhone": workerPhone,
//                     "ETA": eta,
//                   });

//                   Navigator.pop(context);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text("Accepted with ETA $eta")),
//                   );
//                 },
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     ),
//   );
// }
void _acceptRequest(BuildContext context, String orderId) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final workerDoc = await FirebaseFirestore.instance
      .collection("workers")
      .doc(user.uid)
      .get();

  final workerData = workerDoc.data()!;

  showModalBottomSheet(
    context: context,
    builder: (_) => Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Select ETA",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: ["15 mins", "30 mins", "1 hr"].map((eta) {
              return ElevatedButton(
                child: Text(eta),
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection("orders")
                      .doc(orderId)
                      .update({
                    "status": "accepted",
                    "workerId": user.uid,
                    "workerName": workerData["name"],
                    "workerPhone": workerData["phone"],
                    "ETA": eta,
                  });

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Accepted with ETA $eta")),
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Worker Notifications")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("orders")
            .where("status", isEqualTo: "pending")
            .snapshots(),
        builder: (ctx, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final orders = snap.data!.docs;
          if (orders.isEmpty) {
            return const Center(child: Text("No new requests"));
          }
          return ListView(
            children: orders.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(data["serviceName"]),
                  subtitle: Text("Charges: Rs. ${data["charges"]}"),
                  trailing: ElevatedButton(
                    child: const Text("Accept"),
                    // onPressed: () => _acceptRequest(context, doc.id, data),
                    onPressed: () => _acceptRequest(context, doc.id),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
