import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkerRegistrationPage extends StatelessWidget {
  const WorkerRegistrationPage({super.key});

  Stream<DocumentSnapshot> _userStream() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance.collection("users").doc(uid).snapshots();
  }

  static const primaryColor = Color(0xFF1E3C72);
  static const accentColor = Color(0xFF4A90E2);
  static const bgColor = Color(0xFFF4F6FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: StreamBuilder<DocumentSnapshot>(
        stream: _userStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final status = (data["status"] ?? "Pending").toString();

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _heroHeader(),
                  const SizedBox(height: 20),

                  _verificationBanner(status),
                  const SizedBox(height: 16),

                  _hintCard(
                    "Stay reachable on your registered phone number to avoid missing job requests.",
                    Icons.phone_in_talk_outlined,
                  ),

                  _section("Overview"),
                  _overviewRow(),

                  _section("About KamWala"),
                  _infoCard(
                    "Grow Your Work",
                    "Verified workers get higher visibility and more trusted job matches. Keep your profile updated for better opportunities.",
                  ),

                  _section("Safety & Verification"),
                  _bulletCard(const [
                    "CNIC & phone number verification ensures platform trust.",
                    "Never share OTP or personal information.",
                    "Immediately report suspicious activity.",
                  ]),

                  _section("FAQs"),
                  _faq(),

                  const SizedBox(height: 26),
                  Center(
                    child: Text(
                      "📞 0800-12345   •   ✉️ support@kamwala.com",
                      style: const TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= HERO HEADER =================

  Widget _heroHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [primaryColor, Color(0xFF2A5298)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: const [
          Icon(Icons.dashboard_customize, color: Colors.white, size: 34),
          SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Worker Dashboard",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Verification & Account Overview",
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= STATUS BANNER =================

  Widget _verificationBanner(String status) {
    Color color;
    IconData icon;
    String text;

    if (status.toLowerCase() == "approved") {
      color = Colors.green;
      icon = Icons.verified;
      text = "Your account is verified. You can start receiving jobs.";
    } else if (status.toLowerCase() == "rejected") {
      color = Colors.redAccent;
      icon = Icons.block;
      text = "Verification rejected. Please contact support.";
    } else {
      color = Colors.orange;
      icon = Icons.hourglass_top;
      text = "Verification pending. Admin approval required.";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= COMPONENTS =================

  Widget _hintCard(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: accentColor),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 26, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
      ),
    );
  }

  Widget _overviewRow() {
    return Row(
      children: const [
        _OverviewBox("120", "Jobs Done", Icons.check_circle_outline),
        SizedBox(width: 10),
        _OverviewBox("42", "Requests", Icons.inbox_outlined),
        SizedBox(width: 10),
        _OverviewBox("4.8", "Rating", Icons.star_outline),
      ],
    );
  }

  Widget _infoCard(String title, String body) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(body),
          ],
        ),
      ),
    );
  }

  Widget _bulletCard(List<String> bullets) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children:
              bullets
                  .map(
                    (b) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.verified,
                            color: Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(b)),
                        ],
                      ),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  Widget _faq() {
    final items = [
      {
        "q": "How long does verification take?",
        "a": "Usually 24–48 hours after submitting correct details.",
      },
      {
        "q": "Can I work while pending?",
        "a": "You can explore the app but jobs unlock after approval.",
      },
      {
        "q": "Who can I contact for help?",
        "a": "Use the helpline or email support anytime.",
      },
    ];

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children:
            items
                .map(
                  (i) => ExpansionTile(
                    leading: const Icon(
                      Icons.help_outline,
                      color: primaryColor,
                    ),
                    title: Text(
                      i["q"]!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Text(i["a"]!),
                      ),
                    ],
                  ),
                )
                .toList(),
      ),
    );
  }
}

// ================= OVERVIEW CARD =================

class _OverviewBox extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _OverviewBox(this.value, this.label, this.icon);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: [
              Icon(icon, color: WorkerRegistrationPage.accentColor),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
