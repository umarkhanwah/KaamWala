// import 'package:flutter/material.dart';

// class Home3Screen extends StatelessWidget {
//   const Home3Screen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Log in"),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ✅ Address
//             const Text(
//               "Address",
//               style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 4),
//             const Text(
//               "F 2/63 Shah Faisal Avenue Rafah e Aam Society Shah\n"
//               "Faisal Town Karachi Sindh, Shah Faisal Town, Karachi",
//               style: TextStyle(fontSize: 13, color: Colors.black54),
//             ),
//             const SizedBox(height: 20),

//             // ✅ Welcome Heading
//             const Text(
//               "Welcome to KaamWala",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),

//             // ✅ First two services in Grid
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildServiceCard(
//                     context,
//                     title: "Home Services",
//                     img: "assets/pic/toolbox.png",
//                     tags: const ["RESIDENTIAL", "COMMERCIAL"],
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildServiceCard(
//                     context,
//                     title: "Cleaning Services",
//                     img: "assets/pic/cleaning.png",
//                     tags: const ["RESIDENTIAL", "COMMERCIAL"],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),

//             // ✅ Business With Mahir full-width card
//             _buildBusinessCard(
//               context,
//               title: "Business With Mahir",
//               img: "assets/pic/business.png",
//               tags: const ["COMMERCIAL"],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ✅ Normal Service Card
//   Widget _buildServiceCard(
//     BuildContext context, {
//     required String title,
//     required String img,
//     required List<String> tags,
//   }) {
//     return Container(
//       height: 150,
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 6,
//             offset: const Offset(2, 4),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.all(12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ✅ Title
//           Text(
//             title,
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
//           ),

//           const SizedBox(height: 6),

//           // ✅ Tags
//           Wrap(
//             spacing: 6,
//             children:
//                 tags
//                     .map(
//                       (t) => Chip(
//                         label: Text(
//                           t,
//                           style: const TextStyle(
//                             fontSize: 10,
//                             color: Colors.white,
//                           ),
//                         ),
//                         backgroundColor: Colors.blue.shade800,
//                         materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                         padding: EdgeInsets.zero,
//                       ),
//                     )
//                     .toList(),
//           ),

//           const Spacer(),

//           // ✅ Image
//           Align(
//             alignment: Alignment.center,
//             child: Image.asset(img, fit: BoxFit.contain, width: 60),
//           ),
//         ],
//       ),
//     );
//   }

//   // ✅ Business With Mahir (Full-width style like screenshot, responsive)
//   Widget _buildBusinessCard(
//     BuildContext context, {
//     required String title,
//     required String img,
//     required List<String> tags,
//   }) {
//     return Container(
//       height: 120,
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 6,
//             offset: const Offset(2, 4),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.all(12),
//       child: Row(
//         children: [
//           // ✅ Text + Tags (Left side)
//           Expanded(
//             flex: 2,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 15,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Wrap(
//                   spacing: 6,
//                   children:
//                       tags
//                           .map(
//                             (t) => Chip(
//                               label: Text(
//                                 t,
//                                 style: const TextStyle(
//                                   fontSize: 10,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                               backgroundColor: Colors.blue.shade800,
//                               materialTapTargetSize:
//                                   MaterialTapTargetSize.shrinkWrap,
//                               padding: EdgeInsets.zero,
//                             ),
//                           )
//                           .toList(),
//                 ),
//               ],
//             ),
//           ),

//           // ✅ Image (Right side, responsive)
//           Expanded(
//             flex: 1,
//             child: Align(
//               alignment: Alignment.centerRight,
//               child: Image.asset(img, fit: BoxFit.contain, height: 70),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:kam_wala_app/Auth/login_screen.dart';
import 'package:kam_wala_app/beauty%20salon/salon_user_ui.dart';
import 'package:kam_wala_app/image%20crud%20hamdeling/imagedatafatech.dart';
import 'package:kam_wala_app/user/bussinesformscreen.dart';

class Home3Screen extends StatelessWidget {
  const Home3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Full page coverage
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "All Services",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 49, 134),
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromARGB(255, 0, 49, 134),
          ),
          onPressed:
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen1()),
              ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 201, 218, 244),
              Color.fromARGB(255, 164, 214, 255),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),

              // ✅ Welcome Section
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeInOut,
                builder:
                    (context, value, child) => Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, (1 - value) * 20),
                        child: child,
                      ),
                    ),
                child: const Text(
                  "✨ Welcome to KaamWala ✨",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 49, 134),
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              const SizedBox(height: 35),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.9,
                children: [
                  _animatedCard(
                    delay: 300,
                    child: _buildServiceCard(
                      context,
                      title: "     Handy man ",
                      img: "assets/pic/22.png",
                      imgHeight: 140,
                      imgWidth: 120,
                      route: FetchAllCategories(), // ✅ replaced onPressed with route
                      // route: FatchAllimage(), // ✅ replaced onPressed with route
                    ),
                  ),
                  _animatedCard(
                    delay: 600,
                    child: _buildServiceCard(
                      context,
                      title: "Book Appointment",
                      img: "assets/pic/hair-dye-brush.png",
                      imgHeight: 140,
                      imgWidth: 120,
                      route:
                          WelcomeScreenuser(), // ✅ replaced onPressed with route
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              _animatedCard(
                delay: 1000,
                child: _buildBusinessCard(
                  context,
                  title: "Business With Kaamwala",
                  img: "assets/pic/thums up.webp",
                  tags: const ["COMMERCIAL"],
                  route:
                      BusinessFormScreen(), // ✅ use route instead of onPressed
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Fade + Slide Animation Wrapper
  Widget _animatedCard({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder:
          (context, value, _) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, (1 - value) * 30), // Slide up while fading
              child: child,
            ),
          ),
    );
  }

  // ✅ Service Card Widget with adjustable image size
  Widget _buildServiceCard(
    BuildContext context, {
    required String title,
    required String img,
    required double imgHeight,
    required double imgWidth,
    required Widget route,
  }) {
    return GestureDetector(
      onTap:
          () =>
              Navigator.push(context, MaterialPageRoute(builder: (_) => route)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.blue.shade900,
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Image.asset(
                img,
                fit: BoxFit.contain,
                width: imgWidth,
                height: imgHeight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Business Card Widget
  Widget _buildBusinessCard(
    BuildContext context, {
    required String title,
    required String img,
    required List<String> tags,
    required Widget route,
  }) {
    return GestureDetector(
      onTap:
          () =>
              Navigator.push(context, MaterialPageRoute(builder: (_) => route)),
      child: Container(
        height: 190,
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(3, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 26,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children:
                        tags
                            .map(
                              (t) => Chip(
                                label: Text(
                                  t,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: Colors.blue.shade600,
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            ),

            // Expanded(
            //   flex: 1,
            //   child: Align(
            //     alignment: Alignment.centerRight,
            //     child: Image.asset(img, fit: BoxFit.contain, height: 200),
            //   ),
            // ),
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerRight,
                child: Image.asset(
                  img,
                  fit: BoxFit.contain,
                  height:
                      MediaQuery.of(context).size.height *
                      0.25, // 25% of screen height
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
