import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kam_wala_app/Admin/AdminApplicationsTab.dart';
import 'package:kam_wala_app/Admin/AdminElectricianRequestsTab.dart';
import 'package:kam_wala_app/Admin/AdminJobsTab.dart';
import 'package:kam_wala_app/Admin/AdminSettingsTab.dart';
import 'package:kam_wala_app/Admin/admin_users_tab.dart';
import 'package:kam_wala_app/After_Scan_View_files/AdminServiceRequestsTab.dart';
import 'package:kam_wala_app/After_Scan_View_files/plumber_detail_screen.dart';
import 'package:kam_wala_app/Auth/login_screen.dart';
import 'package:kam_wala_app/user/BuyToolsScreen.dart';
import 'package:kam_wala_app/user/user_panel.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:kam_wala_app/worker/WorkerPanel.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  int _selectedIndex = 0;
  String _selectedRole = 'Admin';

  final List<String> _roles = [
    'Admin',
    'Worker',
    'User',
    'Electrician',
    'Plumber',
    'Book Items',
  ];

  final List<Widget> _pages = [
    AdminUsersTab(),
    AdminServiceRequestsTab(),
    AdminJobsTab(),
    AdminApplicationsTab(),
    AdminSettingsTab(),
  ];

  final List<String> _titles = [
    'Users',
    'Service',
    'Jobs',
    'Applications',
    'Settings',
  ];

  @override
  void initState() {
    super.initState();
    _selectedRole = 'Admin';
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateWithAnimation(Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _handleRoleChange(String? newValue) {
    if (newValue != null) {
      final uid = FirebaseAuth.instance.currentUser?.uid;

      if (newValue == 'User' && uid != null) {
        _navigateWithAnimation(const UserPanel());
      } else if (newValue == 'Worker' && uid != null) {
        _navigateWithAnimation(WorkerPanel());
      } else if (newValue == 'Electrician') {
        _navigateWithAnimation(const AdminElectricianRequestsTab());
      } else if (newValue == 'Plumber') {
        _navigateWithAnimation(const PlumberDetailScreen());
      } else if (newValue == 'Book Items') {
        _navigateWithAnimation(BuyToolsScreen());
      } else if (newValue == 'Admin') {
        setState(() => _selectedRole = newValue);
      }
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen1()),
        (route) => false,
      );
    }
  }

  Widget _buildMobileView() {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              _titles[_selectedIndex],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            DropdownButton<String>(
              value: _selectedRole,
              dropdownColor: Colors.blueGrey[900],
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              underline: const SizedBox(),
              onChanged: _handleRoleChange,
              items:
                  _roles.map((role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(
                        role,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: Colors.black,
        activeColor: Colors.lightBlueAccent,
        style: TabStyle.react,
        items: const [
          TabItem(icon: Icons.people, title: 'Users'),
          TabItem(icon: Icons.verified_user, title: 'User Service'),
          TabItem(icon: Icons.assignment, title: 'Jobs'),
          TabItem(icon: Icons.receipt_long, title: 'Apps'),
          TabItem(icon: Icons.settings, title: 'Settings'),
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
                icon: Icon(Icons.people),
                label: Text('Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.verified_user_outlined),
                label: Text('user'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.assignment),
                label: Text('Jobs'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.receipt_long),
                label: Text('Apps'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            labelType: NavigationRailLabelType.all,
            leading: Column(
              children: [
                const SizedBox(height: 16),
                const Icon(Icons.admin_panel_settings, color: Colors.white),
                const SizedBox(height: 16),
                DropdownButton<String>(
                  value: _selectedRole,
                  dropdownColor: Colors.blueGrey[900],
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  underline: const SizedBox(),
                  onChanged: _handleRoleChange,
                  items:
                      _roles.map((role) {
                        return DropdownMenuItem<String>(
                          value: role,
                          child: Text(
                            role,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
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
