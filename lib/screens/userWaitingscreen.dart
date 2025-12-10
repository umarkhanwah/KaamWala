import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../image crud hamdeling/worker_tracking_page.dart';

class WaitingForWorkerScreen extends StatefulWidget {
  final String requestId;

  const WaitingForWorkerScreen({super.key, required this.requestId});

  @override
  State<WaitingForWorkerScreen> createState() => _WaitingForWorkerScreenState();
}

class _WaitingForWorkerScreenState extends State<WaitingForWorkerScreen> {
  @override
  void initState() {
    super.initState();
    _listenForAcceptance();
  }

  void _listenForAcceptance() {
    FirebaseFirestore.instance
        .collection("requests")
        .doc(widget.requestId)
        .snapshots()
        .listen((doc) {
      if (!doc.exists) return;

      final data = doc.data()!;
      final status = data["status"];

      if (status == "accepted") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => WorkerTrackingPage(
              workerId: data["acceptedWorkerId"],
              workerName: data["acceptedWorkerName"],
              workerPhone: data["acceptedWorkerPhone"],
              eta: data["eta"],
              serviceName: data["serviceName"],
              charges: data["charges"],
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              "Waiting for worker to respond...",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
