import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kam_wala_app/screens/wellcomescreen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _controller = PageController();
  int currentIndex = 0;

  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonPulseAnimation;

  static const Color primaryBlue = Color.fromARGB(255, 182, 221, 247);
  static const Color darkBg = Color.fromARGB(255, 167, 190, 233);

  final List<Map<String, String>> onboardingData = [
    {
      "title": "Book Experts Anytime",
      "description":
          "From electricians to makeup artists, it's all at your fingertips.",
      "image": "assets/pic/thums up.webp",
    },
    {
      "title": "Verified & Trained Staff",
      "description":
          "We send only pre-verified professionals for peace of mind.",
      "image": "assets/pic/staff.jpg",
    },
    {
      "title": "Live Technician Tracking",
      "description": "Track your service provider's location in real-time.",
      "image": "assets/pic/technichian.jpg",
    },
  ];

  @override
  void initState() {
    super.initState();
    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _buttonPulseAnimation = Tween<double>(begin: 1.0, end: 1.10).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  void handleSeeMore() {
    if (currentIndex < onboardingData.length - 4) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildFrostedGlassCard(Widget child, {double borderRadius = 30}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 2, 86, 254).withOpacity(0.15),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: const Color.fromARGB(255, 10, 10, 10).withOpacity(0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.07),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildParallaxImage(int index, Size size) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        double page = 0;
        if (_controller.hasClients) {
          page = _controller.page ?? _controller.initialPage.toDouble();
        }

        double delta = page - index;
        double offsetX = delta * 40;
        double rotationY = delta * 0.12;

        return Transform(
          alignment: Alignment.center,
          transform:
              Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(rotationY),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 25,
                  offset: const Offset(0, 15),
                ),
              ],
              borderRadius: BorderRadius.circular(30),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(
                onboardingData[index]['image']!,
                height: size.height * 0.38,
                fit: BoxFit.cover,
                alignment: Alignment(offsetX / 100, 0),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedPageIndicator(int index) {
    bool isActive = index == currentIndex;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: isActive ? 28 : 12,
      height: 12,
      decoration: BoxDecoration(
        color:
            isActive
                ? const Color.fromARGB(255, 2, 2, 2)
                : const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(isActive ? 12 : 6),
        boxShadow:
            isActive
                ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.7),
                    blurRadius: 10,
                    spreadRadius: 3,
                  ),
                ]
                : null,
      ),
    );
  }

  Widget _buildRotatingGear() {
    return Positioned(
      top: 40,
      right: 30,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(seconds: 30),
        tween: Tween(begin: 0.0, end: 2 * pi),
        builder: (_, double angle, __) {
          return Transform.rotate(
            angle: angle,
            child: Icon(
              Icons.settings,
              size: 80,
              color: const Color.fromARGB(255, 218, 17, 17).withOpacity(0.08),
              shadows: const [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          );
        },
        onEnd: () {},
      ),
    );
  }

  Widget _buildParticles() {
    return Positioned.fill(
      child: IgnorePointer(child: CustomPaint(painter: _ParticlesPainter())),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          _buildParticles(),
          _buildRotatingGear(),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: onboardingData.length,
                    onPageChanged: (index) {
                      setState(() => currentIndex = index);
                    },
                    itemBuilder: (_, index) {
                      final item = onboardingData[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildParallaxImage(index, size),
                            const SizedBox(height: 30),
                            _buildFrostedGlassCard(
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 26,
                                  vertical: 28,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      item['title']!,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1.2,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(
                                              0.7,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      item['description']!,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.openSans(
                                        fontSize: 16,
                                        color: const Color.fromARGB(
                                          179,
                                          12,
                                          12,
                                          12,
                                        ),
                                        height: 1.4,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Page indicators & see more
                Padding(
                  padding: const EdgeInsets.only(bottom: 14, top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingData.length,
                      (index) => _buildAnimatedPageIndicator(index),
                    ),
                  ),
                ),

                TextButton(
                  onPressed: handleSeeMore,
                  child: Text(
                    'See More',
                    style: GoogleFonts.openSans(
                      color: const Color.fromARGB(255, 3, 94, 250),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                ScaleTransition(
                  scale: _buttonPulseAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: ElevatedButton(
                      onPressed: () {
                        if (currentIndex == onboardingData.length - 1) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WelcomeScreen(),
                            ),
                          );
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        // Remove backgroundColor here
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 18,
                        shadowColor: Colors.blueAccent.withOpacity(0.7),
                        minimumSize: const Size.fromHeight(58),
                        textStyle: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                      child: ShaderMask(
                        shaderCallback:
                            (bounds) => const LinearGradient(
                              colors: [Color(0xFF41A1F6), Color(0xFF2C87F0)],
                            ).createShader(
                              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                            ),
                        child: Text(
                          currentIndex == onboardingData.length - 1
                              ? 'Get Started'
                              : 'Next',
                          style: const TextStyle(
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  final Random _random = Random();
  final int particleCount = 30;
  final List<_Particle> particles = [];

  _ParticlesPainter() {
    for (int i = 0; i < particleCount; i++) {
      particles.add(_Particle());
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.15);

    for (var particle in particles) {
      particle.update(size);
      paint.color = Colors.white.withOpacity(particle.opacity);
      canvas.drawCircle(particle.position, particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _Particle {
  late Offset position;
  late double radius;
  late double opacity;
  late double speedY;

  _Particle() {
    final Random random = Random();
    position = Offset(random.nextDouble() * 400, random.nextDouble() * 800);
    radius = random.nextDouble() * 3 + 1.5;
    opacity = random.nextDouble() * 0.3 + 0.1;
    speedY = random.nextDouble() * 0.3 + 0.1;
  }

  void update(Size size) {
    position = Offset(position.dx, position.dy - speedY);
    if (position.dy < 0) {
      final Random random = Random();
      position = Offset(random.nextDouble() * size.width, size.height + radius);
      radius = random.nextDouble() * 3 + 1.5;
      opacity = random.nextDouble() * 0.3 + 0.1;
      speedY = random.nextDouble() * 0.3 + 0.1;
    }
  }
}
