import 'package:flutter/material.dart';
import 'package:kam_wala_app/Auth/login_screen.dart';
import 'package:kam_wala_app/beauty%20salon/salon_user_ui.dart';
import 'package:kam_wala_app/image%20crud%20hamdeling/imagedatafatech.dart';
import 'package:kam_wala_app/user/bussinesformscreen.dart';

class Home3Screen extends StatelessWidget {
  const Home3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
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
              SizedBox(height: screenHeight * 0.06),

              // ✅ Welcome Section
              Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) => Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, (1 - value) * 20),
                      child: child,
                    ),
                  ),
                  child: const Text(
                    "✨ Welcome to KaamWala ✨",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 49, 134),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // ✅ Responsive Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 18,
                crossAxisSpacing: 18,
                childAspectRatio: 0.80, // cards thode lambe
                children: [
                  _animatedCard(
                    delay: 300,
                    child: _buildServiceCard(
                      context,
                      title: "Handy man",
                      img: "assets/pic/22.png",
                      route: FatchAllimage(),
                    ),
                  ),
                  _animatedCard(
                    delay: 600,
                    child: _buildServiceCard(
                      context,
                      title: "Book Appointment",
                      img: "assets/pic/hair-dye-brush.png",
                      route: WelcomeScreenuser(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 35),

              // ✅ Business Card
              _animatedCard(
                delay: 1000,
                child: _buildBusinessCard(
                  context,
                  title: "Business With Kaamwala",
                  img: "assets/pic/thums up.webp",
                  tags: const ["COMMERCIAL"],
                  route: BusinessFormScreen(),
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
      builder: (context, value, _) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 30),
          child: child,
        ),
      ),
    );
  }

  // ✅ Service Card (Bigger Images + Modern UI)
  Widget _buildServiceCard(
    BuildContext context, {
    required String title,
    required String img,
    required Widget route,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => route)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(2, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.blue.shade900,
              ),
            ),
            const Spacer(),
            Image.asset(
              img,
              fit: BoxFit.contain,
              height: screenHeight * 0.16, // ✅ bigger (16% of screen height)
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
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => route)),
      child: Container(
        height: screenHeight * 0.25, // ✅ thoda bara
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 14,
              offset: const Offset(3, 7),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Left text
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: tags
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

            // Right image
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerRight,
                child: Image.asset(
                  img,
                  fit: BoxFit.contain,
                  height: screenHeight * 0.18, // ✅ bigger image
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
