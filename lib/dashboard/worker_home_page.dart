import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kam_wala_app/image%20crud%20hamdeling/Worker%20Detail%20recored%20Screen.dart';
import 'package:kam_wala_app/screens/Worker%20Request%20Page.dart';
import 'package:kam_wala_app/worker/WorkerPanel.dart';
import 'token_service.dart';

class WorkerHomePage extends StatelessWidget {
  final String workerId;
  const WorkerHomePage({super.key, required this.workerId});

  @override
  Widget build(BuildContext context) {
    // Worker token save for push notifications
    TokenService.saveWorkerToken(workerId);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("👷 Worker Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection("workers")
                .doc(workerId)
                .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || !snap.data!.exists) {
            return const Center(child: Text("No worker data found."));
          }

          final data = snap.data!.data() as Map<String, dynamic>;
          final status = data['status'] ?? "Pending";

          /// 🔥 Auto quick response SnackBar
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (status == "Approved") {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("✅ Your request has been approved!"),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            } else if (status == "Rejected") {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("❌ Your request has been rejected."),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          });

          Widget content;
          if (status == "Approved") {
            content = _statusCard(
              icon: Icons.verified,
              iconColor: Colors.green,
              title: "Approved!",
              message: "✅ You can now accept jobs.",
              buttonLabel: "Go to Jobs",
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            //WorkerRecordDetailScreen(workerId: workerId),
                            // WorkerRequestsPage(workerId: workerId, workerName: workerName, workerPhone: workerPhone),
                            WorkerPanel(),
                  ),
                );
              },
            );
          } else if (status == "Rejected") {
            content = _statusCard(
              icon: Icons.cancel,
              iconColor: Colors.red,
              title: "Application Rejected",
              message: "❌ Please contact support for details.",
            );
          } else {
            content = _statusCard(
              icon: Icons.hourglass_top,
              iconColor: Colors.orange,
              title: "Waiting for Approval",
              message: "⏳ Please wait while admin reviews your application.",
            );
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: content,
          );
        },
      ),
    );
  }

  Widget _statusCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    String? buttonLabel,
    VoidCallback? onPressed,
  }) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 60),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              if (buttonLabel != null && onPressed != null) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: iconColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: onPressed,
                  child: Text(buttonLabel),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'token_service.dart';

// class WorkerHomePage extends StatelessWidget {
//   final String workerId;
//   const WorkerHomePage({super.key, required this.workerId});

//   @override
//   Widget build(BuildContext context) {
//     // Save worker token for push notifications
//     TokenService.saveWorkerToken(workerId);

//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: const Text("👷 Worker Dashboard"),
//         centerTitle: true,
//         backgroundColor: Colors.blueAccent,
//         elevation: 4,
//       ),
//       body: StreamBuilder<DocumentSnapshot>(
//         stream:
//             FirebaseFirestore.instance
//                 .collection("workers")
//                 .doc(workerId)
//                 .snapshots(),
//         builder: (context, snap) {
//           if (snap.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snap.hasData || !snap.data!.exists) {
//             return const Center(child: Text("No worker data found."));
//           }

//           final data = snap.data!.data() as Map<String, dynamic>;
//           final approved = data['approved'] == true;
//           final rejected = data['rejected'] == true;

//           Widget content;

//           if (approved) {
//             content = _statusCard(
//               icon: Icons.verified,
//               iconColor: Colors.green,
//               title: "Approved!",
//               message: "✅ You can now accept jobs.",
//               buttonLabel: "Go to Jobs",
//               onPressed: () {
//                 // navigate to jobs list
//               },
//             );
//           } else if (rejected) {
//             content = _statusCard(
//               icon: Icons.cancel,
//               iconColor: Colors.red,
//               title: "Application Rejected",
//               message: "❌ Please contact support for details.",
//             );
//           } else {
//             content = _statusCard(
//               icon: Icons.hourglass_top,
//               iconColor: Colors.orange,
//               title: "Waiting for Approval",
//               message: "⏳ Please wait while admin reviews your application.",
//             );
//           }

//           return AnimatedSwitcher(
//             duration: const Duration(milliseconds: 500),
//             child: content,
//           );
//         },
//       ),
//     );
//   }

//   Widget _statusCard({
//     required IconData icon,
//     required Color iconColor,
//     required String title,
//     required String message,
//     String? buttonLabel,
//     VoidCallback? onPressed,
//   }) {
//     return Center(
//       child: Card(
//         margin: const EdgeInsets.all(20),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         elevation: 6,
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(icon, color: iconColor, size: 60),
//               const SizedBox(height: 16),
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 message,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 16, color: Colors.grey[700]),
//               ),
//               if (buttonLabel != null && onPressed != null) ...[
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: iconColor,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   onPressed: onPressed,
//                   child: Text(buttonLabel),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
