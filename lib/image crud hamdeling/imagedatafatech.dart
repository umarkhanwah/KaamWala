import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kam_wala_app/Service_Request/product_list.dart';
import 'package:kam_wala_app/image%20crud%20hamdeling/product_list_screen.dart';
import 'package:kam_wala_app/image%20crud%20hamdeling/product_model.dart';
import 'package:marquee/marquee.dart';

class FatchAllimage extends StatefulWidget {
  const FatchAllimage({super.key});

  @override
  State<FatchAllimage> createState() => _FatchAllimageState();
}

class _FatchAllimageState extends State<FatchAllimage> {
  late Future<List<ProductModel>> productsFuture;
  User? currentUser;

  String searchQuery = "";

  final List<String> taglines = [
    "⚡ Quick & Reliable Services",
    "🛠️ Professional Experts at your Doorstep",
    "❄️ AC, Geyser & More Repairs",
    "🎨 Cleaning & Maintenance",
    "🚀 Hassle-free Booking Experience",
  ];

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    productsFuture = fetchProducts();
  }

  Future<List<ProductModel>> fetchProducts() async {
    final snapshot = await FirebaseFirestore.instance.collection('products').get();
    return snapshot.docs
        .map((doc) => ProductModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // ✅ Header with Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blueAccent, Colors.lightBlueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.miscellaneous_services,
                          color: Colors.white, size: 26),
                      const SizedBox(width: 8),
                      Text(
                        "All Services",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "🔍 Search services...",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ✅ Tagline Marquee
            Container(
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.lightBlueAccent.withOpacity(0.15),
                    Colors.cyanAccent.withOpacity(0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Marquee(
                text: "🌟  ${taglines.join("     🚀     ")}  🌟",
                style: GoogleFonts.poppins(
                  color: Colors.blueGrey.shade900,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
                velocity: 40,
                blankSpace: 80,
                pauseAfterRound: const Duration(seconds: 2),
              ),
            ),

            // ✅ Categories List
            Expanded(
              child: FutureBuilder<List<ProductModel>>(
                future: productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error fetching data"));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No Products Found"));
                  }

                  final categories =
                      snapshot.data!.map((e) => e.category).toSet().toList();

                  // ✅ Search filter
                  final filteredCategories = categories
                      .where((c) => c.toLowerCase().contains(searchQuery))
                      .toList();

                  if (filteredCategories.isEmpty) {
                    return const Center(child: Text("No matching services found"));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = filteredCategories[index];
                      return _buildImageCard(category, () {
                        if (currentUser != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductListScreennew(
                                category: category,
                                currentUserId: currentUser!.uid,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("User not logged in")),
                          );
                        }
                      });
                    },
                  );
                },
              ),
            ),

            // ✅ Footer Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.lightBlueAccent],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Text(
                    "💡 Service Tips",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    spacing: 10,
                    children: [
                      _footerChip("📅 10 years + Experience", Colors.purpleAccent, Colors.deepPurple),
                      _footerChip("⭐ 1000 + projects", Colors.lightGreen, Colors.greenAccent),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryEmoji(String category) {
    switch (category.toLowerCase()) {
      case "plumbing":
        return "🛠️";
      case "electrician":
        return "⚡";
      case "ac repair":
        return "❄️";
      case "geyser repair":
        return "🔥";
      case "cleaner":
        return "🧹";
      case "painter":
        return "🎨";
      default:
        return "⚙️";
    }
  }

  Widget _buildImageCard(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEDF5FF), Color(0xFFFFFFFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Colors.blueAccent, Colors.lightBlueAccent],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _getCategoryEmoji(title),
                  style: const TextStyle(fontSize: 30),
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey.shade900,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.blueAccent),
          ],
        ),
      ),
    );
  }

  Widget _footerChip(String text, Color startColor, Color endColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }
}
