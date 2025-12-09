// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:kam_wala_app/After_Scan_View_files/worker_service_requests_tab.dart';
// import 'package:kam_wala_app/Auth/login_screen.dart';
// import 'package:kam_wala_app/Service_Request/product_list.dart';
// import 'package:kam_wala_app/Service_Request/worker_requests_page.dart';

// import 'package:kam_wala_app/beauty%20salon/AdminBookingRequestsPage.dart';
// import 'package:kam_wala_app/beauty%20salon/addpost.dart';
// import 'package:kam_wala_app/beauty%20salon/editdeletesalonservice.dart';
// import 'package:kam_wala_app/beauty%20salon/imagedatafatechsalon.dart';
// import 'package:kam_wala_app/beauty%20salon/salon%20product%20list.dart';
// import 'package:kam_wala_app/beauty%20salon/salon_user_ui.dart';
// import 'package:kam_wala_app/beauty%20salon/salonimagecrud.dart';
// import 'package:kam_wala_app/dashboard/AddPost.dart';
// import 'package:kam_wala_app/dashboard/admin_worker_cnic_approval.dart';
// import 'package:kam_wala_app/dashboard/categories.dart';
// import 'package:kam_wala_app/dashboard/imagecrud.dart';
// import 'package:kam_wala_app/dashboard/imagedatafatech.dart'
//     show FatchAllplumber;
// import 'package:kam_wala_app/feedback/adminrecored.dart';
// import 'package:kam_wala_app/feedback/userfeedbackscreen.dart';
// import 'package:kam_wala_app/feedback/workerfeedbackscreen.dart';
// import 'package:kam_wala_app/image%20crud%20hamdeling/AdminServiceDetailScreen.dart';

// import 'package:kam_wala_app/image%20crud%20hamdeling/Worker%20Dashboard.dart';
// import 'package:kam_wala_app/image%20crud%20hamdeling/Worker%20Detail%20recored%20Screen.dart';
// import 'package:kam_wala_app/image%20crud%20hamdeling/imagedatafatech.dart';
// import 'package:kam_wala_app/image%20crud%20hamdeling/order_details_page.dart';
// import 'package:kam_wala_app/image%20crud%20hamdeling/product_edit_delete.dart';
// import 'package:kam_wala_app/image%20crud%20hamdeling/worker_job_request_screen.dart';
// import 'package:kam_wala_app/image%20crud%20hamdeling/worker_service_requests.dart';

// import 'package:kam_wala_app/screens/sub_category.dart';
// import 'package:kam_wala_app/user/bussinesadminrecoredscreen.dart';
// import 'package:kam_wala_app/user/user_panel.dart';
// import 'package:kam_wala_app/wallet/Wallet%20Screen.dart';
// import 'package:kam_wala_app/wallet/Worker_wallet.dart';
// import 'package:kam_wala_app/worker/WorkerPanel.dart';
// import 'package:kam_wala_app/worker/worker_registration.dart';

// final user = FirebaseAuth.instance.currentUser;
// final currentUserId = user?.uid ?? "";

// final worker = FirebaseAuth.instance.currentUser;
// final workerId = worker?.uid ?? "";

// class Admindrawer extends StatefulWidget {
//   const Admindrawer({super.key});

//   // Fetch worker name & phone from Firestore
//   Future<Map<String, String>> getWorkerDetails(String uid) async {
//     final doc =
//         await FirebaseFirestore.instance.collection('users').doc(uid).get();
//     if (!doc.exists) return {"workerName": "Unknown", "workerPhone": ""};
//     final data = doc.data()!;
//     return {
//       "workerName": data['name'] ?? "Unknown",
//       "workerPhone": data['phone'] ?? "",
//     };
//   }

//   // ✅ Move getWorkerDetails here inside the State class
//   Future<Map<String, String>> getWorkerDetails(String uid) async {
//     final doc =
//         await FirebaseFirestore.instance.collection('users').doc(uid).get();
//     if (!doc.exists) return {"workerName": "Unknown", "workerPhone": ""};
//     final data = doc.data()!;
//     return {
//       "workerName": data['name'] ?? "Unknown",
//       "workerPhone": data['phone'] ?? "",
//     };
//   }

//   @override
//   State<Admindrawer> createState() => _AdmindrawerState();
// }

// class _AdmindrawerState extends State<Admindrawer> {
//   String _adminEmail = "Admin@kaamwala.com";

//   get category => null;

//   @override
//   void initState() {
//     super.initState();
//     getUser();
//   }

//   void getUser() {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       setState(() {
//         _adminEmail = user.email ?? '';
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double drawerWidth =
//         MediaQuery.of(context).size.width * 0.75; // 75% width

//     return Align(
//       alignment: Alignment.centerLeft,
//       child: SizedBox(
//         width: drawerWidth,
//         child: Drawer(
//           elevation: 8,
//           shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.only(
//               topRight: Radius.circular(20),
//               bottomRight: Radius.circular(20),
//             ),
//           ),
//           child: Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Color(0xFFE6F0FA), // Light pastel blue
//                   Color(0xFFFFFFFF), // White
//                 ],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//             child: SafeArea(
//               child: Column(
//                 children: [
//                   // Header
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.symmetric(vertical: 30),
//                     decoration: const BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [Color(0xFFB3D4F2), Color(0xFFFFFFFF)],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Color(0xFF99BBE8),
//                           blurRadius: 8,
//                           offset: Offset(0, 3),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       children: [
//                         const CircleAvatar(
//                           radius: 42,
//                           backgroundImage: AssetImage(
//                             "assets/pic/user profile.jpg",
//                           ),
//                         ),
//                         const SizedBox(height: 6),
//                         const Text(
//                           "Admin",
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 5),
//                         Text(
//                           _adminEmail,
//                           style: const TextStyle(
//                             fontSize: 15,
//                             color: Colors.black54,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 10),

//                   // ✅ Scrollable Drawer Items
//                   Expanded(
//                     child: SingleChildScrollView(
//                       child: Column(
//                         children: [
//                           _buildDrawerItem(
//                             icon: Icons.home,
//                             label: "Service Category Add",
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(builder: (context) => Post()),
//                               );
//                             },
//                           ),
//                           _buildDrawerItem(
//                             icon: Icons.post_add,
//                             label: "Service image Add",
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => DataAdd(),
//                                 ),
//                               );
//                             },
//                           ),
//                           _buildDrawerItem(
//                             icon: Icons.countertops_outlined,
//                             label: "user service request",
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder:
//                                       (context) => AdminServiceDetailScreen(),
//                                 ),
//                               );
//                             },
//                           ),
//                           _buildDrawerItem(
//                             icon: Icons.approval,
//                             label: "worker Aproval details",
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => AdminPanel(),
//                                 ),
//                               );
//                             },
//                           ),
//                           _buildDrawerItem(
//                             icon: Icons.supervised_user_circle_outlined,
//                             label: "Business Recored",
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => AdminRecordedScreen(),
//                                 ),
//                               );
//                             },
//                           ),
//                           _buildDrawerItem(
//                             icon: Icons.feed_outlined,
//                             label: "User Feedback",
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder:
//                                       (context) => AdminFeedbackDashboard(),
//                                 ),
//                               );
//                             },
//                           ),
//                           _buildDrawerItem(
//                             icon: Icons.dashboard_customize,
//                             label: "Salon post add",
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => salonPost(),
//                                 ),
//                               );
//                             },
//                           ),
//                           _buildDrawerItem(
//                             icon: Icons.post_add_rounded,
//                             label: "Salon service add",
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => SalonDataAdd(),
//                                 ),
//                               );
//                             },
//                           ),
//                           _buildDrawerItem(
//                             icon: Icons.sign_language,
//                             label: "Cnic Admin Page",
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => AdminPanel(),
//                                 ),
//                               );
//                             },
//                           ),
//                           _buildDrawerItem(
//                             icon: Icons.wallet,
//                             label: "Worker wallet",
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => WorkerWallet(),
//                                 ),
//                               );
//                             },
//                           ),
//                           _buildDrawerItem(
//                             icon: Icons.polymer_outlined,
//                             label: "Salon Appointment Details",
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder:
//                                       (context) => AdminAppointmentsScreen(),
//                                 ),
//                               );
//                             },
//                           ),
//                           _buildDrawerItem(
//                             icon: Icons.polymer_outlined,
//                             label: "Edit delete Plumbing services",
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => FatchAllplumber(),
//                                 ),
//                               );
//                             },
//                           ),
//                           _buildDrawerItem(
//                             icon: Icons.polymer_outlined,
//                             label: "Edit delete Salons",
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => FatchAllSalon(),
//                                 ),
//                               );
//                             },
//                           ),
//                           _buildDrawerItem(
//                             icon: Icons.work_outline_rounded,
//                             label: "Worker panel",
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => WorkerPanel(),
//                                 ),
//                               );
//                             },
//                           ),
//                           _buildDrawerItem(
//                             icon: Icons.supervised_user_circle_outlined,
//                             label: "User Panel",
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(builder: (_) => UserPanel()),
//                               );
//                             },
//                           ),
//                           _buildDrawerItem(
//                             icon: Icons.supervised_user_circle_outlined,
//                             label: "Worker Accept",
//                             onTap: () async {
//                               final details = await getWorkerDetails(workerId);
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder:
//                                       (_) => WorkerRequestsPagenew(
//                                         workerId: workerId,
//                                         workerName: details['workerName']!,
//                                         workerPhone: details['workerPhone']!,
//                                       ),
//                                 ),
//                               );
//                             },
//                           ),

//                           _buildDrawerItem(
//                             icon: Icons.supervised_user_circle_outlined,
//                             label: "productlist",
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder:
//                                       (_) => ProductListScreennew(
//                                         category:
//                                             category, // make sure category is defined
//                                         currentUserId: currentUserId,
//                                       ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                   // ✅ Logout at bottom (fixed)
//                   _buildDrawerItem(
//                     icon: Icons.logout,
//                     label: "Logout",
//                     iconColor: Colors.redAccent,
//                     labelColor: Colors.black87,
//                     glowing: true,
//                     onTap: () async {
//                       final shouldLogout = await showDialog<bool>(
//                         context: context,
//                         builder:
//                             (context) => AlertDialog(
//                               backgroundColor: Colors.white,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(15),
//                               ),
//                               title: const Text(
//                                 'Confirm Logout',
//                                 style: TextStyle(color: Colors.black87),
//                               ),
//                               content: const Text(
//                                 'Are you sure you want to logout?',
//                                 style: TextStyle(color: Colors.black54),
//                               ),
//                               actions: [
//                                 TextButton(
//                                   onPressed:
//                                       () => Navigator.pop(context, false),
//                                   child: const Text(
//                                     'Cancel',
//                                     style: TextStyle(color: Colors.grey),
//                                   ),
//                                 ),
//                                 TextButton(
//                                   onPressed: () => Navigator.pop(context, true),
//                                   child: const Text(
//                                     'Logout',
//                                     style: TextStyle(color: Colors.redAccent),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                       );

//                       if (shouldLogout == true) {
//                         await FirebaseAuth.instance.signOut();
//                         Navigator.pushAndRemoveUntil(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const LoginScreen1(),
//                           ),
//                           (route) => false,
//                         );
//                       }
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Drawer Item Builder
//   Widget _buildDrawerItem({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//     Color iconColor = const Color.fromARGB(255, 252, 168, 23),
//     Color labelColor = const Color.fromARGB(255, 6, 2, 211),
//     bool glowing = false,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(16),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             gradient:
//                 glowing
//                     ? LinearGradient(
//                       colors: [
//                         Colors.lightBlueAccent.withOpacity(0.3),
//                         Colors.white.withOpacity(0.6),
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     )
//                     : null,
//             color: glowing ? null : const Color(0xFFF4F8FB),
//             boxShadow:
//                 glowing
//                     ? [
//                       BoxShadow(
//                         color: Colors.lightBlueAccent.withOpacity(0.3),
//                         blurRadius: 8,
//                         offset: const Offset(0, 3),
//                       ),
//                     ]
//                     : [],
//           ),
//           child: Row(
//             children: [
//               Icon(icon, color: iconColor, size: 22),
//               const SizedBox(width: 18),
//               Expanded(
//                 child: Text(
//                   label,
//                   style: TextStyle(
//                     color: labelColor,
//                     fontSize: 15,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//               const Icon(
//                 Icons.arrow_forward_ios_rounded,
//                 size: 14,
//                 color: Colors.black26,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kam_wala_app/After_Scan_View_files/worker_service_requests_tab.dart';
import 'package:kam_wala_app/Auth/login_screen.dart';
import 'package:kam_wala_app/Service_Request/adminsumary.dart';
import 'package:kam_wala_app/Service_Request/product_list.dart';
import 'package:kam_wala_app/Service_Request/worker_requests_page.dart';
import 'package:kam_wala_app/beauty%20salon/AdminBookingRequestsPage.dart';
import 'package:kam_wala_app/beauty%20salon/addpost.dart';
import 'package:kam_wala_app/beauty%20salon/editdeletesalonservice.dart';
import 'package:kam_wala_app/beauty%20salon/imagedatafatechsalon.dart';
import 'package:kam_wala_app/beauty%20salon/salon%20product%20list.dart';
import 'package:kam_wala_app/beauty%20salon/salon_user_ui.dart';
import 'package:kam_wala_app/beauty%20salon/salonimagecrud.dart';
import 'package:kam_wala_app/dashboard/AddPost.dart';
import 'package:kam_wala_app/dashboard/admin_worker_cnic_approval.dart';
import 'package:kam_wala_app/dashboard/categories.dart';
import 'package:kam_wala_app/dashboard/imagecrud.dart';
import 'package:kam_wala_app/dashboard/imagedatafatech.dart'
    show FatchAllplumber;
import 'package:kam_wala_app/feedback/adminrecored.dart';
import 'package:kam_wala_app/feedback/userfeedbackscreen.dart';
import 'package:kam_wala_app/feedback/workerfeedbackscreen.dart';
import 'package:kam_wala_app/image%20crud%20hamdeling/AdminServiceDetailScreen.dart';
import 'package:kam_wala_app/image%20crud%20hamdeling/Worker%20Dashboard.dart';
import 'package:kam_wala_app/image%20crud%20hamdeling/Worker%20Detail%20recored%20Screen.dart';
import 'package:kam_wala_app/image%20crud%20hamdeling/imagedatafatech.dart';
import 'package:kam_wala_app/image%20crud%20hamdeling/order_details_page.dart';
import 'package:kam_wala_app/image%20crud%20hamdeling/product_edit_delete.dart';
import 'package:kam_wala_app/image%20crud%20hamdeling/worker_job_request_screen.dart';
import 'package:kam_wala_app/image%20crud%20hamdeling/worker_service_requests.dart';
import 'package:kam_wala_app/screens/sub_category.dart';
import 'package:kam_wala_app/user/bussinesadminrecoredscreen.dart';
import 'package:kam_wala_app/user/user_panel.dart';
import 'package:kam_wala_app/wallet/Wallet%20Screen.dart';
import 'package:kam_wala_app/wallet/Worker_wallet.dart';
import 'package:kam_wala_app/worker/WorkerPanel.dart';
import 'package:kam_wala_app/worker/worker_registration.dart';

final user = FirebaseAuth.instance.currentUser;
final currentUserId = user?.uid ?? "";

final worker = FirebaseAuth.instance.currentUser;
final workerId = worker?.uid ?? "";

class Admindrawer extends StatefulWidget {
  const Admindrawer({super.key});

  @override
  State<Admindrawer> createState() => _AdmindrawerState();
}

class _AdmindrawerState extends State<Admindrawer> {
  String _adminEmail = "Admin@kaamwala.com";

  @override
  void initState() {
    super.initState();
    getUser();
  }

  void getUser() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _adminEmail = user.email ?? '';
      });
    }
  }

  // Fetch worker details
  Future<Map<String, String>> getWorkerDetails(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!doc.exists) return {"workerName": "Unknown", "workerPhone": ""};
    final data = doc.data()!;
    return {
      "workerName": data['name'] ?? "Unknown",
      "workerPhone": data['phone'] ?? "",
    };
  }

  @override
  Widget build(BuildContext context) {
    final double drawerWidth = MediaQuery.of(context).size.width * 0.75;

    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: drawerWidth,
        child: Drawer(
          elevation: 8,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE6F0FA), Color(0xFFFFFFFF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFB3D4F2), Color(0xFFFFFFFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF99BBE8),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 42,
                          backgroundImage: AssetImage(
                            "assets/pic/user profile.jpg",
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Admin",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _adminEmail,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Scrollable Drawer Items
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildDrawerItem(
                            icon: Icons.home,
                            label: "Service Category Add",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Post()),
                              );
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.post_add,
                            label: "Service image Add",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DataAdd(),
                                ),
                              );
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.countertops_outlined,
                            label: "user service request",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => AdminServiceDetailScreen(),
                                ),
                              );
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.approval,
                            label: "worker Aproval details",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdminPanel(),
                                ),
                              );
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.supervised_user_circle_outlined,
                            label: "Business Recored",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AdminRecordedScreen(),
                                ),
                              );
                            },
                          ),

                          _buildDrawerItem(
                            icon: Icons.post_add_rounded,
                            label: "user service Summary",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AdminSummaryPage(),
                                ),
                              );
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.feed_outlined,
                            label: "User Feedback",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => AdminFeedbackDashboard(),
                                ),
                              );
                            },
                          ),

                          _buildDrawerItem(
                            icon: Icons.dashboard_customize,
                            label: "Salon post add",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => salonPost(),
                                ),
                              );
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.post_add_rounded,
                            label: "Salon service add",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SalonDataAdd(),
                                ),
                              );
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.wallet,
                            label: "Worker wallet",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WorkerWallet(),
                                ),
                              );
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.work_outline_rounded,
                            label: "Worker panel",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => WorkerPanel(),
                                ),
                              );
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.supervised_user_circle_outlined,
                            label: "User Panel",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => UserPanel()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Logout Button
                  _buildDrawerItem(
                    icon: Icons.logout,
                    label: "Logout",
                    iconColor: Colors.redAccent,
                    labelColor: Colors.black87,
                    glowing: true,
                    onTap: () async {
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              title: const Text(
                                'Confirm Logout',
                                style: TextStyle(color: Colors.black87),
                              ),
                              content: const Text(
                                'Are you sure you want to logout?',
                                style: TextStyle(color: Colors.black54),
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Logout',
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                ),
                              ],
                            ),
                      );

                      if (shouldLogout == true) {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen1(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Drawer Item Builder
  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = const Color.fromARGB(255, 252, 168, 23),
    Color labelColor = const Color.fromARGB(255, 6, 2, 211),
    bool glowing = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient:
                glowing
                    ? LinearGradient(
                      colors: [
                        Colors.lightBlueAccent.withOpacity(0.3),
                        Colors.white.withOpacity(0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                    : null,
            color: glowing ? null : const Color(0xFFF4F8FB),
            boxShadow:
                glowing
                    ? [
                      BoxShadow(
                        color: Colors.lightBlueAccent.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                    : [],
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.black26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
