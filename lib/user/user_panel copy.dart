import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kam_wala_app/After_Scan_View_files/plumber_detail_screen.dart';
import 'package:kam_wala_app/Auth/login_screen.dart';
import 'package:kam_wala_app/beauty%20salon/salon_user_ui.dart';
import 'package:kam_wala_app/feedback/userfeedbackscreen.dart';
import 'package:kam_wala_app/image%20crud%20hamdeling/imagedatafatech.dart';

import 'package:kam_wala_app/screens/sub_category.dart';

import 'package:kam_wala_app/user/UserJobsTab.dart';
import 'package:kam_wala_app/user/UserProfileTab.dart';

import 'package:kam_wala_app/wallet/Worker_wallet.dart';

class UserPanel extends StatefulWidget {
  const UserPanel({super.key});

  @override
  State<UserPanel> createState() => _UserPanelState();
}

class _UserPanelState extends State<UserPanel> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    SubCategoryLongScreen(),
    WelcomeScreenuser(),
    //QRScannerScreen(),
    // PlumberDetailScreen(),
    WorkerWallet(),
    UserFeedbackScreen(userId: "user123"),
    //UserProfileSetupScreen(),
  ];

  final List<String> _titles = [
    'Home',
    'Services',
    'wallet',
    'Feedback',
    // 'Profile',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() {
    FirebaseAuth.instance.signOut();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen1()),
    );
  }

  Widget _buildMobileView() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen1()),
              );
            },
          ),
        ],
      ),
      body: _tabs[_selectedIndex],
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: Colors.black,
        activeColor:
            Colors.lightBlueAccent, // changed from yellow to blueAccent
        style: TabStyle.react,
        items: const [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.design_services, title: 'Service'),
          TabItem(icon: Icons.wallet, title: 'wallet'),
          TabItem(icon: Icons.feedback_rounded, title: 'Feedback'),
          //TabItem(icon: Icons.person, title: 'Profile'),
        ],
        initialActiveIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildTabletView() {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            backgroundColor: Colors.blueGrey[900], // changed from grey[900]
            onDestinationSelected: _onItemTapped,
            selectedIconTheme: const IconThemeData(
              color: Colors.blueAccent,
            ), // blueAccent
            unselectedIconTheme: const IconThemeData(color: Colors.white),
            selectedLabelTextStyle: const TextStyle(color: Colors.blueAccent),
            unselectedLabelTextStyle: const TextStyle(color: Colors.white),
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.work),
                label: Text('services'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.qr_code_scanner),
                label: Text('wallet'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.plumbing),
                label: Text('feedback'),
              ),
              // NavigationRailDestination(
              //   icon: Icon(Icons.person),
              //   label: Text('Profile'),
              // ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  _titles[_selectedIndex],
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.black,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: _logout,
                  ),
                ],
              ),
              body: _tabs[_selectedIndex],
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
          return _buildTabletView();
        }
      },
    );
  }
}
