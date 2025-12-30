import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

import 'package:kam_wala_app/Auth/login_screen.dart';
import 'package:kam_wala_app/Service_Request/worker_requests_page.dart';
import 'package:kam_wala_app/Service_Request/workersumarypage.dart';
import 'package:kam_wala_app/feedback/workerfeedbackscreen.dart';
import 'package:kam_wala_app/user/user_panel.dart';
import 'package:kam_wala_app/wallet/Worker_wallet.dart';
import 'package:kam_wala_app/worker/worker_registration.dart';

class WorkerPanel extends StatefulWidget {
  const WorkerPanel({super.key});

  @override
  State<WorkerPanel> createState() => _WorkerPanelState();
}

class _WorkerPanelState extends State<WorkerPanel> {
  String workerCategory = '';
  double walletAmount = 0;

  int _selectedIndex = 0;
  String _selectedRole = 'Worker';

  late String workerId;
  late String workerName;
  late String workerPhone;


  final List<String> _roles = ['Worker', 'User'];

  final List<String> _titles = [
    'Dashboard',
    'Wallet',
    'Summary',
    'Requests',
  ];
@override
void initState() {
  super.initState();
  final user = FirebaseAuth.instance.currentUser;

  workerId = user?.uid ?? '';
  workerName = 'Worker';
  workerPhone = user?.phoneNumber ?? '';

  _loadUserData();
}

  Future<void> _loadUserData() async {
  final userSnap = await FirebaseFirestore.instance
      .collection('users')
      .doc(workerId)
      .get();

  if (!userSnap.exists) return;

  final data = userSnap.data()!;

  // ✅ Name
  workerName = data['name'] ?? workerName;

  // ✅ Wallet (users collection se)
  walletAmount = (data['walletAmount'] ?? 0).toDouble();

  // ✅ Category via categoryId
  final categoryId = data['categoryId'];
  if (categoryId != null && categoryId.toString().isNotEmpty) {
    final catSnap = await FirebaseFirestore.instance
        .collection('categories')
        .doc(categoryId)
        .get();

    if (catSnap.exists) {
      workerCategory = catSnap['name'] ?? '';
    }
  }

  if (mounted) setState(() {});
}

  List<Widget> get _pages => [
        const WorkerRegistrationPage(),
        WorkerWallet(),
        WorkerSummaryPage(
          workerId: workerId,
          workerName: workerName,
          workerPhone: workerPhone,
        ),
        WorkerRequestsPagenew(
          workerId: workerId,
          workerName: workerName,
          workerPhone: workerPhone,
        ),
      ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  Future<void> _logout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'fcmToken': FieldValue.delete()});
      await FirebaseMessaging.instance.deleteToken();
    }

    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen1()),
      (_) => false,
    );
  }

  void _handleRoleChange(String? role) {
    if (role == null || role == _selectedRole) return;

    setState(() => _selectedRole = role);
    if (role == 'User') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => UserPanel()),
      );
    }
  }

  // ================= HEADER =================

  Widget _header() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Colors.blue, size: 32),
          ),
          const SizedBox(width: 14),
          Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        workerName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        workerCategory.isNotEmpty ? workerCategory : "Category not set",
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
        ),
      ),
    ],
  ),
),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(Icons.account_balance_wallet,
                  color: Colors.white, size: 22),
              const SizedBox(height: 4),
              Text(
                "Rs ${walletAmount.toStringAsFixed(0)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  // ================= MOBILE VIEW =================

  Widget _mobileView() {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E3C72),
        title: Text(_titles[_selectedIndex], style: TextStyle(color: Colors.white),),
        leadingWidth: 140,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedRole,
              dropdownColor: Colors.black,
              icon: const Icon(Icons.swap_horiz, color: Colors.white),
              onChanged: _handleRoleChange,
              items: _roles
                  .map((r) => DropdownMenuItem(
                        value: r,
                        child:
                            Text(r, style: const TextStyle(color: Colors.white)),
                      ))
                  .toList(),
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            label: const Text(
              "Logout",
              style: TextStyle(color: Colors.redAccent),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          _header(),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: const Color(0xFF1E3C72),
        activeColor: Colors.white,
        style: TabStyle.reactCircle,
        items: const [
          TabItem(icon: Icons.dashboard, title: 'Dashboard'),
          TabItem(icon: Icons.wallet_rounded, title: 'Wallet'),
          TabItem(icon: Icons.bar_chart, title: 'Summary'),
          TabItem(icon: Icons.notifications_active, title: 'Requests'),
        ],
        initialActiveIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => _mobileView();
}


