import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'helper_service.dart'; // <- Import the helper

class WorkerRequestsPage extends StatefulWidget {
  final String workerId;
  final String workerName;
  final String workerPhone;

  const WorkerRequestsPage({
    super.key,
    required this.workerId,
    required this.workerName,
    required this.workerPhone,
  });

  @override
  State<WorkerRequestsPage> createState() => _WorkerRequestsPageState();
}

class _WorkerRequestsPageState extends State<WorkerRequestsPage> {
  Stream<QuerySnapshot> getRequestsStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.workerId)
        .collection('inboxRequests')
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  void _acceptRequest(String requestId) async {
    final etaController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Set ETA (in minutes)"),
          content: TextField(
            controller: etaController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Enter time to reach"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final eta = etaController.text.trim();
                if (eta.isEmpty) return;

                await WorkerService.acceptRequest(
                  requestId: requestId,
                  workerId: widget.workerId,
                  workerName: widget.workerName,
                  eta: eta,
                  workerPhone: widget.workerPhone,
                );

                // Remove from inbox
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.workerId)
                    .collection('inboxRequests')
                    .doc(requestId)
                    .delete();

                Navigator.pop(context);
              },
              child: const Text("Accept"),
            ),
          ],
        );
      },
    );
  }

  void _rejectRequest(String requestId) async {
    await FirebaseFirestore.instance
        .collection('requests')
        .doc(requestId)
        .update({"status": "rejected"});
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.workerId)
        .collection('inboxRequests')
        .doc(requestId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pending Requests")),
      body: StreamBuilder<QuerySnapshot>(
        stream: getRequestsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final requests = snapshot.data!.docs;
          if (requests.isEmpty) {
            return const Center(child: Text("No Pending Requests"));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final data = requests[index].data() as Map<String, dynamic>;
              final requestId = data['requestId'];

              return Card(
                child: ListTile(
                  title: Text(data['serviceName'] ?? "Service"),
                  subtitle: Text("User ID: ${data['userId']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _acceptRequest(requestId),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _rejectRequest(requestId),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
