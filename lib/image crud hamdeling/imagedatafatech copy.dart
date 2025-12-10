
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:kam_wala_app/Service_Request/product_list.dart';
// import 'package:marquee/marquee.dart'; // 🎯 Auto-scroll tagline
// import 'package:kam_wala_app/image%20crud%20hamdeling/product_list_screen.dart';
// import 'package:kam_wala_app/image%20crud%20hamdeling/product_model.dart';

// class FatchAllimage extends StatefulWidget {
//   const FatchAllimage({super.key});

//   @override
//   State<FatchAllimage> createState() => _FatchAllimageState();
// }

// class _FatchAllimageState extends State<FatchAllimage> {
//   late Future<List<ProductModel>> productsFuture;
//   User? currentUser;

//   final List<String> taglines = [
//     "⚡ Quick & Reliable Services",
//     "🛠️ Professional Experts at your Doorstep",
//     "❄️ AC, Geyser & More Repairs",
//     "🎨  Cleaning & Maintenance",
//     "🚀 Hassle-free Booking Experience",
//   ];

//   @override
//   void initState() {
//     super.initState();
//     currentUser = FirebaseAuth.instance.currentUser; // ✅ get current user
//     productsFuture = fetchProducts();
//   }

//   Future<List<ProductModel>> fetchProducts() async {
//     final snapshot =
//         await FirebaseFirestore.instance.collection('products').get();
//     return snapshot.docs
//         .map((doc) => ProductModel.fromFirestore(doc.data(), doc.id))
//         .toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF9FAFC),
//       appBar: AppBar(
//         title: const Text("Services"),
//         elevation: 0,
//         backgroundColor: Colors.blueAccent,
//         foregroundColor: Colors.white,
//       ),
//       body: Column(
//         children: [
//           Container(
//             height: 85,
//             margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Colors.lightBlueAccent.withOpacity(0.2),
//                   Colors.cyanAccent.withOpacity(0.2),
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.blueGrey.withOpacity(0.2),
//                   blurRadius: 6,
//                   offset: const Offset(0, 3),
//                 ),
//               ],
//             ),
//             child: Marquee(
//               text: "🌟  ${taglines.join("     🚀     ")}  🌟",
//               style: GoogleFonts.poppins(
//                 color: Colors.blueGrey.shade900,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 letterSpacing: 1.2,
//               ),
//               velocity: 50,
//               blankSpace: 80,
//               startPadding: 20,
//               pauseAfterRound: const Duration(seconds: 2),
//             ),
//           ),

//           Expanded(
//             child: FutureBuilder<List<ProductModel>>(
//               future: productsFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (snapshot.hasError) {
//                   return const Center(child: Text("Error fetching data"));
//                 }
//                 if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return const Center(child: Text("No Products Found"));
//                 }

//                 final categories =
//                     snapshot.data!.map((e) => e.category).toSet().toList();

//                 return ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: categories.length,
//                   itemBuilder: (context, index) {
//                     final category = categories[index];
//                     return _buildImageCard(category, () {
//                       if (currentUser != null) {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder:
//                                 (_) => ProductListScreennew(
//                                   category: category,
//                                   currentUserId: currentUser!.uid,
//                                 ),
//                           ),
//                         );
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text("User not logged in")),
//                         );
//                       }
//                     });
//                   },
//                 );
//               },
//             ),
//           ),

//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.blueAccent, Colors.lightBlueAccent],
//                 begin: Alignment.centerLeft,
//                 end: Alignment.centerRight,
//               ),
//               borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black26,
//                   blurRadius: 10,
//                   offset: Offset(0, -3),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Text(
//                   "💡 Service Tips",
//                   style: GoogleFonts.poppins(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w800,
//                     color: Colors.white,
//                     letterSpacing: 1,
//                   ),
//                 ),
//                 const SizedBox(height: 14),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     _footerChip(
//                       "📅 10 years + Experience",
//                       Colors.purpleAccent,
//                       Colors.deepPurple,
//                     ),
//                     _footerChip(
//                       "⭐ 1000 + projects",
//                       Colors.lightGreen,
//                       Colors.greenAccent,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getCategoryEmoji(String category) {
//     switch (category.toLowerCase()) {
//       case "plumbing":
//         return "🛠️";
//       case "electrician":
//         return "⚡";
//       case "ac repair":
//         return "❄️";
//       case "geyser repair":
//         return "🔥";
//       case "cleaner":
//         return "🧹";
//       case "painter":
//         return "🎨";
//       default:
//         return "⚙️";
//     }
//   }

//   Widget _buildImageCard(String title, VoidCallback onTap) {
//     return StatefulBuilder(
//       builder: (context, setState) {
//         double scale = 1.0;

//         return GestureDetector(
//           onTapDown: (_) => setState(() => scale = 0.85),
//           onTapUp: (_) => setState(() => scale = 1.0),
//           onTapCancel: () => setState(() => scale = 1.0),
//           onTap: onTap,
//           child: AnimatedScale(
//             scale: scale,
//             duration: const Duration(milliseconds: 200),
//             curve: Curves.elasticOut,
//             child: Container(
//               margin: const EdgeInsets.only(bottom: 18),
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [Color(0xFFEDF5FF), Color(0xFFFFFFFF)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(22),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.blueAccent.withOpacity(0.2),
//                     blurRadius: 15,
//                     offset: const Offset(0, 8),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   Hero(
//                     tag: "emoji_$title",
//                     child: Container(
//                       height: 85,
//                       width: 70,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         gradient: const LinearGradient(
//                           colors: [Colors.blueAccent, Colors.lightBlueAccent],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.blue.withOpacity(0.4),
//                             blurRadius: 12,
//                             spreadRadius: 2,
//                           ),
//                         ],
//                       ),
//                       child: Center(
//                         child: Text(
//                           _getCategoryEmoji(title),
//                           style: const TextStyle(fontSize: 32),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 20),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           title,
//                           style: GoogleFonts.poppins(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w700,
//                             color: Colors.blueGrey.shade900,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           "Tap to explore services",
//                           style: GoogleFonts.poppins(
//                             fontSize: 13,
//                             color: Colors.grey.shade600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const Icon(
//                     Icons.arrow_forward_ios,
//                     size: 18,
//                     color: Colors.blueAccent,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _footerChip(String text, Color startColor, Color endColor) {
//     return GestureDetector(
//       onTap: () {
//         debugPrint("$text tapped!");
//       },
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [startColor, endColor],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(22),
//           boxShadow: [
//             BoxShadow(
//               color: endColor.withOpacity(0.4),
//               blurRadius: 6,
//               offset: const Offset(2, 3),
//             ),
//           ],
//         ),
//         child: Text(
//           text,
//           style: GoogleFonts.poppins(
//             color: Colors.white,
//             fontWeight: FontWeight.w400,
//             fontSize: 15,
//           ),
//         ),
//       ),
//     );
//   }
// }
