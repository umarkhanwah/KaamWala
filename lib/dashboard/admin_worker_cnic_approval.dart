import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  String searchQuery = "";
Color statusColor(String status) {
  switch (status) {
    case "approved":
      return Colors.green;
    case "blocked":
      return Colors.red;
    default:
      return Colors.orange;
  }
}

IconData statusIcon(String status) {
  switch (status) {
    case "approved":
      return Icons.verified;
    case "blocked":
      return Icons.block;
    default:
      return Icons.hourglass_top;
  }
}
Future<void> updateWorkerStatus(
  String userId,
  String status,
) async {
  await FirebaseFirestore.instance
      .collection("users")
      .doc(userId)
      .update({
    "status": status,
    "updatedAt": FieldValue.serverTimestamp(),
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("Worker ${status.toUpperCase()}"),
      backgroundColor: status == "approved"
          ? Colors.green
          : Colors.red,
    ),
  );
}

  // 🔹 Get category name from categoryId
  Future<String> _getCategoryName(String? categoryId) async {
    if (categoryId == null || categoryId.isEmpty) return "No Category";

    final snap = await FirebaseFirestore.instance
        .collection("categories")
        .doc(categoryId)
        .get();

    return snap.exists ? snap['name'] ?? "Unknown" : "Unknown";
  }

  // 🔹 Worker Details Bottom Sheet
  void _showWorkerDetails(Map<String, dynamic> data, String categoryName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            children: [
              Center(
                child: Text(
                  data['name'] ?? "Worker",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(),

              _detailRow("Category", categoryName),
              _detailRow("Phone", data['phone']),
              _detailRow("CNIC", data['cnic']),
              _detailRow("Email", data['email']),
              _detailRow(
                "Created At",
                data['createdAt'] != null
                    ? (data['createdAt'] as Timestamp)
                        .toDate()
                        .toString()
                        .substring(0, 16)
                    : "N/A",
              ),

              const SizedBox(height: 16),

              ElevatedButton.icon(
                icon: const Icon(Icons.call),
                label: const Text("Call Worker"),
                onPressed: () async {
                  final phone = data['phone'];
                  if (phone != null) {
                    final uri = Uri.parse("tel:$phone");
                    await launchUrl(uri);
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 45),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(title, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            flex: 5,
            child: Text(value ?? "N/A"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text("Admin Panel - Workers"),
        backgroundColor: Colors.blue[800],
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔍 Search
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search worker",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .where("role", isEqualTo: "worker")
                  .orderBy("createdAt", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final d = doc.data() as Map<String, dynamic>;
                  return (d['name'] ?? "")
                          .toString()
                          .toLowerCase()
                          .contains(searchQuery) ||
                      (d['phone'] ?? "")
                          .toString()
                          .toLowerCase()
                          .contains(searchQuery) ||
                      (d['cnic'] ?? "")
                          .toString()
                          .toLowerCase()
                          .contains(searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return FutureBuilder<String>(
                      future: _getCategoryName(data['categoryId']),
                      builder: (context, snap) {
                        final categoryName = snap.data ?? "Loading...";

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: ListTile(
  title: Row(
    children: [
      Text(
        data['name'] ?? "No Name",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(width: 6),

      // 🔰 Verification Badge
      Icon(
        statusIcon(data['status'] ?? "pending"),
        color: statusColor(data['status'] ?? "pending"),
        size: 18,
      ),
    ],
  ),
  subtitle: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(categoryName),
      const SizedBox(height: 2),
      Text(
        (data['status'] ?? "pending").toUpperCase(),
        style: TextStyle(
          color: statusColor(data['status'] ?? "pending"),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    ],
  ),
  trailing: PopupMenuButton<String>(
    onSelected: (value) {
      updateWorkerStatus(doc.id, value);
    },
    itemBuilder: (_) => [
      const PopupMenuItem(
        value: "approved",
        child: Text("Approve"),
      ),
      const PopupMenuItem(
        value: "blocked",
        child: Text("Block"),
      ),
    ],
  ),
  onTap: () => _showWorkerDetails(data, categoryName),
),

                        );
                      },
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
