// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:kam_wala_app/Service_Request/product_list.dart';
// import 'package:shimmer/shimmer.dart';

// class WorkerRequestsPagenew extends StatefulWidget {
//   final String workerId;
//   final String workerName;
//   final String workerPhone;

//   const WorkerRequestsPagenew({
//     super.key,
//     required this.workerId,
//     required this.workerName,
//     required this.workerPhone,
//   });

//   @override
//   State<WorkerRequestsPagenew> createState() => _WorkerRequestsPagenewState();
// }

// class _WorkerRequestsPagenewState extends State<WorkerRequestsPagenew> {
//   Future<void> _refresh() async {
//     await Future.delayed(const Duration(milliseconds: 800));
//     setState(() {}); // rebuild UI to get fresh data
//   }

//   void _showModernSnackBar(
//     BuildContext context, {
//     required String message,
//     required Color color,
//     required IconData icon,
//   }) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(icon, color: Colors.white, size: 26),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 message,
//                 style: const TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: color,
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(14),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//         duration: const Duration(seconds: 3),
//         elevation: 10,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final whiteBlueGradient = const LinearGradient(
//       colors: [Colors.white, Colors.blueAccent],
//       begin: Alignment.topLeft,
//       end: Alignment.bottomRight,
//     );

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: const Text(
//           "Pending Requests",
//           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
//         ),
//         centerTitle: true,
//         elevation: 3,
//         actions: [
//           StreamBuilder<QuerySnapshot>(
//             stream:
//                   FirebaseFirestore.instance
//                       .collection('requests')
//                     .where('status', isEqualTo: 'pending')
//                     .where('nearbyWorkers', arrayContains: widget.workerId)
//                     .snapshots(),
//             builder: (context, snapshot) {
//               final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
//               return Stack(
//                 children: [
//                   IconButton(
//                     icon: const Icon(
//                       Icons.notifications_none,
//                       size: 28,
//                       color: Colors.blue,
//                     ),
//                     onPressed: () {
//                       _showModernSnackBar(
//                         context,
//                         message:
//                             count > 0
//                                 ? "You have $count pending requests"
//                                 : "No new notifications",
//                         color: Colors.blue.shade700,
//                         icon: Icons.notifications,
//                       );
//                     },
//                   ),
//                   if (count > 0)
//                     Positioned(
//                       right: 10,
//                       top: 10,
//                       child: Container(
//                         padding: const EdgeInsets.all(5),
//                         decoration: const BoxDecoration(
//                           color: Colors.red,
//                           shape: BoxShape.circle,
//                         ),
//                         child: Text(
//                           count.toString(),
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 10,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               );
//             },
//           ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: _refresh,
//         child: StreamBuilder<QuerySnapshot>(
//           stream:
//               FirebaseFirestore.instance
//                   .collection('requests')
//                   .where('status', isEqualTo: 'pending')
//                   .where('nearbyWorkers', arrayContains: widget.workerId)
//                   .snapshots(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               // Shimmer loading
//               return ListView.builder(
//                 itemCount: 5,
//                 itemBuilder:
//                     (context, index) => Shimmer.fromColors(
//                       baseColor: Colors.grey.shade300,
//                       highlightColor: Colors.grey.shade100,
//                       child: Card(
//                         margin: const EdgeInsets.all(12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         child: const ListTile(
//                           leading: CircleAvatar(backgroundColor: Colors.grey),
//                           title: SizedBox(height: 10, width: 80),
//                           subtitle: SizedBox(height: 10, width: 40),
//                         ),
//                       ),
//                     ),
//               );
//             }

//             if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(
//                       Icons.hourglass_empty,
//                       size: 100,
//                       color: Colors.blueAccent,
//                     ),
//                     const SizedBox(height: 16),
//                     const Text(
//                       "No Pending Requests",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.blueGrey,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }

//             final requests = snapshot.data!.docs;

//             return ListView.builder(
//               itemCount: requests.length,
//               itemBuilder: (context, index) {
//                 final doc = requests[index];
//                 final data = doc.data() as Map<String, dynamic>;

//                 return GestureDetector(
//                   onTap:
//                       () => _showModernSnackBar(
//                         context,
//                         message: "Service: ${data['serviceName'] ?? 'Unknown'}",
//                         color: Colors.blueAccent,
//                         icon: Icons.info,
//                       ),
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 400),
//                     margin: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 8,
//                     ),
//                     decoration: BoxDecoration(
//                       gradient: whiteBlueGradient,
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black26,
//                           blurRadius: 8,
//                           offset: const Offset(2, 4),
//                         ),
//                       ],
//                     ),
//                     child: ListTile(
//                       leading: const CircleAvatar(
//                         backgroundColor: Colors.blue,
//                         child: Icon(Icons.work, color: Colors.white),
//                       ),
//                       title: Text(
//                         data['serviceName'] ?? "Unknown Service",
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blue,
//                         ),
//                       ),
//                       subtitle: Text(
//                         "Charges: Rs. ${data['charges'] ?? 0}",
//                         style: const TextStyle(color: Colors.black87),
//                       ),
//                       trailing: PopupMenuButton<String>(
//                         color: Colors.white,
//                         icon: const Icon(
//                           Icons.more_vert,
//                           color: Color.fromARGB(255, 10, 10, 10),
//                         ),
//                         onSelected: (value) async {
//                           if (value != 'Reject') {
//                             try {
//                               await ProductPage.workerAcceptRequest(
//                                 requestId: doc.id,
//                                 workerId: widget.workerId,
//                                 workerName: widget.workerName,
//                                 workerPhone: widget.workerPhone,
//                                 eta: value,
//                               );

//                               _showModernSnackBar(
//                                 context,
//                                 message: "Request accepted (ETA: $value)",
//                                 color: Colors.green.shade600,
//                                 icon: Icons.check_circle,
//                               );
//                             } catch (e) {
//                               _showModernSnackBar(
//                                 context,
//                                 message: "Error: ${e.toString()}",
//                                 color: Colors.red.shade600,
//                                 icon: Icons.error,
//                               );
//                             }
//                           } else {
//                             await doc.reference.update({"status": "rejected"});
//                             _showModernSnackBar(
//                               context,
//                               message: "Request Rejected",
//                               color: Colors.orange.shade700,
//                               icon: Icons.close,
//                             );
//                           }
//                         },
//                         itemBuilder:
//                             (_) => const [
//                               PopupMenuItem(
//                                 value: "15 min",
//                                 child: Text("15 min ETA"),
//                               ),
//                               PopupMenuItem(
//                                 value: "30 min",
//                                 child: Text("30 min ETA"),
//                               ),
//                               PopupMenuItem(
//                                 value: "1 hr",
//                                 child: Text("1 hr ETA"),
//                               ),
//                               PopupMenuItem(
//                                 value: "Reject",
//                                 child: Text("Reject"),
//                               ),
//                             ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kam_wala_app/Service_Request/product_list.dart';
import 'package:kam_wala_app/image%20crud%20hamdeling/worker_tracking_page.dart';
import 'package:shimmer/shimmer.dart';

class WorkerRequestsPagenew extends StatefulWidget {
  final String workerId;
  final String workerName;
  final String workerPhone;

  const WorkerRequestsPagenew({
    super.key,
    required this.workerId,
    required this.workerName,
    required this.workerPhone,
  });

  @override
  State<WorkerRequestsPagenew> createState() => _WorkerRequestsPagenewState();
}

class _WorkerRequestsPagenewState extends State<WorkerRequestsPagenew> {
  // ----------------------------
  // REFRESH FUNCTION
  // ----------------------------
  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 700));
    setState(() {});
  }

  // ----------------------------
  // MODERN SNACKBAR
  // ----------------------------
  void _showModernSnackBar(
    BuildContext context, {
    required String message,
    required Color color,
    required IconData icon,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        duration: const Duration(seconds: 3),
        elevation: 8,
      ),
    );
  }

  // ----------------------------
  // AUTO-LISTENER FOR TRACKING NAVIGATION
  // ----------------------------
  void _startRequestListener(String requestId) {
    FirebaseFirestore.instance
        .collection("requests")
        .doc(requestId)
        .snapshots()
        .listen((docSnap) {
      if (!docSnap.exists) return;

      final data = docSnap.data()!;
      final status = data["status"];

      if (status == "accepted") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => WorkerTrackingPage(
              // requestId: requestId,
              workerId: widget.workerId,
              workerName: widget.workerName,
              workerPhone: widget.workerPhone,
              eta: data["eta"],
              serviceName: data["serviceName"],
              charges: data["charges"],
            ),
          ),
        );
      }
    });
  }

  // ----------------------------
  // UI START
  // ----------------------------
  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
      colors: [Colors.white, Colors.blueAccent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Pending Requests",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        centerTitle: true,
        elevation: 3,
      ),

      // ----------------------------
      // MAIN STREAM LISTENER
      // ----------------------------
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('requests')
              .where('status', isEqualTo: 'pending')
              .where('nearbyWorkers', arrayContains: widget.workerId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) => Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Card(
                    margin: const EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const ListTile(
                      leading: CircleAvatar(backgroundColor: Colors.grey),
                      title: SizedBox(height: 10, width: 80),
                      subtitle: SizedBox(height: 10, width: 40),
                    ),
                  ),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.hourglass_empty, size: 100, color: Colors.blueAccent),
                    SizedBox(height: 14),
                    Text(
                      "No Pending Requests",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey,
                      ),
                    )
                  ],
                ),
              );
            }

            final requests = snapshot.data!.docs;

            return ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final doc = requests[index];
                final data = doc.data() as Map<String, dynamic>;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 7,
                        offset: Offset(2, 4),
                      )
                    ],
                  ),

                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.work, color: Colors.white),
                    ),

                    title: Text(
                      data['serviceName'] ?? "Unknown Service",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),

                    subtitle: Text(
                      "Rs. ${data['charges']}",
                      style: const TextStyle(color: Colors.black87),
                    ),

                    trailing: PopupMenuButton<String>(
                      color: Colors.white,
                      onSelected: (value) async {
                        if (value == "Reject") {
                          await doc.reference.update({"status": "rejected"});
                          _showModernSnackBar(
                            context,
                            message: "Request Rejected",
                            color: Colors.orange.shade700,
                            icon: Icons.close,
                          );
                          return;
                        }

                        // Worker Accept
                        // await ProductPage.workerAcceptRequest(
                        //   requestId: doc.id,
                        //   workerId: widget.workerId,
                        //   workerName: widget.workerName,
                        //   workerPhone: widget.workerPhone,
                        //   eta: value,
                        // );

                        _showModernSnackBar(
                          context,
                          message: "Accepted (ETA: $value)",
                          color: Colors.green.shade600,
                          icon: Icons.check_circle,
                        );

                        _startRequestListener(doc.id);
                      },

                      itemBuilder: (_) => const [
                        PopupMenuItem(value: "15 min", child: Text("15 min ETA")),
                        PopupMenuItem(value: "30 min", child: Text("30 min ETA")),
                        PopupMenuItem(value: "1 hr", child: Text("1 hr ETA")),
                        PopupMenuItem(value: "Reject", child: Text("Reject")),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
