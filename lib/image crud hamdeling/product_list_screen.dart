// import 'dart:convert';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:kam_wala_app/image%20crud%20hamdeling/product_model.dart';
// import 'package:kam_wala_app/image%20crud%20hamdeling/worker_tracking_page.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'dart:math';

// class ProductListScreen extends StatelessWidget {
//   final String category;
//   const ProductListScreen({super.key, required this.category});

//   Future<List<ProductModel>> fetchProductsByCategory() async {
//     final snapshot =
//         await FirebaseFirestore.instance
//             .collection('products')
//             .where('Category', isEqualTo: category)
//             .get();

//     return snapshot.docs
//         .map((doc) => ProductModel.fromFirestore(doc.data(), doc.id))
//         .toList();
//   }

//   Future<List<Map<String, dynamic>>> fetchWorkers() async {
//     final snapshot =
//         await FirebaseFirestore.instance
//             .collection("users")
//             .where("role", isEqualTo: "worker")
//             .get();
//     return snapshot.docs.map((doc) => doc.data()).toList();
//   }

//   void _showRadarAnimation(BuildContext context, ProductModel product) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) {
//         return Center(
//           child: SizedBox(
//             width: 220,
//             height: 220,
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 // Multiple animated circles
//                 ...List.generate(3, (i) {
//                   return AnimatedContainer(
//                     duration: Duration(seconds: 2 + i),
//                     curve: Curves.easeInOutCubic,
//                     width: 220 - (i * 60).toDouble(),
//                     height: 220 - (i * 60).toDouble(),
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       gradient: RadialGradient(
//                         colors: [
//                           Colors.cyanAccent.withOpacity(0.25),
//                           Colors.teal.withOpacity(0.05),
//                         ],
//                         stops: const [0.2, 1],
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.cyanAccent.withOpacity(0.3),
//                           blurRadius: 20,
//                           spreadRadius: 5,
//                         ),
//                       ],
//                     ),
//                   );
//                 }),

//                 // Glowing radar icon
//                 Container(
//                   padding: const EdgeInsets.all(15),
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     gradient: LinearGradient(
//                       colors: [
//                         Colors.cyanAccent.withOpacity(0.8),
//                         Colors.tealAccent.withOpacity(0.6),
//                       ],
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.cyanAccent.withOpacity(0.6),
//                         blurRadius: 25,
//                         spreadRadius: 3,
//                       ),
//                     ],
//                   ),
//                   child: const Icon(Icons.radar, size: 70, color: Colors.black),
//                 ),

//                 // Pulsing glow effect
//                 Positioned.fill(
//                   child: TweenAnimationBuilder<double>(
//                     tween: Tween(begin: 0.9, end: 1.1),
//                     duration: const Duration(seconds: 1),
//                     curve: Curves.easeInOut,
//                     builder: (context, value, child) {
//                       return Transform.scale(
//                         scale: value,
//                         child: Container(
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             border: Border.all(
//                               color: Colors.cyanAccent.withOpacity(0.3),
//                               width: 2,
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                     onEnd: () {},
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );

//     Future.delayed(const Duration(seconds: 2), () {
//       Navigator.pop(context);
//       _showWorkerDetails(context, product);
//     });
//   }

//   void _showWorkerDetails(BuildContext context, ProductModel product) async {
//     List<Map<String, dynamic>> workers = await fetchWorkers();

//     if (workers.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("No workers available right now")),
//       );
//       return;
//     }

//     Map<String, dynamic> randomWorker =
//         workers[Random().nextInt(workers.length)];

//     String selectedETA = "15 min";
//     String workerId = randomWorker["uid"] ?? "WRK-${Random().nextInt(9999)}";
//     String workerName = randomWorker["name"] ?? "Unnamed Worker";
//     String workerPhone = randomWorker["phone"] ?? "03001234567";

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: const Color.fromARGB(255, 140, 212, 245),
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//       ),
//       builder: (context) {
//         return StatefulBuilder(
//           builder:
//               (context, setState) => Padding(
//                 padding: const EdgeInsets.all(22),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       height: 5,
//                       width: 60,
//                       margin: const EdgeInsets.only(bottom: 15),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[300],
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                     ),
//                     Text(
//                       "Worker Found ✅",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 20,
//                         color: Colors.blue.shade700,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     CircleAvatar(
//                       radius: 35,
//                       backgroundColor: Colors.blue.shade100,
//                       child: Text(
//                         workerName[0].toUpperCase(),
//                         style: const TextStyle(
//                           fontSize: 28,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Text(
//                       "Name: $workerName",
//                       style: const TextStyle(fontSize: 16),
//                     ),
//                     Text("Worker ID: $workerId"),

//                     // Wrap(
//                     //   spacing: 10,
//                     //   children:
//                     //       ["15 min", "30 min", "1 hr"].map((eta) {
//                     //         return ChoiceChip(
//                     //           label: Text(eta),
//                     //           selected: selectedETA == eta,
//                     //           onSelected:
//                     //               (_) => setState(() => selectedETA = eta),
//                     //         );
//                     //       }).toList(),
//                     // ),
//                     const SizedBox(height: 20),
//                     Text(
//                       "Service: ${product.protitle}",
//                       style: const TextStyle(fontSize: 16),
//                     ),
//                     Text(
//                       "Charges: ${product.price}",
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 25),

//                     ElevatedButton.icon(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color.fromARGB(
//                           255,
//                           243,
//                           204,
//                           114,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 14,
//                           horizontal: 20,
//                         ),
//                       ),
//                       icon: const Icon(Icons.done),

//                       label: const Text("Confirm & Save"),
//                       onPressed: () async {
//                         await FirebaseFirestore.instance
//                             .collection("orders")
//                             .add({
//                               "workerId": workerId,
//                               "workerName": workerName,
//                               "ETA": selectedETA,
//                               "serviceName": product.protitle,
//                               "charges": product.price,
//                               "status": "assigned",
//                               "timestamp": FieldValue.serverTimestamp(),
//                             });

//                         // Confirm ke baad Tracking page pe le jao
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder:
//                                 (context) => WorkerTrackingPage(
//                                   workerId: workerId,
//                                   workerName: workerName,
//                                   workerPhone: workerPhone,
//                                   eta: selectedETA,
//                                   serviceName: product.protitle,
//                                   charges: product.price,
//                                 ),
//                           ),
//                         );

//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: const Text(
//                               "Worker assigned successfully!",
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             backgroundColor: Colors.teal.shade600,
//                             behavior: SnackBarBehavior.floating,
//                             margin: const EdgeInsets.symmetric(
//                               horizontal: 20,
//                               vertical: 10,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             duration: const Duration(seconds: 3),
//                             action: SnackBarAction(
//                               label: "OK",
//                               textColor: Colors.yellowAccent,
//                               onPressed: () {},
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//         );
//       },
//     );
//   }

//   //change

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xfff1f7fe),
//       appBar: AppBar(
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xff2193b0), Color(0xff6dd5ed)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//         title: Text(
//           category,
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//             fontSize: 20,
//             letterSpacing: 1.2,
//           ),
//         ),
//         centerTitle: true,
//         elevation: 6,
//       ),
//       body: FutureBuilder<List<ProductModel>>(
//         future: fetchProductsByCategory(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return const Center(child: Text("Error fetching products"));
//           }
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text("No Products Found"));
//           }

//           final products = snapshot.data!;

//           return ListView.builder(
//             padding: const EdgeInsets.all(14),
//             itemCount: products.length,
//             itemBuilder: (context, index) {
//               final product = products[index];
//               return GestureDetector(
//                 onTap: () => _showRadarAnimation(context, product),
//                 child: Container(
//                   margin: const EdgeInsets.symmetric(vertical: 10),
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     gradient: LinearGradient(
//                       colors: [Colors.white, Colors.blue.shade50],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.blue.withOpacity(0.15),
//                         blurRadius: 8,
//                         spreadRadius: 2,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(12),
//                         child:
//                             product.image.isNotEmpty
//                                 ? Image.memory(
//                                   base64Decode(product.image),
//                                   width: 180,
//                                   height: 150,
//                                   fit: BoxFit.cover,
//                                 )
//                                 : Container(
//                                   width: 200,
//                                   height: 200,
//                                   color: Colors.blue.shade100,
//                                   child: const Icon(
//                                     Icons.image,
//                                     size: 40,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                       ),
//                       const SizedBox(width: 14),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               product.protitle,
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xff0a7bfc),
//                               ),
//                             ),
//                             const SizedBox(height: 6),
//                             Text(
//                               product.description,
//                               style: TextStyle(
//                                 fontSize: 13,
//                                 color: Colors.grey.shade700,
//                               ),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               "Rs. ${product.price}",
//                               style: TextStyle(
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.blue.shade700,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }





// product_list_screen_with_requests.dart
// import 'dart:async';
// import 'dart:convert';
// import 'dart:math';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:kam_wala_app/image%20crud%20hamdeling/product_model.dart';
// import 'package:kam_wala_app/image%20crud%20hamdeling/worker_tracking_page.dart';
// import 'package:url_launcher/url_launcher.dart';

// class ProductListScreen extends StatefulWidget {
//   final String category;
//   final String currentUserId; // pass current logged-in user id
//   const ProductListScreen({
//     super.key,
//     required this.category,
//     required this.currentUserId,
//   });

//   @override
//   State<ProductListScreen> createState() => _ProductListScreenState();

//   static workerAcceptRequest({required String requestId, required String workerId, required workerName, required workerPhone, required String eta}) {}
// }

// class _ProductListScreenState extends State<ProductListScreen> {
//   // timeout (how long to wait for worker acceptance before declaring timeout)
//   final Duration requestTimeout = const Duration(seconds: 30);

//   // ---------- Existing product fetching ----------
//   Future<List<ProductModel>> fetchProductsByCategory() async {
//     final snapshot =
//         await FirebaseFirestore.instance
//             .collection('products')
//             .where('Category', isEqualTo: widget.category)
//             .get();

//     return snapshot.docs
//         .map((doc) => ProductModel.fromFirestore(doc.data(), doc.id))
//         .toList();
//   }

//   // Fetch list of workers (you can enhance with distance filter later)
//   Future<List<Map<String, dynamic>>> fetchWorkers() async {
//     final snapshot =
//         await FirebaseFirestore.instance
//             .collection("users")
//             .where("role", isEqualTo: "worker")
//             .get();
//     return snapshot.docs.map((doc) {
//       final data = doc.data();
//       data['uid'] = doc.id;
//       return data;
//     }).toList();
//   }

//   // Create a request doc in Firestore and return the requestId
//   Future<String> _createServiceRequest(ProductModel product) async {
//     // Fetch workers to add to request (you can filter by proximity)
//     final workers = await fetchWorkers();
//     final nearbyWorkerIds = workers.map((w) => w['uid']).toList();

//     final docRef = await FirebaseFirestore.instance.collection("requests").add({
//       "userId": widget.currentUserId,
//       "serviceName": product.protitle,
//       "charges": product.price,
//       "status":
//           "pending", // pending | accepted | rejected | timeout | cancelled | completed
//       "workerId": null,
//       "workerName": null,
//       "eta": null,
//       "nearbyWorkers":
//           nearbyWorkerIds, // list of worker uids we tried to notify
//       "productId": product.id,
//       "productSnapshot": {
//         "title": product.protitle,
//         "price": product.price,
//         "description": product.description,
//         // add more if needed
//       },
//       "timestamp": FieldValue.serverTimestamp(),
//     });

//     // OPTIONAL: Here you can trigger FCM to workers using their FCM tokens.
//     // For a simple approach without Cloud Functions, you could write into each
//     // worker's subcollection 'inboxRequests' and workers app listens to that.
//     //
//     // Example pseudo:
//     // for (String w in nearbyWorkerIds) {
//     //   FirebaseFirestore.instance.collection('users').doc(w)
//     //     .collection('inboxRequests').doc(docRef.id).set({ ... });
//     // }

//     return docRef.id;
//   }

//   // Show radar animation, create request and show waiting/pending UI.
//   void _startServiceRequestFlow(
//     BuildContext context,
//     ProductModel product,
//   ) async {
//     // 1) Create request doc
//     String requestId;
//     try {
//       requestId = await _createServiceRequest(product);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Failed to create request.")),
//       );
//       return;
//     }

//     // 2) Show radar animation for short while and then show pending dialog
//     _showRadarAnimation(context);

//     // After animation show pending bottom sheet and attach listener
//     Future.delayed(const Duration(seconds: 2), () {
//       // Close radar then show pending
//       Navigator.pop(context);
//       _showPendingRequestSheet(context, product, requestId);
//     });
//   }

//   void _showRadarAnimation(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) {
//         return Center(
//           child: SizedBox(
//             width: 220,
//             height: 220,
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 // Multiple animated circles
//                 ...List.generate(3, (i) {
//                   return AnimatedContainer(
//                     duration: Duration(seconds: 2 + i),
//                     curve: Curves.easeInOutCubic,
//                     width: 220 - (i * 60).toDouble(),
//                     height: 220 - (i * 60).toDouble(),
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       gradient: RadialGradient(
//                         colors: [
//                           Colors.cyanAccent.withOpacity(0.25),
//                           Colors.teal.withOpacity(0.05),
//                         ],
//                         stops: const [0.2, 1],
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.cyanAccent.withOpacity(0.3),
//                           blurRadius: 20,
//                           spreadRadius: 5,
//                         ),
//                       ],
//                     ),
//                   );
//                 }),

//                 // Glowing radar icon
//                 Container(
//                   padding: const EdgeInsets.all(15),
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     gradient: LinearGradient(
//                       colors: [
//                         Colors.cyanAccent.withOpacity(0.8),
//                         Colors.tealAccent.withOpacity(0.6),
//                       ],
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.cyanAccent.withOpacity(0.6),
//                         blurRadius: 25,
//                         spreadRadius: 3,
//                       ),
//                     ],
//                   ),
//                   child: const Icon(Icons.radar, size: 70, color: Colors.black),
//                 ),

//                 // Pulsing glow effect
//                 Positioned.fill(
//                   child: TweenAnimationBuilder<double>(
//                     tween: Tween(begin: 0.9, end: 1.1),
//                     duration: const Duration(seconds: 1),
//                     curve: Curves.easeInOut,
//                     builder: (context, value, child) {
//                       return Transform.scale(
//                         scale: value,
//                         child: Container(
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             border: Border.all(
//                               color: Colors.cyanAccent.withOpacity(0.3),
//                               width: 2,
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // Show BottomSheet with pending state and attach a listener to request doc.
//   void _showPendingRequestSheet(
//     BuildContext context,
//     ProductModel product,
//     String requestId,
//   ) {
//     StreamSubscription<DocumentSnapshot>? subscription;
//     Timer? timeoutTimer;

//     // Start timeout timer
//     timeoutTimer = Timer(requestTimeout, () async {
//       // If still pending after timeout, mark the request as timed out
//       final doc =
//           await FirebaseFirestore.instance
//               .collection("requests")
//               .doc(requestId)
//               .get();
//       if (doc.exists && doc.data()?['status'] == 'pending') {
//         await FirebaseFirestore.instance
//             .collection("requests")
//             .doc(requestId)
//             .update({"status": "timeout"});

//         // Optionally inform the user
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("No worker accepted within time. Try again."),
//             ),
//           );
//         }
//       }
//       // Close sheet if open
//       try {
//         Navigator.of(context).maybePop();
//       } catch (_) {}
//     });

//     // Open bottom sheet
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: const Color.fromARGB(255, 140, 212, 245),
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//       ),
//       builder: (contextSheet) {
//         // Inside sheet we show states updating via setState inside StatefulBuilder
//         return StatefulBuilder(
//           builder: (context2, setState) {
//             String currentStatus = "pending";
//             String workerName = "";
//             String workerId = "";
//             String eta = "";
//             String workerPhone = "";

//             // Attach listener only once at sheet build
//             subscription ??= FirebaseFirestore.instance
//                 .collection("requests")
//                 .doc(requestId)
//                 .snapshots()
//                 .listen((docSnap) {
//                   if (!docSnap.exists) return;
//                   final data = docSnap.data() as Map<String, dynamic>;

//                   final newStatus = data['status'] as String? ?? 'pending';

//                   // update UI:
//                   setState(() {
//                     currentStatus = newStatus;
//                     workerName = data['workerName'] ?? "";
//                     workerId = data['workerId'] ?? "";
//                     eta = data['eta'] ?? "";
//                     // If you stored worker phone in request you can fetch it
//                     workerPhone = data['workerPhone'] ?? "";
//                   });

//                   // When accepted -> navigate to tracking page
//                   if (newStatus == 'accepted') {
//                     // cancel timeout & subscription before navigating
//                     timeoutTimer?.cancel();
//                     subscription?.cancel();
//                     // Close the sheet then navigate
//                     Navigator.of(context2).pop(); // close bottom sheet
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                         builder:
//                             (contextNav) => WorkerTrackingPage(
//                               workerId: workerId,
//                               workerName: workerName,
//                               workerPhone: workerPhone,
//                               eta: eta,
//                               serviceName: product.protitle,
//                               charges: product.price,
//                             ),
//                       ),
//                     );
//                   } else if (newStatus == 'rejected') {
//                     // Optionally you can keep waiting for another worker or notify user
//                     // Here we show a snack and close sheet
//                     timeoutTimer?.cancel();
//                     subscription?.cancel();
//                     if (mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text(
//                             "Worker rejected the request. Trying next...",
//                           ),
//                         ),
//                       );
//                     }
//                     Navigator.of(context2).pop();
//                   } else if (newStatus == 'timeout') {
//                     timeoutTimer?.cancel();
//                     subscription?.cancel();
//                     if (mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text(
//                             "No worker accepted. Please try again.",
//                           ),
//                         ),
//                       );
//                     }
//                     Navigator.of(context2).pop();
//                   } // other states handled similarly
//                 });

//             return Padding(
//               padding: EdgeInsets.only(
//                 bottom: MediaQuery.of(context2).viewInsets.bottom + 20,
//                 left: 22,
//                 right: 22,
//                 top: 18,
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                     height: 5,
//                     width: 60,
//                     margin: const EdgeInsets.only(bottom: 15),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[300],
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                   ),
//                   Text(
//                     currentStatus == 'pending'
//                         ? "Searching for Worker..."
//                         : "Status: ${currentStatus.toUpperCase()}",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 20,
//                       color: Colors.blue.shade700,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   if (currentStatus == 'pending') ...[
//                     const SizedBox(height: 8),
//                     const CircularProgressIndicator(),
//                     const SizedBox(height: 12),
//                     const Text(
//                       "We're notifying nearby workers. Please wait...",
//                     ),
//                     const SizedBox(height: 18),
//                     ElevatedButton.icon(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color.fromARGB(
//                           255,
//                           243,
//                           204,
//                           114,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 14,
//                           horizontal: 20,
//                         ),
//                       ),
//                       icon: const Icon(Icons.cancel),
//                       label: const Text("Cancel Request"),
//                       onPressed: () async {
//                         // Cancel request
//                         timeoutTimer?.cancel();
//                         subscription?.cancel();
//                         await FirebaseFirestore.instance
//                             .collection("requests")
//                             .doc(requestId)
//                             .update({"status": "cancelled"});
//                         Navigator.of(context2).pop();
//                         if (mounted) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(content: Text("Request cancelled")),
//                           );
//                         }
//                       },
//                     ),
//                   ] else if (currentStatus == 'accepted') ...[
//                     const SizedBox(height: 8),
//                     CircleAvatar(
//                       radius: 35,
//                       backgroundColor: Colors.blue.shade100,
//                       child: Text(
//                         workerName.isNotEmpty
//                             ? workerName[0].toUpperCase()
//                             : "W",
//                         style: const TextStyle(
//                           fontSize: 28,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Text("Worker: $workerName"),
//                     Text("Worker ID: $workerId"),
//                     Text("ETA: $eta"),
//                     const SizedBox(height: 12),
//                     ElevatedButton.icon(
//                       icon: const Icon(Icons.phone),
//                       label: const Text("Call Worker"),
//                       onPressed: () {
//                         if (workerPhone.isNotEmpty) {
//                           launchUrl(Uri.parse("tel:$workerPhone"));
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green.shade600,
//                       ),
//                     ),
//                   ] else if (currentStatus == 'timeout' ||
//                       currentStatus == 'rejected' ||
//                       currentStatus == 'cancelled') ...[
//                     const SizedBox(height: 12),
//                     Text("Request ended with status: $currentStatus"),
//                     const SizedBox(height: 12),
//                     ElevatedButton(
//                       onPressed: () {
//                         Navigator.of(context2).pop();
//                       },
//                       child: const Text("OK"),
//                     ),
//                   ],
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     ).whenComplete(() {
//       // Ensure timers & subscriptions cleaned up if sheet dismissed manually
//       timeoutTimer?.cancel();
//       subscription?.cancel();
//     });
//   }

//   // ---------- Worker-side helper (example) -----------
//   // This function is to be used in the worker app when a worker chooses to accept.
//   // It sets the request doc to accepted and writes worker details and chosen ETA.
//   // workerPhone optional - you may fetch worker phone from users collection and write it to request.
//   static Future<void> workerAcceptRequest({
//     required String requestId,
//     required String workerId,
//     required String workerName,
//     required String eta,
//     String? workerPhone,
//   }) async {
//     final requestRef = FirebaseFirestore.instance
//         .collection("requests")
//         .doc(requestId);

//     // Do a transaction to avoid race conditions (multiple workers accept at same time)
//     await FirebaseFirestore.instance.runTransaction((tx) async {
//       final snapshot = await tx.get(requestRef);
//       if (!snapshot.exists) {
//         throw Exception("Request not found");
//       }
//       final data = snapshot.data() as Map<String, dynamic>;
//       final status = data['status'] ?? 'pending';

//       // Only accept if still pending
//       if (status == 'pending') {
//         tx.update(requestRef, {
//           "status": "accepted",
//           "workerId": workerId,
//           "workerName": workerName,
//           "eta": eta,
//           "workerPhone": workerPhone ?? FieldValue.delete(),
//           "acceptedAt": FieldValue.serverTimestamp(),
//         });
//       } else {
//         // If not pending, throw or ignore
//         throw Exception("Request already taken");
//       }
//     });
//   }

//   // ---------- UI build ----------
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xfff1f7fe),
//       appBar: AppBar(
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xff2193b0), Color(0xff6dd5ed)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//         title: Text(
//           widget.category,
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//             fontSize: 20,
//             letterSpacing: 1.2,
//           ),
//         ),
//         centerTitle: true,
//         elevation: 6,
//       ),
//       body: FutureBuilder<List<ProductModel>>(
//         future: fetchProductsByCategory(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return const Center(child: Text("Error fetching products"));
//           }
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text("No Products Found"));
//           }

//           final products = snapshot.data!;

//           return ListView.builder(
//             padding: const EdgeInsets.all(14),
//             itemCount: products.length,
//             itemBuilder: (context, index) {
//               final product = products[index];
//               return GestureDetector(
//                 onTap: () {
//                   // Start the service request flow
//                   _startServiceRequestFlow(context, product);
//                 },
//                 child: Container(
//                   margin: const EdgeInsets.symmetric(vertical: 10),
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     gradient: LinearGradient(
//                       colors: [Colors.white, Colors.blue.shade50],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.blue.withOpacity(0.15),
//                         blurRadius: 8,
//                         spreadRadius: 2,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(12),
//                         child:
//                             product.image.isNotEmpty
//                                 ? Image.memory(
//                                   base64Decode(product.image),
//                                   width: 180,
//                                   height: 150,
//                                   fit: BoxFit.cover,
//                                 )
//                                 : Container(
//                                   width: 200,
//                                   height: 200,
//                                   color: Colors.blue.shade100,
//                                   child: const Icon(
//                                     Icons.image,
//                                     size: 40,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                       ),
//                       const SizedBox(width: 14),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               product.protitle,
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xff0a7bfc),
//                               ),
//                             ),
//                             const SizedBox(height: 6),
//                             Text(
//                               product.description,
//                               style: TextStyle(
//                                 fontSize: 13,
//                                 color: Colors.grey.shade700,
//                               ),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               "Rs. ${product.price}",
//                               style: TextStyle(
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.blue.shade700,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//  }
// }

