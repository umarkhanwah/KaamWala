import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminSummaryPage extends StatefulWidget {
  const AdminSummaryPage({super.key});

  @override
  State<AdminSummaryPage> createState() => _AdminSummaryPageState();
}

class _AdminSummaryPageState extends State<AdminSummaryPage> {
  String _selectedFilter = "All";
  String _searchQuery = "";

  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {});
  }

  Widget _buildSummaryCard(String title, int count, Color color, IconData icon) {
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

  Widget _buildPieChart(int total, int accepted, int rejected, int pending) {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(
              value: accepted.toDouble(),
              title: "Accepted",
              color: Colors.green,
              radius: 60,
              titleStyle:
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            PieChartSectionData(
              value: rejected.toDouble(),
              title: "Rejected",
              color: Colors.red,
              radius: 60,
              titleStyle:
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            PieChartSectionData(
              value: pending.toDouble(),
              title: "Pending",
              color: Colors.orange,
              radius: 60,
              titleStyle:
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
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
          "Admin Summary",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        centerTitle: true,
        elevation: 3,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('requests').snapshots(),
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
            final accepted = requests
                .where((doc) => (doc['status'] ?? '') == 'accepted')
                .length;
            final rejected = requests
                .where((doc) => (doc['status'] ?? '') == 'rejected')
                .length;
            final pending = requests
                .where((doc) => (doc['status'] ?? 'pending') == 'pending')
                .length;

            // 🔹 Filter + Search
            final filteredRequests = requests.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final status = (data['status'] ?? 'pending').toString();
              final serviceName = (data['serviceName'] ?? "").toString();
              final workerName = (data['workerName'] ?? "").toString();

              final matchesFilter = _selectedFilter == "All"
                  ? true
                  : status == _selectedFilter.toLowerCase();
              final matchesSearch = serviceName
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ||
                  workerName.toLowerCase().contains(_searchQuery.toLowerCase());

              return matchesFilter && matchesSearch;
            }).toList();

            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                // 🔹 Summary Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryCard(
                        "Total", total, Colors.blueAccent, Icons.list_alt),
                    _buildSummaryCard(
                        "Accepted", accepted, Colors.green, Icons.check_circle),
                    _buildSummaryCard(
                        "Rejected", rejected, Colors.red, Icons.cancel),
                  ],
                ),
                const SizedBox(height: 12),

                // 🔹 Pie Chart Overview
                _buildPieChart(total, accepted, rejected, pending),
                const SizedBox(height: 16),

                // 🔹 Search Bar
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: "Search by service or worker...",
                    prefixIcon: const Icon(Icons.search, color: Colors.blue),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 🔹 Filter Bar
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          fontWeight: FontWeight.bold, color: Colors.blue),
                      items: ["All", "Accepted", "Rejected", "Pending"]
                          .map((filter) =>
                              DropdownMenuItem(value: filter, child: Text(filter)))
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

                  // Format date
                  String formattedDate = "";
                  if (data['createdAt'] != null) {
                    final timestamp = (data['createdAt'] as Timestamp).toDate();
                    formattedDate =
                        DateFormat('EEEE, dd MMM yyyy – hh:mm a').format(timestamp);
                  }

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
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
                            fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      subtitle: Text(
                        "Worker: ${data['workerName'] ?? 'N/A'}\n"
                        "Charges: Rs. ${data['charges'] ?? 0}\n"
                        "Status: $status\n"
                        "Date: $formattedDate",
                        style: TextStyle(color: statusColor),
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
