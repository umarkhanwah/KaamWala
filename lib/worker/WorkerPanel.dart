import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:kam_wala_app/Admin/AdminElectricianRequestsTab.dart';
import 'package:kam_wala_app/After_Scan_View_files/plumber_detail_screen.dart';
import 'package:kam_wala_app/Service_Request/worker_requests_page.dart';
import 'package:kam_wala_app/Service_Request/workersumarypage.dart';
import 'package:kam_wala_app/feedback/workerfeedbackscreen.dart';
import 'package:kam_wala_app/Auth/login_screen.dart';
import 'package:kam_wala_app/image crud hamdeling/worker_job_request_screen.dart';
import 'package:kam_wala_app/user/user_panel.dart';
import 'package:kam_wala_app/wallet/Worker_wallet.dart';
import 'package:kam_wala_app/worker/WorkerProfileTab.dart';
import 'package:kam_wala_app/worker/worker_registration.dart';

// ✅ Import Worker Summary Page

class WorkerPanel extends StatefulWidget {
  const WorkerPanel({super.key});

  @override
  State<WorkerPanel> createState() => _WorkerPanelState();
}

class _WorkerPanelState extends State<WorkerPanel> {
  int _selectedIndex = 0;
  String _selectedRole = 'Worker';

  late String workerId;
  late String workerName;
  late String workerPhone;

  final List<String> _roles = ['Worker', 'User'];
  final List<String> _titles = [
    'Verification',
    'Requests',
    'Summary', // ✅ New Tab Title
    'Wallet',
    'Feedback',
    //  'Profile',
  ];

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      workerId = currentUser.uid;
      workerName = currentUser.displayName ?? "Worker";
      workerPhone = currentUser.phoneNumber ?? "Unknown";
    } else {
      workerId = "unknown";
      workerName = "Unknown";
      workerPhone = "Unknown";
    }
  }

  // ✅ Pages me worker info pass
  List<Widget> get _pages {
    return [
      const WorkerRegistrationPage(),
      WorkerRequestsPagenew(
        workerId: workerId,
        workerName: workerName,
        workerPhone: workerPhone,
      ),
      WorkerSummaryPage(
        // ✅ Summary Page Added
        workerId: workerId,
        workerName: workerName,
        workerPhone: workerPhone,
      ),
      WorkerWallet(),
      WorkerFeedbackScreen(workerId: workerId),
      //const WorkerProfileTab(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
void _logout() async {
  try {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // 🔹 Remove FCM token from Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'fcmToken': FieldValue.delete(),
        'updatedAt': DateTime.now(),
      });

      // 🔹 Delete token locally on device (so this device stops receiving notifications)
      await FirebaseMessaging.instance.deleteToken();
    }

    // 🔹 Sign out from Firebase Auth
    await FirebaseAuth.instance.signOut();

    // 🔹 Navigate to login screen and remove all previous routes
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen1()),
      (route) => false,
    );
  } catch (e) {
    // 🔹 Optional: show error if logout failed
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Logout failed: $e")),
    );
  }
}


  void _navigateWithFade(Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(opacity: anim, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _handleRoleChange(String? newValue) {
    if (newValue == null || newValue == _selectedRole) return;

    setState(() => _selectedRole = newValue);

    if (newValue == 'Electrician') {
      _navigateWithFade(AdminElectricianRequestsTab());
    } else if (newValue == 'Plumber') {
      _navigateWithFade(PlumberDetailScreen());
    } else if (newValue == 'User') {
      _navigateWithFade(UserPanel());
    }
  }
Widget _workerHeader() {
  return Container(
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: const LinearGradient(
        colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Row(
      children: [
        const CircleAvatar(
          radius: 32,
          backgroundColor: Colors.white,
          child: Icon(Icons.person, size: 36, color: Colors.blue),
        ),
        const SizedBox(width: 16),
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
                workerPhone,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 6),
              Chip(
                label: const Text("Worker"),
                backgroundColor: Colors.greenAccent,
                labelStyle: const TextStyle(color: Colors.black),
              )
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.account_balance_wallet, color: Colors.white),
          onPressed: () {
            _onItemTapped(3); // wallet tab
          },
        )
      ],
    ),
  );
}
Widget _buildMobileView() {
  return Scaffold(
    backgroundColor: const Color(0xFFF4F6FA),
    appBar: AppBar(
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF1E3C72)],
          ),
        ),
      ),
      title: Text(
        _titles[_selectedIndex],
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: DropdownButton<String>(
            value: _selectedRole,
            dropdownColor: Colors.black,
            icon: const Icon(Icons.swap_horiz, color: Colors.white),
            underline: const SizedBox(),
            onChanged: _handleRoleChange,
            items: _roles
                .map(
                  (role) => DropdownMenuItem(
                    value: role,
                    child: Text(role, style: const TextStyle(color: Colors.white)),
                  ),
                )
                .toList(),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: _logout,
        ),
      ],
    ),
    body: Column(
      children: [
        _workerHeader(), // ⭐ NEW HEADER
        Expanded(child: _pages[_selectedIndex]),
      ],
    ),
    bottomNavigationBar: ConvexAppBar(
      backgroundColor: Colors.black,
      activeColor: Colors.blueAccent,
      elevation: 8,
      style: TabStyle.reactCircle,
      items: const [
        TabItem(icon: Icons.verified_user, title: 'Verify'),
        TabItem(icon: Icons.notifications_active, title: 'Requests'),
        TabItem(icon: Icons.bar_chart, title: 'Summary'),
        TabItem(icon: Icons.account_balance_wallet, title: 'Wallet'),
        TabItem(icon: Icons.feedback, title: 'Feedback'),
      ],
      initialActiveIndex: _selectedIndex,
      onTap: _onItemTapped,
    ),
  );
}

  Widget _buildTabletDesktopView() {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: Colors.blueGrey[900],
            selectedIconTheme: const IconThemeData(color: Colors.blueAccent),
            unselectedIconTheme: const IconThemeData(color: Colors.white),
            selectedLabelTextStyle: const TextStyle(color: Colors.blueAccent),
            unselectedLabelTextStyle: const TextStyle(color: Colors.white),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.work),
                label: Text('Verification'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.notifications),
                label: Text('Requests'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.summarize),
                label: Text('Summary'), // ✅ New Tab
              ),
              NavigationRailDestination(
                icon: Icon(Icons.assignment),
                label: Text('Wallet'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.feedback_rounded),
                label: Text('Feedback'),
              ),
              // NavigationRailDestination(
              //   icon: Icon(Icons.person),
              //   label: Text('Profile'),
              // ),
            ],
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            labelType: NavigationRailLabelType.all,
            leading: Column(
              children: [
                const SizedBox(height: 16),
                const Icon(Icons.person_pin, color: Colors.white),
                const SizedBox(height: 16),
                DropdownButton<String>(
                  value: _selectedRole,
                  dropdownColor: Colors.blueGrey[800],
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  underline: const SizedBox(),
                  onChanged: _handleRoleChange,
                  items:
                      _roles
                          .map(
                            (role) => DropdownMenuItem<String>(
                              value: role,
                              child: Text(
                                role,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.black,
                title: Text(
                  '${_titles[_selectedIndex]} ($_selectedRole)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: _logout,
                  ),
                ],
              ),
              body: _pages[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          return _buildMobileView();
        } else {
          return _buildTabletDesktopView();
        }
      },
    );
  }
}
