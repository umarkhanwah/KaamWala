import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:kam_wala_app/Admin/Adminpanel.dart';
import 'package:kam_wala_app/Service_Request/worker_requests_page.dart';
import 'package:kam_wala_app/dashboard/admin_home.dart';
import 'package:kam_wala_app/screens/ResetPassword.dart';
import 'package:kam_wala_app/screens/main_screen.dart';
import 'package:kam_wala_app/worker/worker_registration.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen1 extends StatefulWidget {
  const LoginScreen1({super.key});
  @override
  State<LoginScreen1> createState() => _LoginScreen1State();
}

class _LoginScreen1State extends State<LoginScreen1>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _loading = false;

  late AnimationController _iconController;
  late Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _iconAnimation = Tween<double>(begin: 0.0, end: 15.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeInOut),
    );

    // ✅ Check if already logged in
    _checkUserLogin();
  }

  Future<void> _checkUserLogin() async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Get user role from Firestore
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        String role = userDoc['role']?.toString().toLowerCase() ?? '';
        _navigateToRoleScreen(role);
      }
    }
  }

  void _navigateToRoleScreen(String role) {
    if (role == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AdminHomePage()),
      );
    } else if (role == 'worker') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => WorkerRegistrationPage()),
      );
    } else if (role == 'user') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeServiceScreen()),
      );
    }
  }

  // void _navigateToRoleScreen(String role) async {
  //   if (role == 'admin') {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (_) => AdminHomePage()),
  //     );
  //   } else if (role == 'worker') {
  //     final uid = FirebaseAuth.instance.currentUser!.uid;

  //     final doc =
  //         await FirebaseFirestore.instance.collection("users").doc(uid).get();

  //     final data = doc.data() ?? {};

  //     final workerId = uid;
  //     final workerName = data["name"] ?? "Worker";
  //     final workerPhone = data["phone"] ?? "";

  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder:
  //             (_) => WorkerRequestsPagenew(
  //               workerId: workerId,
  //               workerName: workerName,
  //               workerPhone: workerPhone,
  //             ),
  //       ),
  //     );
  //   } else if (role == 'user') {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (_) => HomeServiceScreen()),
  //     );
  //   }
  // }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      UserCredential userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userCred.user!.uid).get();

      if (!userDoc.exists) {
        throw Exception("User data not found");
      }

      String role = userDoc['role']?.toString().toLowerCase() ?? '';
      print("User Role: $role");
      _navigateToRoleScreen(role);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? "Login failed")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    } finally {
      setState(() => _loading = false);
    }
  }

  InputDecoration _neumorphicInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(
        color: const Color(0xFF1565C0),
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      prefixIcon: Icon(icon, color: const Color(0xFF1976D2)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.8),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 234, 235, 236),
                  Color.fromARGB(255, 93, 158, 255),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 36,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedBuilder(
                              animation: _iconAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, -_iconAnimation.value),
                                  child: child,
                                );
                              },
                              child: SizedBox(
                                height: 160,
                                width: 500,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.lightBlue.shade100,
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset(
                                      'assets/pic/mechanic.png',
                                      width: double.infinity,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),

                            Text(
                              'Welcome Back',
                              style: GoogleFonts.poppins(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                color: Colors.black.withOpacity(0.9),
                                letterSpacing: 1.3,
                              ),
                            ),
                            const SizedBox(height: 36),

                            // Email
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white.withOpacity(0.85),
                              ),
                              child: TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: _neumorphicInputDecoration(
                                  'Email',
                                  Icons.email_outlined,
                                ),
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF0D47A1),
                                  fontSize: 17,
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Password
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white.withOpacity(0.85),
                              ),
                              child: TextField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: _neumorphicInputDecoration(
                                  'Password',
                                  Icons.lock_outline,
                                ),
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF0D47A1),
                                  fontSize: 17,
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => const ResetPasswordScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Forgot Password?',
                                  style: GoogleFonts.poppins(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 36),

                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(
                                    0.85,
                                  ),
                                  shadowColor: Colors.blue.shade100,
                                  elevation: 18,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                onPressed: _loading ? null : _login,
                                child:
                                    _loading
                                        ? const SizedBox(
                                          width: 28,
                                          height: 28,
                                          child: CircularProgressIndicator(
                                            color: Color(0xFF0D47A1),
                                            strokeWidth: 3.5,
                                          ),
                                        )
                                        : Text(
                                          'Login',
                                          style: GoogleFonts.poppins(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.3,
                                            color: const Color(0xFF0D47A1),
                                          ),
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
