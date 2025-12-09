import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:kam_wala_app/image%20crud%20hamdeling/imagedatafatech.dart';
import 'package:kam_wala_app/user/3services_select_screen.dart';
import '../firebase_options.dart';

class BusinessFormScreen extends StatefulWidget {
  const BusinessFormScreen({super.key});

  @override
  State<BusinessFormScreen> createState() => _BusinessFormScreenState();
}

class _BusinessFormScreenState extends State<BusinessFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final dbRef = FirebaseDatabase.instance.ref("businesses");

  // Controllers
  final TextEditingController _businessName = TextEditingController();
  final TextEditingController _repName = TextEditingController();
  final TextEditingController _repNumber = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _message = TextEditingController();

  String businessType = "Corporate Office";

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // CREATE
  Future<void> _createBusiness() async {
    if (_formKey.currentState!.validate()) {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      await dbRef.child(id).set({
        "id": id,
        "type": businessType,
        "businessName": _businessName.text.trim(),
        "repName": _repName.text.trim(),
        "repNumber": _repNumber.text.trim(),
        "email": _email.text.trim(),
        "city": _city.text.trim(),
        "message": _message.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF4CAF50), // modern green
                  Color(0xFF2E7D32), // darker modern green
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "✅ Business Added Successfully",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          padding: EdgeInsets.zero,
          duration: const Duration(seconds: 3),
          dismissDirection: DismissDirection.horizontal,
        ),
      );

      _clearForm();
    }
  }

  void _clearForm() {
    _businessName.clear();
    _repName.clear();
    _repNumber.clear();
    _email.clear();
    _city.clear();
    _message.clear();
    setState(() {
      businessType = "Corporate Office";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.blue.shade50,

      appBar: AppBar(
        title: const Text(
          "Corporate Office",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 6,
        shadowColor: Colors.blue.withOpacity(0.4),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),

            onPressed:
                () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => FetchAllCategories()),
                  // MaterialPageRoute(builder: (context) => Home3Screen()),
                ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFF90CAF9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  height: 160,
                  alignment: Alignment.center,
                  child: Container(
                    width: 350,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 126, 192, 246),
                          Color(0xFF1976D2),
                          Color(0xFF0D47A1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.4),
                          blurRadius: 25,
                          spreadRadius: 3,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: const Color.fromARGB(
                          255,
                          199,
                          236,
                          244,
                        ).withOpacity(0.8),
                        width: 2.5,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.business_center_rounded,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Glassmorphic Card
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Card(
                      elevation: 8,
                      shadowColor: Colors.blue.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Dropdown
                              DropdownButtonFormField<String>(
                                value: businessType,
                                items: const [
                                  DropdownMenuItem(
                                    value: "Corporate Office",
                                    child: Text("Corporate Office"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Educational System",
                                    child: Text("Educational System"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Shop",
                                    child: Text("Shop"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Clinic",
                                    child: Text("Clinic"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Restaurant",
                                    child: Text("Restaurant"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Real State",
                                    child: Text("Real State"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Not For Profit Organization",
                                    child: Text("Not For Profit Organization"),
                                  ),
                                ],
                                onChanged:
                                    (val) =>
                                        setState(() => businessType = val!),
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.business_center,
                                    color: Colors.blue,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              _buildTextField(
                                "Business Name*",
                                _businessName,
                                required: true,
                                icon: Icons.apartment,
                              ),
                              _buildTextField(
                                "Representative Name*",
                                _repName,
                                required: true,
                                icon: Icons.person,
                              ),
                              _buildTextField(
                                "Representative Number*",
                                _repNumber,
                                required: true,
                                keyboard: TextInputType.phone,
                                icon: Icons.phone,
                              ),
                              _buildTextField(
                                "Email",
                                _email,
                                keyboard: TextInputType.emailAddress,
                                icon: Icons.email,
                              ),
                              _buildTextField(
                                "City",
                                _city,
                                icon: Icons.location_city,
                              ),
                              _buildTextField(
                                "Message",
                                _message,
                                maxLines: 3,
                                icon: Icons.message,
                              ),

                              const SizedBox(height: 30),

                              // Submit button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 8,
                                    backgroundColor: Colors.blueAccent,
                                    shadowColor: Colors.blueAccent.withOpacity(
                                      0.5,
                                    ),
                                  ),
                                  onPressed: _createBusiness,
                                  child: const Text(
                                    "Submit",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool required = false,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        validator: (value) {
          if (required && (value == null || value.trim().isEmpty)) {
            return "$label is required";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: Colors.blue) : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
          ),
        ),
      ),
    );
  }
}
