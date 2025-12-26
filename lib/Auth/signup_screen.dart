import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kam_wala_app/screens/wellcomescreen.dart';
import 'package:kam_wala_app/services/auth_service.dart';

class SignupScreen1 extends StatefulWidget {
  const SignupScreen1({super.key});

  @override
  State<SignupScreen1> createState() => _SignupScreen1State();
}

class _SignupScreen1State extends State<SignupScreen1>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cnicController = TextEditingController();

  final AuthService _authService = AuthService();

  final List<String> _roles = ['user', 'worker'];
  String _selectedRole = 'user';
  String? _selectedCategoryId;

  List<Map<String, String>> _categories = [];
  bool _loading = false;

  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _fetchCategories();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _expandAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  Future<void> _fetchCategories() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('categories').get();

    setState(() {
      _categories = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['name'].toString(),
              })
          .toList();
    });
  }

  void _onRoleChanged(String role) {
    setState(() {
      _selectedRole = role;
      if (role == 'worker') {
        _controller.forward();
      } else {
        _controller.reverse();
        _cnicController.clear();
        _selectedCategoryId = null;
      }
    });
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRole == 'worker' && _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a category")),
      );
      return;
    }

    setState(() => _loading = true);

    final user = await _authService.signupWithRole(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      role: _selectedRole,
      extraFields: _selectedRole == 'worker'
          ? {
              'cnic': _cnicController.text.trim(),
              'categoryId': _selectedCategoryId,
              'status': 'Pending',
            }
          : {},
    );

    setState(() => _loading = false);

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signup Successful")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signup Failed")),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEEF2FF), Color(0xFFF8FAFC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _topBar(),
                  const SizedBox(height: 20),
                  _signupCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _signupCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 25,
            offset: const Offset(0, 12),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Create Account",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Sign up to continue",
            style: TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 26),

          _field(_nameController, "Full Name", Icons.person,
              validator: _required),
          _gap(),
          _field(_phoneController, "Phone Number", Icons.phone,
              keyboard: TextInputType.phone, validator: _phone),
          _gap(),
          _field(_emailController, "Email", Icons.email,
              keyboard: TextInputType.emailAddress, validator: _email),
          _gap(),
          _field(_passwordController, "Password", Icons.lock,
              obscure: true, validator: _password),

          const SizedBox(height: 22),
          _roleToggle(),

          SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: -1,
            child: _workerSection(),
          ),

          const SizedBox(height: 28),
          _loading ? const Center(child: CircularProgressIndicator()) : _button(),
        ],
      ),
    );
  }

  Widget _roleToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: _roles.map((role) {
          final selected = _selectedRole == role;
          return Expanded(
            child: GestureDetector(
              onTap: () => _onRoleChanged(role),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                          )
                        ]
                      : [],
                ),
                child: Text(
                  role.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        selected ? Colors.blueAccent : Colors.blueGrey,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _workerSection() {
    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _field(_cnicController, "CNIC Number", Icons.badge,
              keyboard: TextInputType.number),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedCategoryId,
            decoration: _dropdownDecoration("Select Category"),
            items: _categories
                .map<DropdownMenuItem<String>>((cat) => DropdownMenuItem(
                      value: cat['id'],
                      child: Text(cat['name']!),
                    ))
                .toList(),
            onChanged: (val) => setState(() => _selectedCategoryId = val),
          ),
        ],
      ),
    );
  }

  Widget _button() {
    return Container(
      height: 52,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Color(0xFF6366F1)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ElevatedButton(
        onPressed: _signup,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: const Text(
          "Create Account",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  SizedBox _gap() => const SizedBox(height: 16);

  // ================= VALIDATORS =================

  String? _required(String? v) =>
      v == null || v.isEmpty ? 'Required field' : null;

  String? _phone(String? v) =>
      RegExp(r'^\d{10,15}$').hasMatch(v ?? '') ? null : 'Invalid phone';

  String? _email(String? v) =>
      RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v ?? '')
          ? null
          : 'Invalid email';

  String? _password(String? v) =>
      v != null && v.length >= 6 ? null : 'Min 6 characters';

  String? _cnic(String? v) =>
      RegExp(r'^\d{13}$').hasMatch(v ?? '') ? null : '13 digit CNIC';
}
