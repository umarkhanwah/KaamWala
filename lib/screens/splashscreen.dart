import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kam_wala_app/dashboard/admin_home.dart';
import 'package:kam_wala_app/screens/onboundring.dart';
import 'package:kam_wala_app/user/user_panel.dart';
import 'package:kam_wala_app/worker/WorkerPanel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
      
  late AnimationController _controller;
  late Animation<double> _logoScaleAnimation;
  

  static const Color primaryBlue = Color(0xFF3498DB);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();

    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.1,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    // Timer for splash
    Timer(const Duration(seconds: 4), () async {
      await _checkUserLogin();
    });
  }

  Future<void> _checkUserLogin() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        String role = userDoc['role']?.toString().toLowerCase() ?? '';

        if (role == "user") {
          _navigateWithAnimation(const UserPanel());
        } else if (role == "admin") {
          _navigateWithAnimation(const AdminHomePage());
        } else if (role == "worker") {
          _navigateWithAnimation(const WorkerPanel());
        } else {
          _navigateWithAnimation(const OnboardingScreen());
        }
      } else {
        _navigateWithAnimation(const OnboardingScreen());
      }
    } else {
      _navigateWithAnimation(const OnboardingScreen());
    }
  }

  void _navigateWithAnimation(Widget page) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              Color(0xFFe0f0ff),
              Color(0xFF2a75bb),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: _logoScaleAnimation,
            child: Image.asset(
              'assets/pic/Kaamwala.png',
              width: size.width * 0.6,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
    );
  }
}
