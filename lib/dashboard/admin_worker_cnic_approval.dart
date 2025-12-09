
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  String searchQuery = "";
  String? recentlyUpdatedId; // Track last updated worker

  Future<void> updateWorkerStatus(
    String docId,
    String status,
    String token,
  ) async {
    await FirebaseFirestore.instance.collection("workers").doc(docId).update({
      "status": status,
      "updatedAt": FieldValue.serverTimestamp(),
    });

    await sendPushNotification(token, status);

    setState(() {
      recentlyUpdatedId = docId;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          recentlyUpdatedId = null;
        });
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Worker $status successfully"),
        backgroundColor: status == "Approved" ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> sendPushNotification(String token, String status) async {
    try {
      debugPrint("Send push to: $token | Status: $status");
      // TODO: Add FCM push notification logic here
    } catch (e) {
      debugPrint("Push notification error: $e");
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Approved":
        return Colors.green;
      case "Rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text("Admin Panel - Worker Requests"),
        backgroundColor: Colors.blue[800],
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search worker by name, phone or CNIC",
                prefixIcon: const Icon(Icons.search, color: Colors.blue),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection("workers")
                      .orderBy("createdAt", descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs =
                    snapshot.data!.docs.where((doc) {
                      final name = (doc["name"] ?? "").toString().toLowerCase();
                      final phone =
                          (doc["phone"] ?? "").toString().toLowerCase();
                      final cnic = (doc["cnic"] ?? "").toString().toLowerCase();
                      return name.contains(searchQuery) ||
                          phone.contains(searchQuery) ||
                          cnic.contains(searchQuery);
                    }).toList();

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No worker requests found",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final name = data["name"] ?? "No Name";
                    final phone = data["phone"] ?? "No Phone";
                    final cnic = data["cnic"] ?? "No CNIC";
                    final status = data["status"] ?? "Pending";
                    final token = data["fcmToken"] ?? "";

                    final isUpdated = recentlyUpdatedId == doc.id;
                    final flashColor =
                        status == "Approved"
                            ? Colors.green.withOpacity(0.2)
                            : status == "Rejected"
                            ? Colors.red.withOpacity(0.2)
                            : Colors.transparent;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isUpdated ? flashColor : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              "Phone: $phone",
                              style: const TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "CNIC: $cnic",
                              style: const TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Status: $status",
                              style: TextStyle(
                                color: getStatusColor(status),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 28,
                              ),
                              onPressed:
                                  () => updateWorkerStatus(
                                    doc.id,
                                    "Approved",
                                    token,
                                  ),
                              tooltip: "Approve",
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.cancel,
                                color: Colors.red,
                                size: 28,
                              ),
                              onPressed:
                                  () => updateWorkerStatus(
                                    doc.id,
                                    "Rejected",
                                    token,
                                  ),
                              tooltip: "Reject",
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
