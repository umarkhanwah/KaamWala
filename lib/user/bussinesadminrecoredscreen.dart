import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AdminRecordedScreen extends StatefulWidget {
  const AdminRecordedScreen({super.key});

  @override
  State<AdminRecordedScreen> createState() => _AdminRecordedScreenState();
}

class _AdminRecordedScreenState extends State<AdminRecordedScreen> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("businesses");

  String searchQuery = "";
  String selectedCity = "All";
  String selectedType = "All";

  List<String> cities = ["All"];
  List<String> types = ["All"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FF),
      appBar: AppBar(
        title: const Text(
          "Business  Records",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 6,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1976D2), Color(0xFF64B5F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Column(
        children: [
          // 🔍 Search + Filters
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: "🔍 Search business or representative...",
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.blue.shade700,
                        size: 26,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (val) {
                      setState(() => searchQuery = val.toLowerCase());
                    },
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedCity,
                        decoration: InputDecoration(
                          labelText: "Filter by City",
                          labelStyle: TextStyle(color: Colors.blue.shade700),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items:
                            cities
                                .map(
                                  (city) => DropdownMenuItem(
                                    value: city,
                                    child: Text(
                                      city,
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) {
                          setState(() => selectedCity = val!);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedType,
                        decoration: InputDecoration(
                          labelText: "Filter by Type",
                          labelStyle: TextStyle(color: Colors.blue.shade700),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items:
                            types
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(
                                      type,
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) {
                          setState(() => selectedType = val!);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: dbRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("❌ Error loading data"));
                }
                if (!snapshot.hasData ||
                    snapshot.data == null ||
                    (snapshot.data! as DatabaseEvent).snapshot.value == null) {
                  return const Center(child: Text("No records found 📭"));
                }

                final data =
                    (snapshot.data! as DatabaseEvent).snapshot.value
                        as Map<dynamic, dynamic>;

                final businesses = data.values.toList();

                // 🏙 Collect filters dynamically
                final uniqueCities = <String>{"All"};
                final uniqueTypes = <String>{"All"};

                for (var item in businesses) {
                  if (item['city'] != null) uniqueCities.add(item['city']);
                  if (item['type'] != null) uniqueTypes.add(item['type']);
                }

                cities = uniqueCities.toList();
                types = uniqueTypes.toList();

                // 🔎 Filtering logic
                final filtered =
                    businesses.where((item) {
                      final name =
                          (item['businessName'] ?? "").toString().toLowerCase();
                      final rep =
                          (item['repName'] ?? "").toString().toLowerCase();
                      final city = item['city'] ?? "Unknown";
                      final type = item['type'] ?? "Unknown";

                      final matchesSearch =
                          name.contains(searchQuery) ||
                          rep.contains(searchQuery);
                      final matchesCity =
                          selectedCity == "All" || city == selectedCity;
                      final matchesType =
                          selectedType == "All" || type == selectedType;

                      return matchesSearch && matchesCity && matchesType;
                    }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index] as Map<dynamic, dynamic>;

                    return Card(
                      elevation: 6,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFFFFF), Color(0xFFE3F2FD)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(18),
                          leading: Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.business_center_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          title: Text(
                            item['businessName'] ?? "Unknown",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "🏢 Type: ${item['type'] ?? ''}",
                                  style: const TextStyle(color: Colors.black87),
                                ),
                                Text(
                                  "👤 Rep: ${item['repName'] ?? ''} (${item['repNumber'] ?? ''})",
                                  style: const TextStyle(color: Colors.black87),
                                ),
                                Text(
                                  "📍 City: ${item['city'] ?? ''}",
                                  style: const TextStyle(color: Colors.black87),
                                ),
                                Text(
                                  "✉️ Email: ${item['email'] ?? ''}",
                                  style: const TextStyle(color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_forever,
                              color: Colors.redAccent,
                              size: 28,
                            ),
                            onPressed:
                                () => _confirmDelete(context, item['id']),
                          ),
                          onTap: () => _showDetailsDialog(context, item),
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

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFDFEFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text(
                "Confirm Delete",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            "Are you sure you want to delete this business record? This action cannot be undone.",
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.delete_forever),
              label: const Text("Delete"),
              onPressed: () async {
                await dbRef.child(id).remove();
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("✅ Record deleted successfully"),
                    backgroundColor: Colors.redAccent.shade400,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showDetailsDialog(BuildContext context, Map<dynamic, dynamic> item) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFDFEFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Row(
            children: const [
              Icon(Icons.info_outline, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                "Business Details",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Business Name: ${item['businessName']}"),
              Text("Type: ${item['type']}"),
              Text("Representative: ${item['repName']}"),
              Text("Number: ${item['repNumber']}"),
              Text("Email: ${item['email']}"),
              Text("City: ${item['city']}"),
              Text("Message: ${item['message']}"),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue.shade700,
              ),
              child: const Text("Close"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
}
