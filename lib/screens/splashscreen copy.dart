import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kam_wala_app/screens/onboundring.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _dropletFallAnimation;
  late Animation<double> _gearRotationAnimation;
  late Animation<double> _waterSplashAnimation;

  // Additional plumber animations
  late Animation<double> _pipePulseAnimation;
  late Animation<double> _wrenchRotationAnimation;
  late Animation<double> _dripFallAnimation;

  // For tools: float, rotate, scale animations with phase shifts
  late Animation<double> _toolFloat1;
  late Animation<double> _toolFloat2;
  late Animation<double> _toolFloat3;
  late Animation<double> _toolRotate1;
  late Animation<double> _toolRotate2;
  late Animation<double> _toolRotate3;
  late Animation<double> _toolScale1;
  late Animation<double> _toolScale2;

  static const Color primaryBlue = Color(0xFF3498DB);
  static const Color lightBlue = Color(0xFF85C1E9);
  static const Color whiteColor = Colors.white;
  static const Color blackColor = Colors.black87;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0)),
    );

    _rippleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _dropletFallAnimation = Tween<double>(begin: -30, end: 30).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
      ),
    );

    _gearRotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.1416,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _waterSplashAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Additional plumber animations:
    _pipePulseAnimation = Tween<double>(begin: 0.95, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
    _wrenchRotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.1416,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
    _dripFallAnimation = Tween<double>(begin: -50, end: 50).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 1, curve: Curves.easeInOut),
      ),
    );

    // Tool animations with phase offsets for variety
    _toolFloat1 = Tween<double>(begin: -12, end: 12).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
    _toolFloat2 = Tween<double>(begin: 10, end: -10).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
        reverseCurve: Curves.easeInOut,
      ),
    );
    _toolFloat3 = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOutSine),
      ),
    );

    _toolRotate1 = Tween<double>(
      begin: -0.03,
      end: 0.03,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _toolRotate2 = Tween<double>(
      begin: 0.04,
      end: -0.04,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _toolRotate3 = Tween<double>(
      begin: -0.02,
      end: 0.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _toolScale1 = Tween<double>(
      begin: 0.85,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _toolScale2 = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat(reverse: true);

    Timer(const Duration(seconds: 7), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const OnboardingScreen(),
          transitionsBuilder: (_, animation, secondaryAnimation, child) {
            // Combine fade + scale transition
            final fade = Tween<double>(begin: 0.0, end: 1.0).animate(animation);
            final scale = Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            );

            return FadeTransition(
              opacity: fade,
              child: ScaleTransition(scale: scale, child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildRippleEffect(double size, double progress) {
    final rippleSize = size * (0.7 + progress);
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    return Center(
      child: Container(
        width: rippleSize,
        height: rippleSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: primaryBlue.withOpacity(0.2 * opacity),
          border: Border.all(
            color: primaryBlue.withOpacity(0.3 * opacity),
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildWaterDroplet(double fallDistance, double left) {
    // Multiple droplets falling from different horizontal positions
    return Positioned(
      bottom: 120 + fallDistance,
      left: left,
      child: Opacity(
        opacity: 0.7,
        child: Icon(
          Icons.water_drop,
          size: 20,
          color: lightBlue.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildRotatingGear(double size, Animation<double> animation) {
    return Positioned(
      bottom: 20,
      left: 20,
      child: RotationTransition(
        turns: animation,
        child: Icon(
          Icons.settings, // gear icon
          size: size,
          color: primaryBlue.withOpacity(0.6),
          shadows: const [
            Shadow(color: Colors.black26, blurRadius: 5, offset: Offset(2, 2)),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterSplash(double offset) {
    return Positioned(
      top: 180 - offset,
      left: 100 + offset,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final scale = 1.0 - (offset / 15) + (i * 0.1);
          final opacity = (1.0 - offset / 15).clamp(0.0, 1.0);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Transform.scale(
              scale: scale.clamp(0.7, 1.1),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: lightBlue.withOpacity(0.8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: lightBlue.withOpacity(0.7),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAnimatedTool({
    required IconData icon,
    required double left,
    required double top,
    required double size,
    required Animation<double> floatAnim,
    required Animation<double> rotateAnim,
    Animation<double>? scaleAnim,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Positioned(
          left: left,
          top: top + floatAnim.value,
          child: RotationTransition(
            turns: rotateAnim,
            child: Transform.scale(
              scale: scaleAnim?.value ?? 1.0,
              child: Icon(
                icon,
                size: size,
                color: Colors.white.withOpacity(0.9),
                shadows: [
                  Shadow(
                    color: primaryBlue.withOpacity(0.7),
                    blurRadius: 10,
                    offset: const Offset(0, 0),
                  ),
                  const Shadow(
                    color: Colors.black26,
                    blurRadius: 3,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFe0f0ff), // lighter blue top-left
              Color(0xFF2a75bb), // deeper blue bottom-right
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ripples
            AnimatedBuilder(
              animation: _rippleAnimation,
              builder: (_, __) {
                return Stack(
                  children: [
                    _buildRippleEffect(220, _rippleAnimation.value),
                    _buildRippleEffect(180, (_rippleAnimation.value + 0.5) % 1),
                  ],
                );
              },
            ),

            // Multiple water droplets falling with different positions and delays
            AnimatedBuilder(
              animation: _dripFallAnimation,
              builder: (_, __) {
                return Stack(
                  children: [
                    _buildWaterDroplet(
                      _dripFallAnimation.value,
                      size.width * 0.15,
                    ),
                    _buildWaterDroplet(
                      (_dripFallAnimation.value + 20) % 80 - 40,
                      size.width * 0.3,
                    ),
                    _buildWaterDroplet(
                      (_dripFallAnimation.value + 40) % 80 - 40,
                      size.width * 0.45,
                    ),
                  ],
                );
              },
            ),

            // Rotating gear (pipe gear)
            _buildRotatingGear(50, _gearRotationAnimation),

            // Water splash near logo
            AnimatedBuilder(
              animation: _waterSplashAnimation,
              builder: (_, __) {
                return _buildWaterSplash(_waterSplashAnimation.value);
              },
            ),

            // Pulsing pipe icon on left near bottom
            Positioned(
              bottom: 100,
              left: 30,
              child: ScaleTransition(
                scale: _pipePulseAnimation,
                child: Icon(
                  Icons
                      .plumbing_rounded, // pipe icon from flutter icons (if available)
                  size: 50,
                  color: Colors.white.withOpacity(0.85),
                  shadows: [
                    Shadow(
                      color: primaryBlue.withOpacity(0.8),
                      blurRadius: 15,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ),

            // Rotating wrench near logo top-right
            Positioned(
              top: size.height * 0.25,
              right: size.width * 0.25,
              child: RotationTransition(
                turns: _wrenchRotationAnimation,
                child: Icon(
                  Icons.build, // wrench icon
                  size: 55,
                  color: Colors.white.withOpacity(0.9),
                  shadows: [
                    Shadow(
                      color: primaryBlue.withOpacity(0.9),
                      blurRadius: 12,
                      offset: const Offset(0, 0),
                    ),
                    const Shadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),

            // 8 Animated Plumbing Tools scattered on screen:
            _buildAnimatedTool(
              icon: Icons.build, // wrench
              left: 40,
              top: size.height * 0.35,
              size: 45,
              floatAnim: _toolFloat1,
              rotateAnim: _toolRotate1,
              scaleAnim: _toolScale1,
            ),
            _buildAnimatedTool(
              icon: Icons.toggle_on, // valve toggle style
              left: size.width * 0.75,
              top: size.height * 0.25,
              size: 50,
              floatAnim: _toolFloat2,
              rotateAnim: _toolRotate2,
              scaleAnim: _toolScale2,
            ),
            _buildAnimatedTool(
              icon: Icons.tune, // pipe tuner
              left: size.width * 0.6,
              top: size.height * 0.5,
              size: 40,
              floatAnim: _toolFloat3,
              rotateAnim: _toolRotate3,
            ),

            _buildAnimatedTool(
              icon: Icons.precision_manufacturing, // bolt
              left: size.width * 0.3,
              top: size.height * 0.2,
              size: 35,
              floatAnim: _toolFloat2,
              rotateAnim: _toolRotate3,
            ),
            _buildAnimatedTool(
              icon: Icons.water_damage, // faucet/water drop icon
              left: size.width * 0.15,
              top: size.height * 0.55,
              size: 38,
              floatAnim: _toolFloat1,
              rotateAnim: _toolRotate2,
            ),
            _buildAnimatedTool(
              icon: Icons.plumbing, // pipe wrench
              left: size.width * 0.8,
              top: size.height * 0.55,
              size: 42,
              floatAnim: _toolFloat3,
              rotateAnim: _toolRotate1,
              scaleAnim: _toolScale1,
            ),
            _buildAnimatedTool(
              icon: Icons.settings_applications, // gear icon
              left: size.width * 0.4,
              top: size.height * 0.4,
              size: 37,
              floatAnim: _toolFloat2,
              rotateAnim: _toolRotate1,
            ),
            _buildAnimatedTool(
              icon: Icons.electrical_services, // electric bolt for modern tech
              left: size.width * 0.7,
              top: size.height * 0.15,
              size: 34,
              floatAnim: _toolFloat1,
              rotateAnim: _toolRotate3,
            ),

            // Optional sparkle star near logo
            Positioned(
              top: size.height * 0.35,
              left: size.width * 0.3,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (_, __) {
                  final sparkleOpacity = (0.5 +
                          0.5 * (_controller.value * 2 - 1).abs())
                      .clamp(0.0, 1.0);
                  return Opacity(
                    opacity: sparkleOpacity,
                    child: Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.white.withOpacity(0.8),
                      shadows: [
                        Shadow(
                          color: Colors.white.withOpacity(0.9),
                          blurRadius: 6,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Main content: Logo, text, loading indicator
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _logoScaleAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withOpacity(0.7),
                          blurRadius: 25,
                          spreadRadius: 5,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/pic/Kaamwala.png',
                      width: size.width * 0.6,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),

                //const SizedBox(height: 30),

                // FadeTransition(
                //   opacity: _textFadeAnimation,
                //   child: ClipRRect(
                //     borderRadius: BorderRadius.circular(16),
                //     child: BackdropFilter(
                //       filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                //       child: Container(
                //         padding: const EdgeInsets.symmetric(
                //           horizontal: 24,
                //           vertical: 14,
                //         ),
                //         decoration: BoxDecoration(
                //           color: Colors.white.withOpacity(0.18),
                //           borderRadius: BorderRadius.circular(16),
                //           border: Border.all(
                //             color: Colors.white.withOpacity(0.4),
                //             width: 1.5,
                //           ),
                //           boxShadow: [
                //             BoxShadow(
                //               color: Colors.white.withOpacity(0.12),
                //               blurRadius: 18,
                //               offset: const Offset(0, 8),
                //             ),
                //           ],
                //         ),
                //         child: Text(
                //           'Professional plumbing services at your doorstep',
                //           style: TextStyle(
                //             color: blackColor.withOpacity(0.85),
                //             fontSize: 20,
                //             fontWeight: FontWeight.w600,
                //             letterSpacing: 1.3,
                //             shadows: [
                //               Shadow(
                //                 blurRadius: 5,
                //                 color: Colors.white.withOpacity(0.5),
                //                 offset: const Offset(0, 2),
                //               ),
                //             ],
                //           ),
                //           textAlign: TextAlign.center,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                //const SizedBox(height: 35),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.7, end: 1.2),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeInOut,
                  builder: (_, scale, __) {
                    return Transform.scale(
                      scale: scale,
                      child: SizedBox(
                        width: 70,
                        height: 70,
                        child: CircularProgressIndicator(
                          strokeWidth: 6,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            primaryBlue.withOpacity(0.95),
                          ),
                          backgroundColor: primaryBlue.withOpacity(0.3),
                        ),
                      ),
                    );
                  },
                  onEnd: () {
                    setState(() {});
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
