import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Requests"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Pending"),
              Tab(text: "Accepted"),
              Tab(text: "Rejected"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRequestList("pending", user?.uid),
            _buildRequestList("accepted", user?.uid),
            _buildRequestList("rejected", user?.uid),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestList(String status, String? userId) {
    if (userId == null) {
      return const Center(child: Text("User not logged in"));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('requests')
          .where("userId", isEqualTo: userId) // filter current user ka data
          .where("status", isEqualTo: status) // filter by status
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No $status requests found"));
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: status == "accepted"
                      ? Colors.green
                      : status == "pending"
                          ? Colors.orange
                          : Colors.red,
                  child: const Icon(Icons.work, color: Colors.white),
                ),
                title: Text(data["serviceName"] ?? "Unknown Service"),
                subtitle: Text("Date: ${data["date"] ?? "N/A"}"),
                trailing: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: status == "accepted"
                        ? Colors.green
                        : status == "pending"
                            ? Colors.orange
                            : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
