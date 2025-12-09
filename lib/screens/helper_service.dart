import 'package:cloud_firestore/cloud_firestore.dart';

class WorkerService {
  // Worker accepts a request
  static Future<void> acceptRequest({
    required String requestId,
    required String workerId,
    required String workerName,
    required String eta,
    String? workerPhone,
  }) async {
    final requestRef = FirebaseFirestore.instance.collection("requests").doc(requestId);

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snapshot = await tx.get(requestRef);
      if (!snapshot.exists) throw Exception("Request not found");

      final data = snapshot.data() as Map<String, dynamic>;
      final status = data['status'] ?? 'pending';

      if (status == 'pending') {
        tx.update(requestRef, {
          "status": "accepted",
          "workerId": workerId,
          "workerName": workerName,
          "eta": eta,
          "workerPhone": workerPhone ?? FieldValue.delete(),
          "acceptedAt": FieldValue.serverTimestamp(),
        });
      } else {
        throw Exception("Request already taken");
      }
    });
  }
}
