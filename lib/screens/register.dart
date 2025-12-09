import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animations/animations.dart';
import 'package:kam_wala_app/screens/wellcomescreen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? selectedRole;
  bool loading = false;

  Future<void> registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() => loading = true);

      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text,
            );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
              'uid': userCredential.user!.uid,
              'name': nameController.text.trim(),
              'email': emailController.text.trim(),
              'role': selectedRole, // 🔥 dynamic role
              'createdAt': FieldValue.serverTimestamp(),
            });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Signup successful!')));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignupScreen()),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message ?? 'Signup failed')));
      } finally {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 600),
        reverse: false,
        transitionBuilder:
            (child, primaryAnimation, secondaryAnimation) =>
                FadeThroughTransition(
                  animation: primaryAnimation,
                  secondaryAnimation: secondaryAnimation,
                  child: child,
                ),

        child: SingleChildScrollView(
          key: const ValueKey("signup"),
          child: Column(
            children: [
              ClipPath(
                clipper: WaveClipper(),
                child: Container(
                  width: double.infinity,
                  height: 450,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black, Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),

                  // child: Center(
                  //   child: Column(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       Align(
                  //         alignment: Alignment.topLeft,
                  //         child: Padding(
                  //           padding: const EdgeInsets.only(
                  //             left: 16.0,
                  //             top: 16.0,
                  //           ),
                  //           child: GestureDetector(
                  //             onTap: () {
                  //               Navigator.push(
                  //                 context,
                  //                 MaterialPageRoute(
                  //                   builder: (context) => WelcomeScreen(),
                  //                 ),
                  //               );
                  //             },

                  //             child: const Icon(
                  //               Icons.arrow_back,
                  //               color: Colors.yellowAccent,

                  //               size: 35,
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //       Image.asset('assets/pic/DRILMAN.png', height: 200),
                  //       const SizedBox(height: 10),
                  //       const Text(
                  //         "Create your Account",
                  //         style: TextStyle(
                  //           color: Colors.yellowAccent,
                  //           fontSize: 24,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ).animate().fade(delay: 200.ms),
                  //     ],
                  //   ),
                  // ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.start, // start instead of center
                      children: [
                        const SizedBox(
                          height: 80,
                        ), // <-- Always gives 20px gap from top
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const WelcomeScreen(),
                                  ),
                                );
                              },
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.yellowAccent,
                                size: 35,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Image.asset('assets/pic/DRILMAN.png', height: 200),
                        const SizedBox(height: 10),
                        const Text(
                          "Create your Account",
                          style: TextStyle(
                            color: Colors.yellowAccent,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate().fade(delay: 200.ms),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      buildInputField(
                        controller: nameController,
                        label: "Name",
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 25),
                      buildInputField(
                        controller: emailController,
                        label: "Email",
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 25),
                      buildInputField(
                        controller: passwordController,
                        label: "Password",
                        icon: Icons.lock,
                        obscureText: true,
                      ),
                      const SizedBox(height: 25),

                      // 🔽 Role Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        hint: const Text("Select Role"),
                        decoration: InputDecoration(
                          labelText: "Role",
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(
                            Icons.supervised_user_circle,
                            color: Colors.yellow,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade900,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.yellow),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.yellowAccent,
                              width: 2,
                            ),
                          ),
                        ),
                        dropdownColor: Colors.black,
                        style: const TextStyle(color: Colors.white),
                        items:
                            ['admin', 'worker', 'user'].map((role) {
                              return DropdownMenuItem(
                                value: role,
                                child: Text(
                                  role[0].toUpperCase() + role.substring(1),
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() => selectedRole = value);
                        },
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Please select a role'
                                    : null,
                      ),
                      const SizedBox(height: 40),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC107),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 50,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: loading ? null : registerUser,
                        child:
                            loading
                                ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.black,
                                  ),
                                )
                                : const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ).animate().fadeIn().slideY(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "© 2025 Kaamwala.pk",
                style: TextStyle(color: Color.fromARGB(255, 31, 31, 31)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.yellow),
        filled: true,
        fillColor: Colors.grey.shade900,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.yellow),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.yellowAccent, width: 2),
        ),
      ),
      validator:
          (value) =>
              value == null || value.isEmpty ? 'Enter your $label' : null,
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.4);
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 60,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
