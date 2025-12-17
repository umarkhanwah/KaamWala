// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:kam_wala_app/Service_Request/product_list.dart';
// import 'package:kam_wala_app/image crud hamdeling/imagedatafatech.dart';
// import 'package:kam_wala_app/user/3services_select_screen.dart';
// import 'package:shimmer/shimmer.dart';

// class SubCategoryLongScreen extends StatefulWidget {
//   const SubCategoryLongScreen({super.key});

//   @override
//   State<SubCategoryLongScreen> createState() => _SubCategoryLongScreenState();
// }

// class _SubCategoryLongScreenState extends State<SubCategoryLongScreen> {
//   final List<String> serviceImages = [
//     'assets/pic/WORKERS.jpg',
//     'assets/pic/technichian.jpg',
//     'assets/pic/male-plumber.jpg',
//   ];

//   int _currentIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       extendBody: true,
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFFE8F0FF), Color(0xFFF4F6F8)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(vertical: 20),
//             child: Column(
//               children: [
//                 _buildBanner(),
//                 const SizedBox(height: 40),
//                 _buildCarousel(),
//                 const SizedBox(height: 30),
//                 _buildHeading(),
//                 const SizedBox(height: 40),
//                 _buildServiceGrid(),
//                 const SizedBox(height: 50),
//                 _buildWhyChooseUs(),
//                 const SizedBox(height: 30),
//                 _buildCallToAction(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// TextEditingController _searchController = TextEditingController();

// Widget _buildBanner() {
//   return Stack(
//     clipBehavior: Clip.none,
//     children: [
//       ClipRRect(
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(40),
//           bottomRight: Radius.circular(40),
//         ),
//         child: Stack(
//           children: [
//             Image.asset(
//               "assets/pic/Services Banner.png",
//               height: 220,
//               width: double.infinity,
//               fit: BoxFit.cover,
//             ),
//             Container(
//               height: 220,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Colors.black.withOpacity(0.4), Colors.transparent],
//                   begin: Alignment.bottomCenter,
//                   end: Alignment.topCenter,
//                 ),
//               ),
//             ),
//             Positioned(
//               bottom: 20,
//               left: 20,
//               child: Text(
//                 "Our Services",
//                 style: GoogleFonts.poppins(
//                   color: Colors.white,
//                   fontSize: 26,
//                   fontWeight: FontWeight.bold,
//                   shadows: [
//                     Shadow(
//                       blurRadius: 8,
//                       color: Colors.black.withOpacity(0.6),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),

//       // 🔹 Floating Search Bar
//       Positioned(
//         bottom: -30,
//         left: 30,
//         right: 30,
//         child: Material(
//           elevation: 10,
//           borderRadius: BorderRadius.circular(30),
//           shadowColor: Colors.blue.withOpacity(0.3),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(30),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.9),
//               ),
//               child: TextField(
//                 controller: _searchController,
//                 onSubmitted: (query) async {
//                   if (query.isEmpty) return;

//                   // 🔹 Firestore query for category
//                   final categorySnap = await FirebaseFirestore.instance
//                       .collection('products')
//                       .where('category', isEqualTo: query)
//                       .get();

//                   if (categorySnap.docs.isNotEmpty) {
//                     // Navigator.push(
//                     //   context,
//                     //   MaterialPageRoute(
//                     //     builder: (_) => ProductListScreennew(
//                     //       category: query,
//                     //       currentUserId:
//                     //           FirebaseAuth.instance.currentUser?.uid ?? '',
//                     //     ),
//                     //   ),
//                     // );
//                   }

//                    else {
//                     // 🔹 Firestore query for service title
//                     final productSnap = await FirebaseFirestore.instance
//                         .collection('products')
//                         .where('name', isEqualTo: query)
//                         .get();

//                     // if (productSnap.docs.isNotEmpty) {
//                     //   String category =
//                     //       productSnap.docs.first['category'].toString();
//                     //   Navigator.push(
//                     //     context,
//                     //     MaterialPageRoute(
//                     //       builder: (_) => ProductPage(
//                     //         categoryName: category,
//                     //         currentUserId:
//                     //             FirebaseAuth.instance.currentUser?.uid ?? '',
//                     //       ),
//                     //     ),
//                     //   );
//                     // }

//                     if (productSnap.docs.isNotEmpty) {
//   final doc = productSnap.docs.first;

//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (_) => ProductPage(
//         categoryName: doc['category'].toString(),
//         docId: doc.id,
//         categoryId: doc['categoryId'].toString(),   // ⭐ IMPORTANT
//       ),
//     ),
//   );
// }

//                     else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                             content: Text("No matching service found")),
//                       );
//                     }
//                   }
//                 },
//                 decoration: InputDecoration(
//                   hintText: "Search services or categories...",
//                   hintStyle: GoogleFonts.poppins(
//                     color: Colors.grey.shade600,
//                     fontSize: 15,
//                   ),
//                   prefixIcon: const Icon(Icons.search, color: Colors.blue),
//                   border: InputBorder.none,
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 20,
//                     vertical: 14,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     ],
//   );
// }

//  // 🔹 Hero Banner with Floating Search Bar
// // Widget _buildBanner() {
// //   return Stack(
// //     clipBehavior: Clip.none,
// //     children: [
// //       ClipRRect(
// //         borderRadius: const BorderRadius.only(
// //           bottomLeft: Radius.circular(40),
// //           bottomRight: Radius.circular(40),
// //         ),
// //         child: Stack(
// //           children: [
// //             Image.asset(
// //               "assets/pic/Services Banner.png",
// //               height: 220,
// //               width: double.infinity,
// //               fit: BoxFit.cover,
// //             ),
// //             Container(
// //               height: 220,
// //               decoration: BoxDecoration(
// //                 gradient: LinearGradient(
// //                   colors: [Colors.black.withOpacity(0.4), Colors.transparent],
// //                   begin: Alignment.bottomCenter,
// //                   end: Alignment.topCenter,
// //                 ),
// //               ),
// //             ),
// //             Positioned(
// //               bottom: 20,
// //               left: 20,
// //               child: Text(
// //                 "Our Services",
// //                 style: GoogleFonts.poppins(
// //                   color: Colors.white,
// //                   fontSize: 26,
// //                   fontWeight: FontWeight.bold,
// //                   shadows: [
// //                     Shadow(
// //                       blurRadius: 8,
// //                       color: Colors.black.withOpacity(0.6),
// //                     )
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),

// //       // 🔹 Floating Glassmorphism Search Bar
// //       Positioned(
// //         bottom: -30,
// //         left: 30,
// //         right: 30,
// //         child: Material(
// //           elevation: 10,
// //           borderRadius: BorderRadius.circular(30),
// //           shadowColor: Colors.blue.withOpacity(0.3),
// //           child: ClipRRect(
// //             borderRadius: BorderRadius.circular(30),
// //             child: Container(
// //               decoration: BoxDecoration(
// //                 color: Colors.white.withOpacity(0.7),
// //                 border: Border.all(
// //                   color: Colors.white.withOpacity(0.4),
// //                   width: 1,
// //                 ),
// //               ),
// //               child: TextField(
// //                 style: GoogleFonts.poppins(
// //                   fontSize: 15,
// //                   color: Colors.blueGrey.shade900,
// //                   fontWeight: FontWeight.w500,
// //                 ),
// //                 decoration: InputDecoration(
// //                   hintText: "Search services...",
// //                   hintStyle: GoogleFonts.poppins(
// //                     color: Colors.grey.shade600,
// //                     fontSize: 15,
// //                   ),
// //                   prefixIcon: const Icon(Icons.search, color: Colors.blue),
// //                   border: InputBorder.none,
// //                   contentPadding: const EdgeInsets.symmetric(
// //                     horizontal: 20,
// //                     vertical: 14,
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     ],
// //   );
// // }

//   // 🔹 Carousel with Dots
//   Widget _buildCarousel() {
//     return Column(
//       children: [
//         CarouselSlider(
//           options: CarouselOptions(
//             height: 200,
//             autoPlay: true,
//             enlargeCenterPage: true,
//             viewportFraction: 0.85,
//             onPageChanged: (index, reason) {
//               setState(() => _currentIndex = index);
//             },
//           ),
//           items: serviceImages.map((imagePath) {
//             return ClipRRect(
//               borderRadius: BorderRadius.circular(20),
//               child: Image.asset(imagePath, fit: BoxFit.cover, width: 1000),
//             );
//           }).toList(),
//         ),
//         const SizedBox(height: 12),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: List.generate(serviceImages.length, (index) {
//             return Container(
//               margin: const EdgeInsets.symmetric(horizontal: 4),
//               width: _currentIndex == index ? 10 : 8,
//               height: _currentIndex == index ? 10 : 8,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: _currentIndex == index
//                     ? Colors.blue
//                     : Colors.blue.withOpacity(0.3),
//               ),
//             );
//           }),
//         ),
//       ],
//     );
//   }

//   // 🔹 Heading with shimmer
//   Widget _buildHeading() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Column(
//         children: [
//           Shimmer.fromColors(
//             baseColor: Colors.lightBlueAccent.shade100,
//             highlightColor: Colors.blueGrey.shade900,
//             child: Text(
//               "Explore Our Premium Services",
//               style: GoogleFonts.poppins(
//                 fontSize: 28,
//                 fontWeight: FontWeight.w800,
//                 letterSpacing: 1.2,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             "From plumbing and AC repair to deep cleaning — we bring trust, skill, and care to your doorstep.",
//             style: GoogleFonts.openSans(
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//               color: Colors.grey.shade800,
//               height: 1.6,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   // 🔹 Services Grid
//   Widget _buildServiceGrid() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: GridView.count(
//         crossAxisCount: 2,
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         mainAxisSpacing: 16,
//         crossAxisSpacing: 16,
//         childAspectRatio: 0.9,
//         children: [
//           _buildServiceCard("assets/pic/male-plumber.jpg", "Plumbing"),
//           _buildServiceCard("assets/pic/technichian.jpg", "Technicians"),
//           _buildServiceCard("assets/pic/WORKERS.jpg", "Workers"),
//           _buildServiceCard("assets/pic/user profile.jpg", "View All"),
//         ],
//       ),
//     );
//   }

//   Widget _buildServiceCard(String imagePath, String title) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => FetchAllCategories()),
//           // MaterialPageRoute(builder: (_) => Home3Screen()),
//         );
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(18),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.blue.withOpacity(0.15),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//           gradient: LinearGradient(
//             colors: [Colors.white, Colors.blue.shade50],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Expanded(
//               child: ClipRRect(
//                 borderRadius:
//                     const BorderRadius.vertical(top: Radius.circular(18)),
//                 child: Image.asset(imagePath,
//                     fit: BoxFit.cover, width: double.infinity),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Text(
//                 title,
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.blueGrey.shade900,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // 🔹 Why Choose Us
//   Widget _buildWhyChooseUs() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
//       child: Column(
//         children: [
//           Text(
//             "Why Choose Us?",
//             style: GoogleFonts.poppins(
//               fontSize: 26,
//               fontWeight: FontWeight.w800,
//               color: Colors.blue.shade700,
//             ),
//           ),
//           const SizedBox(height: 20),
//           _buildInfoPoint(Icons.verified, "Verified & Experienced Professionals", 0),
//           _buildInfoPoint(Icons.schedule, "Instant Booking & On-time Service", 200),
//           _buildInfoPoint(Icons.attach_money, "Transparent Pricing & Support", 400),
//           _buildInfoPoint(Icons.emoji_emotions, "Satisfaction Guaranteed", 600),
//           const SizedBox(height: 25),
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.blue.shade50, Colors.white],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.blue.withOpacity(0.08),
//                   blurRadius: 15,
//                   offset: const Offset(0, 6),
//                 ),
//               ],
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildStat("5000+", "Happy Customers"),
//                 _buildStat("4.9★", "Average Rating"),
//                 _buildStat("24/7", "Support"),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoPoint(IconData icon, String text, int delay) {
//     return TweenAnimationBuilder<double>(
//       tween: Tween(begin: 0, end: 1),
//       duration: Duration(milliseconds: 600 + delay),
//       builder: (context, value, child) {
//         return Opacity(
//           opacity: value,
//           child: Transform.translate(
//             offset: Offset(0, (1 - value) * 20),
//             child: child,
//           ),
//         );
//       },
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8),
//         child: Row(
//           children: [
//             CircleAvatar(
//               backgroundColor: Colors.blue.shade100,
//               child: Icon(icon, color: Colors.blue.shade700),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 text,
//                 style: GoogleFonts.openSans(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.grey.shade800,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStat(String value, String label) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: GoogleFonts.poppins(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.blue.shade800,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(label,
//             style: GoogleFonts.openSans(fontSize: 13, color: Colors.grey.shade600)),
//       ],
//     );
//   }

//   // 🔹 Call To Action
//   Widget _buildCallToAction() {
//     return Container(
//       margin: const EdgeInsets.only(top: 20, bottom: 20),
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.blue.shade600, Colors.blue.shade400],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(25),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.blue.withOpacity(0.3),
//             blurRadius: 15,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Text(
//             "Experience the Best Service Today!",
//             textAlign: TextAlign.center,
//             style: GoogleFonts.poppins(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             "Join thousands of happy customers who trust us every day.",
//             textAlign: TextAlign.center,
//             style: GoogleFonts.openSans(
//               fontSize: 14,
//               color: Colors.white.withOpacity(0.9),
//             ),
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton.icon(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.white.withOpacity(0.2),
//               padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(14),
//               ),
//               elevation: 0,
//             ),
//             onPressed: () {},
//             icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
//             label: Text(
//               "Get Started",
//               style: GoogleFonts.poppins(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kam_wala_app/image%20crud%20hamdeling/imagedatafatech.dart';
import 'package:kam_wala_app/user/bussinesformscreen.dart';

class SubCategoryLongScreen extends StatefulWidget {
  const SubCategoryLongScreen({super.key});

  @override
  State<SubCategoryLongScreen> createState() => _SubCategoryLongScreenState();
}

class _SubCategoryLongScreenState extends State<SubCategoryLongScreen> {
  int _currentIndex = 0;

  final List<String> banners = [
    'assets/pic/front.JPG',
    'assets/pic/front.JPG',
    'assets/pic/front.JPG',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3F6FB),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// 🔍 Search Bar
              /// 🔝 Logo (Top Left - Landscape Friendly)
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 58,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 8),
                    ],
                  ),
                  child: Image.asset(
                    'assets/pic/Logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// 🔍 Full Width Search Bar
              Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 12),
                    Text(
                      "Search services or categories...",
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// 🎞 Carousel
              CarouselSlider(
                options: CarouselOptions(
                  height: 180,
                  autoPlay: true,
                  viewportFraction: 1,
                  onPageChanged: (index, reason) {
                    setState(() => _currentIndex = index);
                  },
                ),
                items:
                    banners.map((img) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          img,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      );
                    }).toList(),
              ),

              const SizedBox(height: 10),

              /// ● Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  banners.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _currentIndex == index
                              ? Colors.blue
                              : Colors.blue.withOpacity(0.3),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// 🔹 Heading
              Text(
                "Explore Our Premium\nServices",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.lightBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "From plumbing and AC repair to deep cleaning — we bring trust, skill, and care to your doorstep.",
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 30),

              /// 🔹 SERVICES (2 UP + 1 DOWN)
              Row(
                children: [
                  Expanded(
                    child: Expanded(
                      child: _serviceCard(
                        title: "Handy Man Services",
                        color: Colors.blue,
                        icon: Icons.handyman,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FetchAllCategories(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Stack(
                      children: [
                        _serviceCard(
                          title: "Beautician",
                          color: Colors.pink,
                          icon: Icons.spa,
                          onTap: () {},
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                "COMING SOON",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Stack(
                children: [
                  _serviceCard(
                    title: "Business with KaamWala",
                    color: Colors.deepOrange,
                    icon: Icons.business_center,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BusinessFormScreen(),
                        ),
                      );
                    },
                  ),

                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Commercial",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              /// 🔹 WHY CHOOSE US
              _buildWhyChooseUs(),

              const SizedBox(height: 30),

              /// 🔹 CALL TO ACTION
              _buildCallToAction(),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 SERVICE CARD
  // Widget _serviceCard({
  //   required String title,
  //   required Color color,
  //   required IconData icon,
  // }) {
  //   return Container(
  //     height: 130,
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(20),
  //       gradient: LinearGradient(
  //         colors: [color.withOpacity(0.85), color.withOpacity(0.6)],
  //       ),
  //       boxShadow: [
  //         BoxShadow(color: color.withOpacity(0.3), blurRadius: 12),
  //       ],
  //     ),
  //     child: Row(
  //       children: [
  //         const SizedBox(width: 16),
  //         CircleAvatar(
  //           radius: 28,
  //           backgroundColor: Colors.white.withOpacity(0.25),
  //           child: Icon(icon, color: Colors.white, size: 28),
  //         ),
  //         const SizedBox(width: 16),
  //         Expanded(
  //           child: Text(
  //             title,
  //             style: GoogleFonts.poppins(
  //               fontSize: 18,
  //               fontWeight: FontWeight.w600,
  //               color: Colors.white,
  //             ),
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }
  Widget _serviceCard({
    required String title,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          height: 130,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.9), color.withOpacity(0.65)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white.withOpacity(0.25),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.white,
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 WHY CHOOSE US
  Widget _buildWhyChooseUs() {
    return Column(
      children: [
        Text(
          "Why Choose Us?",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 20),
        _info(Icons.verified, "Verified Professionals"),
        _info(Icons.schedule, "On-time Service"),
        _info(Icons.attach_money, "Transparent Pricing"),
        _info(Icons.emoji_emotions, "Satisfaction Guaranteed"),
      ],
    );
  }

  Widget _info(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Text(text, style: GoogleFonts.openSans(fontSize: 16)),
        ],
      ),
    );
  }

  /// 🔹 CALL TO ACTION
  Widget _buildCallToAction() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade400],
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Text(
            "Experience the Best Service Today!",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "Join thousands of happy customers who trust us every day.",
            style: GoogleFonts.openSans(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            onPressed: () {},
            child: const Text(
              "Get Started",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
