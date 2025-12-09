

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

class WorkerSummaryPage extends StatefulWidget {
  final String workerId;
  final String workerName;
  final String workerPhone;

  const WorkerSummaryPage({
    super.key,
    required this.workerId,
    required this.workerName,
    required this.workerPhone,
  });

  @override
  State<WorkerSummaryPage> createState() => _WorkerSummaryPageState();
}

class _WorkerSummaryPageState extends State<WorkerSummaryPage> {
  String _selectedFilter = "All";

  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {});
  }

  Widget _buildSummaryCard(
    String title,
    int count,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, color.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(height: 8),
              Text(
                count.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: color,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final whiteBlueGradient = const LinearGradient(
      colors: [Colors.white, Color.fromARGB(255, 137, 176, 244)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Worker Summary",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        centerTitle: true,
        elevation: 3,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('requests')
                  .where('nearbyWorkers', arrayContains: widget.workerId)
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView(
                children: [
                  const SizedBox(height: 20),
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        3,
                        (index) => Container(
                          height: 90,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  "No Requests Found",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey,
                  ),
                ),
              );
            }

            final requests = snapshot.data!.docs;
            final total = requests.length;
            final accepted =
                requests
                    .where((doc) => (doc['status'] ?? '') == 'accepted')
                    .length;
            final rejected =
                requests
                    .where((doc) => (doc['status'] ?? '') == 'rejected')
                    .length;

            // 🔹 Filter requests
            final filteredRequests =
                requests.where((doc) {
                  final status = (doc['status'] ?? 'pending').toString();
                  if (_selectedFilter == "All") return true;
                  return status == _selectedFilter.toLowerCase();
                }).toList();

            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                // 🔹 Summary Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryCard(
                      "Total",
                      total,
                      Colors.blueAccent,
                      Icons.list_alt,
                    ),
                    _buildSummaryCard(
                      "Accepted",
                      accepted,
                      Colors.green,
                      Icons.check_circle,
                    ),
                    _buildSummaryCard(
                      "Rejected",
                      rejected,
                      Colors.red,
                      Icons.cancel,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 🔹 Filter Bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: whiteBlueGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedFilter,
                      icon: const Icon(Icons.filter_list, color: Colors.blue),
                      dropdownColor: Colors.white,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                      items:
                          ["All", "Accepted", "Rejected", "Pending"]
                              .map(
                                (filter) => DropdownMenuItem(
                                  value: filter,
                                  child: Text(filter),
                                ),
                              )
                              .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedFilter = val);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 🔹 List of Requests
                ...filteredRequests.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status = data['status'] ?? "pending";

                  Color statusColor;
                  switch (status) {
                    case "accepted":
                      statusColor = Colors.green;
                      break;
                    case "rejected":
                      statusColor = Colors.red;
                      break;
                    default:
                      statusColor = Colors.orange;
                  }

                  // Format time, date, day
                  String formattedDate = "";
                  if (data['createdAt'] != null) {
                    final timestamp = (data['createdAt'] as Timestamp).toDate();
                    formattedDate =
                        DateFormat('EEEE, dd MMM yyyy – hh:mm a').format(timestamp);
                  }

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: whiteBlueGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: const Offset(2, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: statusColor,
                        child: const Icon(Icons.work, color: Colors.white),
                      ),
                      title: Text(
                        data['serviceName'] ?? "Unknown Service",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.pinkAccent,
                        ),
                      ),
                      subtitle: Text(
                        "Charges: Rs. ${data['charges'] ?? 0}\n"
                        "Status: $status\n",
                        //"Date: $formattedDate",
                        //style: TextStyle(color: statusColor),
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}
