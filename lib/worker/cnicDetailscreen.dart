import 'package:flutter/material.dart';

class WorkercnicDetailPage extends StatelessWidget {
  final String workerId;
  final String name;
  final String cnic;
  final String phone;
  final String category;

  const WorkercnicDetailPage({
    super.key,
    required this.workerId,
    required this.name,
    required this.cnic,
    required this.phone,
    required this.category,
  });

  Widget _infoTile(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // AppBar style
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.blueAccent, Colors.lightBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Center(
                    child: Text(
                      "Worker Details",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Worker Info Cards
                _infoTile("Full Name", name, Icons.person_outline),
                _infoTile("Service Category", category, Icons.build_outlined),
                _infoTile("CNIC", cnic, Icons.credit_card),
                _infoTile("Phone", phone, Icons.phone_android),
                _infoTile("Worker ID", workerId, Icons.badge_outlined),

                const SizedBox(height: 30),

                // Action button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    label: const Text(
                      "Back",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
