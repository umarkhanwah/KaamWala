import 'dart:async';
import 'dart:ui' show ImageFilter;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kam_wala_app/dashboard/token_service.dart';
import 'package:kam_wala_app/dashboard/worker_home_page.dart';
import 'package:kam_wala_app/worker/WorkerPanel.dart';

class WorkerRegistrationPage extends StatefulWidget {
  const WorkerRegistrationPage({super.key});

  @override
  State<WorkerRegistrationPage> createState() => _WorkerRegistrationPageState();
}

class _WorkerRegistrationPageState extends State<WorkerRegistrationPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // --- Original controllers / state (UNCHANGED LOGIC) ---
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _selectedCategory;
  bool isLoading = false;

  // --- UI states / helpers (pure UI only) ---
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<String> _searchResults = [];

  final List<String> categories = const [
    "Electrician",
    "Plumber",
    "Carpenter",

    "Mechanic",
  ];

  final List<String> quickTips = const [
    "✅ Fill details correctly for quick approval.",
    "📞 Use an active phone number for contact.",
    "🔧 Choose the exact service category.",
    "🕒 Keep availability updated for more jobs.",
  ];
  int _currentTipIndex = 0;

  late final AnimationController _statsController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

  // Derived UI metric: form completion %
  double get _progress {
    double filled = 0;
    if (_nameController.text.trim().isNotEmpty) filled++;
    if (_cnicController.text.trim().isNotEmpty) filled++;
    if (_phoneController.text.trim().isNotEmpty) filled++;
    if (_selectedCategory != null) filled++;
    return filled / 4;
  }

  // --- Original registration (UNCHANGED) ---
  Future<void> registerWorker() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) return;

    setState(() => isLoading = true);

    final docRef = await FirebaseFirestore.instance.collection("workers").add({
      "name": _nameController.text.trim(),
      "cnic": _cnicController.text.trim(),
      "phone": _phoneController.text.trim(),
      "category": _selectedCategory,
      "approved": false,
      "rejected": false,
      "createdAt": FieldValue.serverTimestamp(),
      "status": "pending",
    });

    await TokenService.saveWorkerToken(docRef.id);

    setState(() => isLoading = false);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => WorkerHomePage(workerId: docRef.id)),
    );
  }

  // --- UI helpers ---
  InputDecoration _inputDecoration(
    String label,
    IconData icon, {
    String? hint,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.blueAccent),
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.blueAccent.withOpacity(0.25)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  void _runSearch(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    final results = categories
        .where((c) => c.toLowerCase().contains(q))
        .toList(growable: false);
    setState(() => _searchResults = results);
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => _runSearch(value),
    );
  }

  @override
  void initState() {
    super.initState();

    // Auto-rotate quick tips
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return false;
      setState(() {
        _currentTipIndex = (_currentTipIndex + 1) % quickTips.length;
      });
      return true;
    });

    // Update progress reactively
    _nameController.addListener(() => setState(() {}));
    _cnicController.addListener(() => setState(() {}));
    _phoneController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameController.dispose();
    _cnicController.dispose();
    _phoneController.dispose();
    _searchController.dispose();
    _statsController.dispose();
    super.dispose();
  }

  Widget _glassAppBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.55),
              Colors.white.withOpacity(0.30),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        // child: BackdropFilter(
        //   filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        //   child: Stack(
        //     children: [
        //       Center(
        //         child: ShaderMask(
        //           shaderCallback:
        //               (rect) => const LinearGradient(
        //                 colors: [Colors.blueAccent, Colors.lightBlue],
        //                 begin: Alignment.topLeft,
        //                 end: Alignment.bottomRight,
        //               ).createShader(rect),
        //           child: const Text(
        //             "Worker Registration",
        //             style: TextStyle(
        //               color: Colors.white, // still needed for ShaderMask
        //               fontSize: 26, // larger & modern
        //               fontWeight: FontWeight.bold,
        //               letterSpacing: 1.5, // better spacing
        //               fontFamily: "Roboto", // modern readable font
        //               shadows: [
        //                 Shadow(
        //                   offset: Offset(2, 2),
        //                   blurRadius: 4,
        //                   color: Colors.black26, // soft shadow
        //                 ),
        //                 Shadow(
        //                   offset: Offset(-1, -1),
        //                   blurRadius: 3,
        //                   color: Colors.white24, // highlight effect
        //                 ),
        //               ],
        //             ),
        //           ),
        //         ),
        //       ),

        //       // 🔴 Logout button added (top-right corner)
        //       Positioned(
        //         top: 8,
        //         right: 8,
        //         child: IconButton(
        //           icon: const Icon(Icons.logout, color: Colors.redAccent),
        //           onPressed: () async {
        //             await FirebaseAuth.instance.signOut();
        //             if (!context.mounted) return;
        //             Navigator.of(context).pop(); // back to previous screen
        //           },
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Stack(
            children: [
              Center(
                child: ShaderMask(
                  shaderCallback:
                      (rect) => const LinearGradient(
                        colors: [Colors.blueAccent, Colors.lightBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(rect),
                  child: const Text(
                    "Worker Registration",
                    style: TextStyle(
                      color: Colors.white, // still needed for ShaderMask
                      fontSize: 26, // larger & modern
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5, // better spacing
                      fontFamily: "Roboto", // modern readable font
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 4,
                          color: Colors.black26, // soft shadow
                        ),
                        Shadow(
                          offset: Offset(-1, -1),
                          blurRadius: 3,
                          color: Colors.white24, // highlight effect
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 🔴 Logout button (top-right corner)
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (!context.mounted) return;
                    Navigator.of(context).pop(); // back to previous screen
                  },
                ),
              ),

              // 🟢 Next page button (top-left corner)
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.blueAccent,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                WorkerPanel(), // 👉 replace with your next page widget
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _floatingSearchBar() {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.blueAccent.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: const InputDecoration(
              hintText: "Search category (e.g., Electrician)…",
              prefixIcon: Icon(Icons.search),
              border: InputBorder.none,
            ),
          ),
          if (_searchResults.isNotEmpty) const Divider(height: 10),
          if (_searchResults.isNotEmpty)
            ..._searchResults.map(
              (r) => ListTile(
                dense: true,
                leading: const Icon(Icons.check_circle_outline),
                title: Text(r),
                onTap: () {
                  setState(() {
                    _selectedCategory = r;
                    _searchResults = [];
                    _searchController.clear();
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _quickTips() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.tips_and_updates, color: Colors.amber),
          const SizedBox(width: 10),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder:
                  (child, anim) => FadeTransition(opacity: anim, child: child),
              child: Text(
                quickTips[_currentTipIndex],
                key: ValueKey<String>(quickTips[_currentTipIndex]),
                style: const TextStyle(
                  color: Color.fromARGB(255, 250, 50, 250),
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _animatedStat(String label, int value, IconData icon) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _statsController,
        curve: Curves.easeOutBack,
      ),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEBF3FF), Color(0xFFFFFFFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Colors.blueAccent),
            const SizedBox(width: 10),
            Expanded(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: value.toDouble()),
                duration: const Duration(milliseconds: 900),
                builder:
                    (_, v, __) => Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          v.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, {IconData icon = Icons.info_outline}) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEAF3FF), Color(0xFFFFFFFF)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.18)),
              ),
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: _progress.clamp(0, 1),
            backgroundColor: Colors.grey[300],
            color: Colors.blueAccent,
            minHeight: 8,
          ),
          const SizedBox(height: 6),
          Text(
            "${(_progress * 100).round()}% completed",
            style: TextStyle(color: Colors.black.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _glassAppBar(),
                _floatingSearchBar(),
                _quickTips(),
                _progressBar(),

                // --- Animated Stats Row ---
                _sectionHeader(
                  "Overview",
                  icon: Icons.space_dashboard_outlined,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      _animatedStat(
                        "Customer care",
                        100,
                        Icons.task_alt_outlined,
                      ),
                      const SizedBox(width: 12),
                      _animatedStat("Requests", 42, Icons.inbox_outlined),
                      const SizedBox(width: 12),
                      _animatedStat(
                        "Tasks managable",
                        100,
                        Icons.forum_outlined,
                      ),
                    ],
                  ),
                ),

                // --- Registration Form (ORIGINAL LOGIC) ---
                _sectionHeader("Registration Form", icon: Icons.badge_outlined),
                Card(
                  elevation: 8,
                  shadowColor: Colors.blueAccent.withOpacity(0.2),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: _inputDecoration(
                              "Full Name",
                              Icons.person_outline,
                            ),
                            validator:
                                (v) =>
                                    (v == null || v.isEmpty)
                                        ? "Enter your name"
                                        : null,
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<String>(
                            decoration: _inputDecoration(
                              "Service Category",
                              Icons.build_circle_outlined,
                            ),
                            value: _selectedCategory,
                            items:
                                categories
                                    .map(
                                      (c) => DropdownMenuItem<String>(
                                        value: c,
                                        child: Text(c),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (v) => setState(() => _selectedCategory = v),
                            validator:
                                (v) => v == null ? "Select a category" : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _cnicController,
                            decoration: _inputDecoration(
                              "CNIC",
                              Icons.credit_card,
                              hint: "XXXXX-XXXXXXX-X",
                            ),
                            validator:
                                (v) =>
                                    (v == null || v.isEmpty)
                                        ? "Enter CNIC"
                                        : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: _inputDecoration(
                              "Phone Number",
                              Icons.phone_android,
                              hint: "03XX-XXXXXXX",
                            ),
                            validator:
                                (v) =>
                                    (v == null || v.isEmpty)
                                        ? "Enter phone number"
                                        : null,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: isLoading ? null : registerWorker,
                              child:
                                  isLoading
                                      ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                      : const Text(
                                        "Submit",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // --- Informational Sections ---
                _sectionHeader(
                  "About This Registration",
                  icon: Icons.info_outline_rounded,
                ),
                _infoCard(
                  "Build Trust & Visibility",
                  "Create a verified profile to get discovered by customers seeking reliable workers. Accurate details speed up approval.",
                ),

                _sectionHeader(
                  "Safety & Verification",
                  icon: Icons.verified_user_outlined,
                ),
                _bulletCard(const [
                  "CNIC and contact verification improve platform safety.",
                  "Only share job details inside the app to stay protected.",
                  "Report suspicious activity via Help Center → Safety.",
                ]),

                _sectionHeader(
                  "Frequently Asked Questions",
                  icon: Icons.help_center_outlined,
                ),
                _faq(),

                const SizedBox(height: 26),
                Text(
                  "📞 Helpline: 0800-12345  •  ✉️ support@kamwala.com",
                  style: TextStyle(
                    color: Colors.blueAccent.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Extra UI pieces ---
  Widget _infoCard(String title, String body) {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.star_outline_rounded, color: Colors.orange),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    body,
                    style: TextStyle(color: Colors.black.withOpacity(0.75)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bulletCard(List<String> bullets) {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children:
              bullets
                  .map(
                    (b) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(b)),
                        ],
                      ),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  Widget _faq() {
    final items = [
      {
        "q": "How long does approval take?",
        "a":
            "Most profiles are reviewed within 24–48 hours if details are correct.",
      },
      {
        "q": "Can I edit my information later?",
        "a": "Yes, go to Profile → Edit to update your data anytime.",
      },
      {
        "q": "Why is category selection important?",
        "a":
            "Choosing the exact category connects you with the right jobs faster.",
      },
    ];
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children:
              items
                  .map(
                    (it) => ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                      title: Text(
                        it["q"]!,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              it["a"]!,
                              style: const TextStyle(height: 1.4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}
