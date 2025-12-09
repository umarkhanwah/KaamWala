import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kam_wala_app/user/user_panel.dart';
import 'package:kam_wala_app/Auth/login_screen.dart';

class HomeServiceScreen extends StatefulWidget {
  const HomeServiceScreen({super.key});

  @override
  State<HomeServiceScreen> createState() => _HomeServiceScreenState();
}

class _HomeServiceScreenState extends State<HomeServiceScreen> {
  @override
  void initState() {
    super.initState();
    // ✅ Show Terms & Conditions dialog after screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTermsDialog();
    });
  }

  // ✅ Logout function
  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen1()),
      (route) => false,
    );
  }

  // ✅ Terms & Conditions Dialog
  void _showTermsDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "📜 Terms & Conditions",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "By using KaamWala App, you agree to the following:\n\n"
                  "1. Services are provided by verified workers but company is not liable for damages.\n"
                  "2. Payments must be made via the official platform only.\n"
                  "3. Misuse of services may lead to account suspension.\n"
                  "4. Your data will be secured and not shared with third parties.\n"
                  "5. By continuing, you accept our privacy policy & terms.",
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _logout,
              child: const Text(
                "Decline",
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx); // close dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Accept"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F0FF), Color(0xFFF4F6F8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // 🌟 Center Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                            'assets/pic/happy man.png',
                            width: (size.width * 0.7),
                            height: size.height * 0.5,
                            fit: BoxFit.cover,
                          ),
                  const SizedBox(height: 20),
                  Text(
                    "Reliable Home Services",
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.07,
                      fontWeight: FontWeight.w700,
                      color: Colors.blueGrey.shade900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Book trusted professionals for cleaning,\nrepairs, and more — anytime, anywhere.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.04,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // ⬇️ Bottom Button
            Positioned(
              bottom: size.height * 0.05,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UserPanel()),
                    );
                  },
                  child: CircleAvatar(
                    radius: size.width * 0.09,
                    backgroundColor: Colors.blueAccent,
                    child: const Icon(Icons.arrow_forward_ios,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
