import 'package:flutter/material.dart';
import 'package:kam_wala_app/dashboard/admin_drawer.dart';
import 'package:kam_wala_app/screens/wellcomescreen.dart';
import 'package:kam_wala_app/services/auth_service.dart';

class SignupScreen1 extends StatefulWidget {
  const SignupScreen1({super.key});

  @override
  State<SignupScreen1> createState() => _SignupScreen1State();
}

class _SignupScreen1State extends State<SignupScreen1> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = "user"; // default role
  // final List<String> _roles = ["admin", "worker", "user"];
  final List<String> _roles = ["worker", "user"];
  
  final AuthService _authService = AuthService();

  bool _loading = false;

  void _signup() async {
    setState(() => _loading = true);
    var user = await _authService.signupWithRole(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      role: _selectedRole,
    );
    setState(() => _loading = false);

    if (user != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Signup Successful")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Signup Failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFB3E5FC), // Light Blue Background
      backgroundColor: const Color.fromARGB(255, 251, 254, 254),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.west,
                    color: Colors.blueAccent,
                    size: 28,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                    ); // or just leave empty for null route
                  },
                  splashRadius: 24,
                  tooltip: 'Go Back',
                ),
                const SizedBox(width: 8),
                const Text(
                  "",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 8, 8, 8),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            // Top Half Light Blue with Image
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.35,
              child: Center(
                child: Image.asset(
                  "assets/pic/Untitled design (1).png",
                  height: 660,
                  width: 800,
                ),
              ),
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),

              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.45),
                    blurRadius: 25,
                    spreadRadius: 10,
                    offset: const Offset(0, -20),
                  ),
                ],
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 253, 254, 255), // Light Blue
                    Color.fromARGB(255, 166, 210, 246), // Medium Blue
                    Color.fromARGB(255, 253, 251, 251), // Dark Blue
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Name TextField with modern shadows & rounded corners
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Full Name",
                      labelStyle: const TextStyle(color: Colors.blueAccent),
                      filled: true,
                      fillColor: Colors.blueAccent.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 20,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: Colors.blueAccent,
                          width: 2,
                        ),
                      ),
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 22),

                  // Phone Number TextField same style
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Phone Number",
                      labelStyle: const TextStyle(color: Colors.blueAccent),
                      filled: true,
                      fillColor: Colors.blueAccent.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 20,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: Colors.blueAccent,
                          width: 2,
                        ),
                      ),
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),

                  // Email TextField
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: const TextStyle(color: Colors.blueAccent),
                      filled: true,
                      fillColor: Colors.blueAccent.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 20,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: Colors.blueAccent,
                          width: 2,
                        ),
                      ),
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),

                  // Password TextField
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: const TextStyle(color: Colors.blueAccent),
                      filled: true,
                      fillColor: Colors.blueAccent.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 20,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: Colors.blueAccent,
                          width: 2,
                        ),
                      ),
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),

                  // Dropdown with similar style
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: InputDecoration(
                      labelText: "Select Role",
                      labelStyle: const TextStyle(color: Colors.blueAccent),
                      filled: true,
                      fillColor: Colors.blueAccent.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 20,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: Colors.blueAccent,
                          width: 2,
                        ),
                      ),
                    ),
                    items:
                        _roles.map((role) {
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Text(role.toUpperCase()),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                      });
                    },
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                    iconEnabledColor: Colors.blueAccent,
                  ),
                  const SizedBox(height: 38),

                  // Elevated Button with smooth gradient & rounded corners
                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 54),
                          backgroundColor: Colors.blueAccent,
                          elevation: 12,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          shadowColor: Colors.blueAccent.withOpacity(0.6),
                        ),
                        onPressed: _signup,
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
