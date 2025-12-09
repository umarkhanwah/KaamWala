import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kam_wala_app/Auth/login_screen.dart';
import 'package:kam_wala_app/screens/sub_category.dart';
import 'package:kam_wala_app/beauty salon/salon_user_ui.dart';
import 'package:kam_wala_app/wallet/Worker_wallet.dart';
import 'package:kam_wala_app/feedback/userfeedbackscreen.dart';

class UserPanel extends StatefulWidget {
  const UserPanel({super.key});

  @override
  State<UserPanel> createState() => _UserPanelState();
}

class _UserPanelState extends State<UserPanel> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _tabs = [
    SubCategoryLongScreen(),
    WelcomeScreenuser(),
    WorkerWallet(),
    UserFeedbackScreen(userId: "user123"),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen1()),
    );
  }

  Widget _buildDrawer() {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.black87,
            ),
            accountName: Text(
              user?.displayName ?? "Demo User",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(user?.email ?? "user@email.com"),
            currentAccountPicture: const CircleAvatar(
              backgroundImage: AssetImage("assets/demo_user.png"), // demo pic
            ),
            otherAccountsPictures: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  // profile edit page
                },
              ),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.switch_account),
            title: const Text("Switch to Worker"),
            onTap: () {
              // switch worker logic
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Edit Profile"),
            onTap: () {
              // edit profile
            },
          ),
          ListTile(
            leading: const Icon(Icons.article),
            title: const Text("Terms & Conditions"),
            onTap: () {
              // T&C screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileView() {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          _tabs[_selectedIndex],
          Positioned(
            top: 40,
            left: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.black87,
              child: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: Colors.black,
        activeColor: Colors.lightBlueAccent,
        style: TabStyle.react,
        items: const [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.design_services, title: 'Service'),
          TabItem(icon: Icons.wallet, title: 'Wallet'),
          TabItem(icon: Icons.feedback_rounded, title: 'Feedback'),
        ],
        initialActiveIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildTabletView() {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            backgroundColor: Colors.black87,
            onDestinationSelected: _onItemTapped,
            selectedIconTheme: const IconThemeData(color: Colors.lightBlueAccent),
            unselectedIconTheme: const IconThemeData(color: Colors.white70),
            selectedLabelTextStyle: const TextStyle(color: Colors.lightBlueAccent),
            unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.work),
                label: Text('Services'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.wallet),
                label: Text('Wallet'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.feedback),
                label: Text('Feedback'),
              ),
            ],
          ),
          Expanded(
            child: Stack(
              children: [
                _tabs[_selectedIndex],
                Positioned(
                  top: 40,
                  left: 16,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.black87,
                    child: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                ),
              ],
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
