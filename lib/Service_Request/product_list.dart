// import 'dart:async';
// import 'dart:convert';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:kam_wala_app/image%20crud%20hamdeling/product_model.dart';
// import 'package:kam_wala_app/image%20crud%20hamdeling/worker_tracking_page.dart';
// import 'package:url_launcher/url_launcher.dart';

// class ProductListScreennew extends StatefulWidget {
//   final String category;
//   final String currentUserId;

//   const ProductListScreennew({
//     super.key,
//     required this.category,
//     required this.currentUserId,
//   });

//   @override
//   State<ProductListScreennew> createState() => _ProductListScreennewState();

//   // Worker acceptance helper (used in WorkerRequestsPage)
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

//     await FirebaseFirestore.instance.runTransaction((tx) async {
//       final snapshot = await tx.get(requestRef);
//       if (!snapshot.exists) throw Exception("Request not found");
//       final data = snapshot.data() as Map<String, dynamic>;
//       final status = data['status'] ?? 'pending';

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
//         throw Exception("Request already taken");
//       }
//     });
//   }
// }

// class _ProductListScreennewState extends State<ProductListScreennew> {
//   final Duration requestTimeout = const Duration(seconds: 30);

//   /// 🔔 FCM server key (tum apni Firebase console → Project Settings → Cloud Messaging se copy karna)
//   static const String serverKey = "YOUR_FIREBASE_SERVER_KEY";

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

//   /// 🔔 Send push notification to worker
//   Future<void> sendNotificationToWorker(
//     String token,
//     String title,
//     String body,
//   ) async {
//     final response = await http.post(
//       Uri.parse("https://fcm.googleapis.com/fcm/send"),
//       headers: {
//         "Content-Type": "application/json",
//         "Authorization": "key=$serverKey",
//       },
//       body: jsonEncode({
//         "to": token,
//         "notification": {"title": title, "body": body, "sound": "default"},
//         "data": {
//           "click_action": "FLUTTER_NOTIFICATION_CLICK",
//           "status": "new_request",
//         },
//       }),
//     );

//     if (response.statusCode != 200) {
//       debugPrint("❌ Failed to send notification: ${response.body}");
//     }
//   }

//   /// Create request + notify nearby workers
//   Future<String> _createServiceRequest(ProductModel product) async {
//     final workers = await fetchWorkers();
//     final nearbyWorkerIds = workers.map((w) => w['uid']).toList();

//     final docRef = await FirebaseFirestore.instance.collection("requests").add({
//       "userId": widget.currentUserId,
//       "serviceName": product.protitle,
//       "charges": product.price,
//       "status": "pending",
//       "workerId": null,
//       "workerName": null,
//       "eta": null,
//       "workerPhone": null,
//       "nearbyWorkers": nearbyWorkerIds,
//       "productId": product.id,
//       "productSnapshot": {
//         "title": product.protitle,
//         "price": product.price,
//         "description": product.description,
//       },
//       "timestamp": FieldValue.serverTimestamp(),
//     });

//     /// 🔔 Send notification to each worker
//     for (final worker in workers) {
//       if (worker['fcmToken'] != null) {
//         await sendNotificationToWorker(
//           worker['fcmToken'],
//           "New Request: ${product.protitle}",
//           "Charges: Rs.${product.price}",
//         );
//       }
//     }

//     return docRef.id;
//   }

//   void _startServiceRequestFlow(
//     BuildContext context,
//     ProductModel product,
//   ) async {
//     String requestId;
//     try {
//       requestId = await _createServiceRequest(product);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Failed to create request.")),
//       );
//       return;
//     }

//     _showRadarAnimation(context);

//     Future.delayed(const Duration(seconds: 2), () {
//       Navigator.pop(context);
//       _showPendingRequestSheet(context, product, requestId);
//     });
//   }

//   // Radar animation (no change)
//   void _showRadarAnimation(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder:
//           (_) => Center(
//             child: SizedBox(
//               width: 220,
//               height: 220,
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   ...List.generate(3, (i) {
//                     return AnimatedContainer(
//                       duration: Duration(seconds: 2 + i),
//                       curve: Curves.easeInOutCubic,
//                       width: 220 - (i * 60).toDouble(),
//                       height: 220 - (i * 60).toDouble(),
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         gradient: RadialGradient(
//                           colors: [
//                             Colors.cyanAccent.withOpacity(0.25),
//                             Colors.teal.withOpacity(0.05),
//                           ],
//                           stops: const [0.2, 1],
//                         ),
//                       ),
//                     );
//                   }),
//                   Container(
//                     padding: const EdgeInsets.all(15),
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       gradient: LinearGradient(
//                         colors: [
//                           Colors.cyanAccent.withOpacity(0.8),
//                           Colors.tealAccent.withOpacity(0.6),
//                         ],
//                       ),
//                     ),
//                     child: const Icon(
//                       Icons.radar,
//                       size: 70,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//     );
//   }

//   // Bottom sheet (same as before)
//   void _showPendingRequestSheet(
//     BuildContext context,
//     ProductModel product,
//     String requestId,
//   ) {
//     StreamSubscription<DocumentSnapshot>? subscription;
//     Timer? timeoutTimer;

//     timeoutTimer = Timer(requestTimeout, () async {
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
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("No worker accepted within time. Try again."),
//             ),
//           );
//         }
//       }
//       try {
//         Navigator.of(context).maybePop();
//       } catch (_) {}
//     });

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: const Color.fromARGB(255, 140, 212, 245),
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//       ),
//       builder: (contextSheet) {
//         return StatefulBuilder(
//           builder: (context2, setState) {
//             String currentStatus = "pending";
//             String workerName = "";
//             String workerId = "";
//             String eta = "";
//             String workerPhone = "";

//             subscription ??= FirebaseFirestore.instance
//                 .collection("requests")
//                 .doc(requestId)
//                 .snapshots()
//                 .listen((docSnap) {
//                   if (!docSnap.exists) return;
//                   final data = docSnap.data() as Map<String, dynamic>;
//                   final newStatus = data['status'] as String? ?? 'pending';
//                   setState(() {
//                     currentStatus = newStatus;
//                     workerName = data['workerName'] ?? "";
//                     workerId = data['workerId'] ?? "";
//                     eta = data['eta'] ?? "";
//                     workerPhone = data['workerPhone'] ?? "";
//                   });

//                   if (newStatus == 'accepted') {
//                     timeoutTimer?.cancel();
//                     subscription?.cancel();
//                     Navigator.of(context2).pop();
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                         builder:
//                             (_) => WorkerTrackingPage(
//                               workerId: workerId,
//                               workerName: workerName,
//                               workerPhone: workerPhone,
//                               eta: eta,
//                               serviceName: product.protitle,
//                               charges: product.price,
//                             ),
//                       ),
//                     );
//                   } else if (newStatus == 'rejected' ||
//                       newStatus == 'timeout') {
//                     timeoutTimer?.cancel();
//                     subscription?.cancel();
//                     if (mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text(
//                             "Request ended with status: $newStatus",
//                           ),
//                         ),
//                       );
//                     }
//                     Navigator.of(context2).pop();
//                   }
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
//                   ],
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     ).whenComplete(() {
//       timeoutTimer?.cancel();
//       subscription?.cancel();
//     });
//   }

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
//                 onTap: () => _startServiceRequestFlow(context, product),
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



// // import 'dart:convert';

// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:kam_wala_app/image%20crud%20hamdeling/product_model.dart';


// // class ProductPage extends StatefulWidget {
// //   final String categoryName;
// //   final String docId;
// //   final String categoryId;

// //   const ProductPage({
// //     super.key,
// //     required this.categoryName,
// //     required this.docId,
// //     required this.categoryId,
// //   });

// //   @override
// //   State<ProductPage> createState() => _ProductPageState();
// // }

// // class _ProductPageState extends State<ProductPage> {
// //   List<ProductModel> productList = [];

// //   String? categoryName;
// // bool isLoadingCategory = true;

// // /// 🔹 Fetch services by category ID
// // Future<List<ProductModel>> fetchServicesByCategory() async {
// //   final snapshot = await FirebaseFirestore.instance
// //       .collection('services')
// //       .where('categoryId', isEqualTo: widget.category)
// //       .get();

// //   return snapshot.docs
// //       .map((doc) => ProductModel.fromFirestore(doc.data(), doc.id))
// //       .toList();
// // }

// // Future<void> fetchCategoryName() async {
// //   try {
// //     final doc = await FirebaseFirestore.instance
// //         .collection('categories')
// //         .doc(widget.category) // category ID
// //         .get();

// //     if (doc.exists) {
// //       setState(() {
// //         categoryName = doc['name'];
// //         isLoadingCategory = false;
// //       });
// //     } else {
// //       setState(() {
// //         categoryName = "Unknown Category";
// //         isLoadingCategory = false;
// //       });
// //     }
// //   } catch (e) {
// //     setState(() {
// //       categoryName = "Error Loading";
// //       isLoadingCategory = false;
// //     });
// //   }
// // }


// //   @override
// //   void initState() {
// //     check();
// //     super.initState();
// //     fetchCategoryName();   // 🔹 fetch category name
// //   }

// //   void check() async {
// //     try {
// //       FirebaseFirestore.instance
// //           .collection("Advance / Products")
// //           .where("Category", isEqualTo: widget.categoryName)
// //           .snapshots()
// //           .listen((event) {
// //         productList.clear();
// //         for (final doc in event.docs) {
// //           print(doc.data());
// //           productList.add(ProductModel.fromJson(doc.data()));
// //         }
// //         setState(() {});
// //       });
// //     } catch (e) {
// //       print("Error: $e");
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //      appBar: AppBar(
// //   flexibleSpace: Container(
// //     decoration: const BoxDecoration(
// //       gradient: LinearGradient(
// //         colors: [Color(0xff2193b0), Color(0xff6dd5ed)],
// //         begin: Alignment.topLeft,
// //         end: Alignment.bottomRight,
// //       ),
// //     ),
// //   ),
// //   title: Text(
// //     isLoadingCategory
// //         ? "Loading..."
// //         : (categoryName ?? "Category"),
// //     style: const TextStyle(
// //       fontWeight: FontWeight.bold,
// //       color: Colors.white,
// //       fontSize: 20,
// //       letterSpacing: 1.2,
// //     ),
// //   ),
// //   centerTitle: true,
// //   elevation: 6,
// // ),
// //       body: productList.isEmpty
// //           ? const Center(
// //               child: Text(
// //                 "No product found",
// //                 style: TextStyle(color: Colors.grey),
// //               ),
// //             )
// //           : ListView.builder(
// //               itemCount: productList.length,
// //               itemBuilder: (context, index) {
// //                 final product = productList[index];

// //                 return Container(
// //                   padding: const EdgeInsets.all(10),
// //                   decoration: const BoxDecoration(
// //                     border: Border(
// //                       bottom: BorderSide(color: Colors.grey),
// //                     ),
// //                   ),
// //                   child: Row(
// //                     children: [
// //                       ClipRRect(
// //                         borderRadius: BorderRadius.circular(10),
// //                         child: Image.memory(
// //                           base64Decode(product.img),
// //                           height: 80,
// //                           width: 80,
// //                           fit: BoxFit.cover,
// //                         ),
// //                       ),
// //                       const SizedBox(width: 10),
// //                       Expanded(
// //                         child: Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             Text(
// //                               product.title,
// //                               style: const TextStyle(
// //                                   fontWeight: FontWeight.bold, fontSize: 16),
// //                             ),
// //                             const SizedBox(height: 5),
// //                             Text(
// //                               "PKR: ${product.price}",
// //                               style: const TextStyle(
// //                                 color: Colors.blue,
// //                                 fontWeight: FontWeight.bold,
// //                                 fontSize: 15,
// //                               ),
// //                             ),
// //                             const SizedBox(height: 5),
// //                             Text(
// //                               product.des,
// //                               maxLines: 2,
// //                               overflow: TextOverflow.ellipsis,
// //                               style: const TextStyle(color: Colors.grey),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 );
// //               },
// //             ),
// //     );
// //   }
// // }



// ------------------Faltuuuuuuuuuuuuuuuuuuu---------------------

// import 'dart:convert';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:kam_wala_app/image%20crud%20hamdeling/product_model.dart';

// class ProductPage extends StatefulWidget {
//   final String categoryName;
//   final String docId;
//   final String categoryId;


// // -------------------------------------------
// // 🔥 WORKER ACCEPT REQUEST — FINAL VERSION
// // -------------------------------------------
// static Future<void> workerAcceptRequest({
//   required String requestId,
//   required String workerId,
//   required String workerName,
//   required String workerPhone,
//   required String eta,
// }) async {
//   final ref = FirebaseFirestore.instance.collection('requests').doc(requestId);

//   await ref.update({
//     "status": "accepted",
//     "acceptedWorkerId": workerId,
//     "acceptedWorkerName": workerName,
//     "acceptedWorkerPhone": workerPhone,
//     "eta": eta,
//     "acceptedAt": DateTime.now().millisecondsSinceEpoch,
//   });
// }

//   const ProductPage({
//     super.key,
//     required this.categoryName,
//     required this.docId,
//     required this.categoryId,
//   });

//   @override
//   State<ProductPage> createState() => _ProductPageState();
// }

// class _ProductPageState extends State<ProductPage> {
//   List<ProductModel> productList = [];

//   String? categoryName;
//   bool isLoadingCategory = true;

//   /// 🔹 Fetch category name
//   Future<void> fetchCategoryName() async {
//     try {
//       final doc = await FirebaseFirestore.instance
//           .collection('categories')
//           .doc(widget.categoryId)
//           .get();

//       if (doc.exists) {
//         setState(() {
//           categoryName = doc['name'];
//           isLoadingCategory = false;
//         });
//       } else {
//         setState(() {
//           categoryName = "Unknown Category";
//           isLoadingCategory = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         categoryName = "Error Loading";
//         isLoadingCategory = false;
//       });
//     }
//   }

//   /// 🔹 Listen Product list
//   void fetchProducts() async {
//     try {
//       FirebaseFirestore.instance
//           .collection("AdvanceProducts") // FIX NAME
//           .where("Category", isEqualTo: widget.categoryName)
//           .snapshots()
//           .listen((event) {
//         productList.clear();

//         for (final doc in event.docs) {
//           productList.add(ProductModel.fromJson(doc.data()));
//         }

//         setState(() {});
//       });
//     } catch (e) {
//       print("Error: $e");
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     fetchCategoryName();
//     fetchProducts();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
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
//           isLoadingCategory ? "Loading..." : (categoryName ?? "Category"),
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

//       body: productList.isEmpty
//           ? const Center(
//               child: Text(
//                 "No product found",
//                 style: TextStyle(color: Colors.grey),
//               ),
//             )
//           : ListView.builder(
//               itemCount: productList.length,
//               itemBuilder: (context, index) {
//                 final product = productList[index];

//                 return Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: const BoxDecoration(
//                     border: Border(
//                       bottom: BorderSide(color: Colors.grey),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(10),
//                         child: Image.memory(
//                           base64Decode(product.img),
//                           height: 80,
//                           width: 80,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               product.title,
//                               style: const TextStyle(
//                                   fontWeight: FontWeight.bold, fontSize: 16),
//                             ),
//                             const SizedBox(height: 5),
//                             Text(
//                               "PKR: ${product.price}",
//                               style: const TextStyle(
//                                 color: Colors.blue,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 15,
//                               ),
//                             ),
//                             const SizedBox(height: 5),
//                             Text(
//                               product.des,
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                               style: const TextStyle(color: Colors.grey),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }



// faltu

// import 'dart:convert';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:kam_wala_app/image crud hamdeling/product_model.dart';

// class ProductPage extends StatefulWidget {
//   final String categoryName; // Only needed for fetching products
//   final String categoryId;   // Only needed for future if you use it
//   final String docId;        // Optional (can remove later if unused)

//   // -------------------------------------------
//   // 🔥 WORKER ACCEPT REQUEST — FINAL VERSION
//   // -------------------------------------------
//   static Future<void> workerAcceptRequest({
//     required String requestId,
//     required String workerId,
//     required String workerName,
//     required String workerPhone,
//     required String eta,
//   }) async {
//     final ref = FirebaseFirestore.instance.collection('requests').doc(requestId);

//     await ref.update({
//       "status": "accepted",
//       "acceptedWorkerId": workerId,
//       "acceptedWorkerName": workerName,
//       "acceptedWorkerPhone": workerPhone,
//       "eta": eta,
//       "acceptedAt": DateTime.now().millisecondsSinceEpoch,
//     });
//   }

//   const ProductPage({
//     super.key,
//     required this.categoryName,
//     required this.categoryId,
//     required this.docId,
//   });

//   @override
//   State<ProductPage> createState() => _ProductPageState();
// }

// class _ProductPageState extends State<ProductPage> {
//   List<ProductModel> productList = [];

//   /// 🔹 Fetch products in real-time
//   void fetchProducts() {
//   FirebaseFirestore.instance
//       .collection("services")
//       .where("categoryId", isEqualTo: widget.categoryId)
//       .snapshots()
//       .listen((event) {
//     productList = event.docs
//         .map((doc) => ProductModel.fromJson(doc.data()))
//         .toList();

//     setState(() {});
//   });
// }


//   @override
//   void initState() {
//     super.initState();
//     fetchProducts(); // No category fetch needed
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
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
//           widget.categoryName, // DIRECTLY USE PASSED NAME
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

//       body: productList.isEmpty
//           ? const Center(
//               child: Text(
//                 "No product found",
//                 style: TextStyle(color: Colors.grey),
//               ),
//             )
//           : ListView.builder(
//               itemCount: productList.length,
//               itemBuilder: (context, index) {
//                 final product = productList[index];

//                 return Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: const BoxDecoration(
//                     border: Border(
//                       bottom: BorderSide(color: Colors.grey),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(10),
//                           child: Image.memory(
//                             base64Decode(product.img),
//                             height: 80,
//                             width: 80,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               product.title,
//                               style: const TextStyle(
//                                   fontWeight: FontWeight.bold, fontSize: 16),
//                             ),
//                             const SizedBox(height: 5),
//                             Text(
//                               "PKR: ${product.price}",
//                               style: const TextStyle(
//                                 color: Colors.blue,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 15,
//                               ),
//                             ),
//                             const SizedBox(height: 5),
//                             Text(
//                               product.des,
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                               style: const TextStyle(color: Colors.grey),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

// product_page_with_waiting_and_request.dart
import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kam_wala_app/Service_Request/send_fcm.dart';
import 'package:kam_wala_app/image crud hamdeling/product_model.dart';
import 'package:kam_wala_app/image%20crud%20hamdeling/worker_tracking_page.dart';

class ProductPage extends StatefulWidget {
  final String categoryName;
  final String categoryId;
  final String docId;

  const ProductPage({
    super.key,
    required this.categoryName,
    required this.categoryId,
    required this.docId,
  });

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<ProductModel> productList = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  void fetchProducts() {
    FirebaseFirestore.instance
        .collection("services") // or "products" depending on your DB
        .where("categoryId", isEqualTo: widget.categoryId)
        .snapshots()
        .listen((event) {
      productList = event.docs
          .map((doc) {
            final data = doc.data();
            // adapt constructor names as per your model
            return ProductModel.fromJson(data);
          })
          .toList();
      setState(() {});
    });
  }

Future<String> createRequest(ProductModel service) async {
  final user = FirebaseAuth.instance.currentUser;
  final reqRef = FirebaseFirestore.instance.collection('requests');

  // ---------------------------------------
  // STEP 1: Find workers from `workers` collection by category
  // ---------------------------------------
  final workersSnapshot = await FirebaseFirestore.instance
      .collection('workers')
      .where('categoryId', isEqualTo: widget.categoryId)
      .get();

  // No worker?
  if (workersSnapshot.docs.isEmpty) {
    debugPrint("⚠ No workers found in this category!");
  }

  // ---------------------------------------
  // STEP 2: Create request document
  // ---------------------------------------
  final docRef = reqRef.doc();

  final payload = {
    "requestId": docRef.id,
    "userId": user?.uid ?? "",
    "serviceName": service.title,
    "charges": service.price,
    "description": service.des,
    "categoryId": widget.categoryId,
    "status": "pending",
    "createdAt": FieldValue.serverTimestamp(),
  };

  await docRef.set(payload);

  // ---------------------------------------
  // STEP 3: For each worker → find his token via email in USERS collection
  // ---------------------------------------

  for (var worker in workersSnapshot.docs) {
    final workerEmail = worker.data()["email"];

    if (workerEmail == null || workerEmail.toString().isEmpty) {
      continue;
    }

    // Find matching user document by email
    final userSnap = await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: workerEmail)
        .limit(1)
        .get();

    if (userSnap.docs.isEmpty) {
      debugPrint("⚠ Worker user doc not found for: $workerEmail");
      continue;
    }

    final workerToken = userSnap.docs.first.data()["token"];

    if (workerToken == null || workerToken.toString().isEmpty) {
      debugPrint("⚠ Worker token empty for: $workerEmail");
      continue;
    }

    // ---------------------------------------
    // STEP 4: Send notification
    // ---------------------------------------
    await sendPushNotification(
      token: workerToken,
      title: "New Job Request",
      body: "${service.title} — Rs. ${service.price}",
      data: {
        "screen": "worker_notifications",
        "requestId": docRef.id,
      },
    );
  }

  return docRef.id;
}



// yeh bh bekaar
// Future<String> createRequest(ProductModel service) async {
//   final user = FirebaseAuth.instance.currentUser;
//   final reqRef = FirebaseFirestore.instance.collection('requests');

//   // Step 1: fetch all workers of this category
//   final workersSnapshot = await FirebaseFirestore.instance
//       .collection('users')
//       .where('role', isEqualTo: 'worker')
//       .where('categoryId', isEqualTo: widget.categoryId)
//       .get();

//   final docRef = reqRef.doc();
//   final payload = {
//     "requestId": docRef.id,
//     "userId": user?.uid ?? "",
//     "serviceName": service.title,
//     "charges": service.price,
//     "description": service.des,
//     "categoryId": widget.categoryId,
//     "status": "pending",
//     "createdAt": FieldValue.serverTimestamp(),
//   };

//   // Step 2: save request
//   await docRef.set(payload);

//   // Step 3: SEND NOTIFICATION TO EACH WORKER
//   for (var worker in workersSnapshot.docs) {
//     final data = worker.data();
//     final workerToken = data["fcmToken"];

//     if (workerToken != null && workerToken.toString().isNotEmpty) {
//       await sendPushNotification(
//         token: workerToken,
//         title: "New Job Request",
//         body: "${service.title} — Rs. ${service.price}",
//         data: {
//           "screen": "worker_notifications",
//           "requestId": docRef.id,
//         },
//       );
//     }
//   }

//   return docRef.id;
// }

  /// ---------- CREATE REQUEST ----------
  /// creates request doc and returns created doc id
  // Future<String> createRequest(ProductModel service) async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   final requestsRef = FirebaseFirestore.instance.collection('requests');

  //   // find nearby workers (collect their IDs) — adapt query if you store worker categories differently
  //   final workersSnapshot = await FirebaseFirestore.instance
  //       .collection('users')
  //       .where('role', isEqualTo: 'worker')
  //       .where('categoryId', isEqualTo: widget.categoryId)
  //       .get();

  //   final nearbyWorkerIds = workersSnapshot.docs.map((d) => d.id).toList();

  //   final docRef = requestsRef.doc(); // new id
  //   final now = FieldValue.serverTimestamp();

  //   final payload = {
  //     'requestId': docRef.id,
  //     'userId': user?.uid ?? '',
  //     'serviceName': service.title, // adapt field names if needed
  //     // 'serviceId': service.id ?? '', // if you store id
  //     'description': service.des,
  //     'charges': service.price,
  //     'categoryId': widget.categoryId,
  //     'categoryName': widget.categoryName,
  //     'status': 'pending',
  //     'nearbyWorkers': nearbyWorkerIds,
  //     'createdAt': now,
  //     // optionally add user's location if available
  //   };

  //   await docRef.set(payload);
  //   return docRef.id;
  // }

  void _onBookNow(ProductModel service) async {
    try {
      // navigate to waiting screen immediately (optimistic UX) while creating request
      // show waiting page and then create the request and pass requestId into it
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WaitingForWorkerScreen(
            service: service,
            categoryId: widget.categoryId,
            createRequestFuture: createRequest(service),
          ),
        ),
      );
    } catch (e) {
      // fallback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff2193b0), Color(0xff6dd5ed)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        elevation: 6,
      ),
      body: productList.isEmpty
          ? const Center(child: Text("No products found"))
          : ListView.builder(
              itemCount: productList.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final product = productList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: product.img.isNotEmpty
                          ? Image.memory(
                              base64Decode(product.img),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 80,
                              height: 80,
                              color: Colors.blue.shade100,
                              child: const Icon(Icons.image),
                            ),
                    ),
                    title: Text(product.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(product.des, maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: ElevatedButton(
                      onPressed: () => _onBookNow(product),
                      child: const Text("Book Now"),
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

/// Waiting screen — full page (prevents overflow dialogs)
/// - accepts a future that creates the request; shows loading + request id when available
/// - listens to the request doc; when status becomes "accepted", navigates to WorkerTrackingPage
class WaitingForWorkerScreen extends StatefulWidget {
  final ProductModel service;
  final String categoryId;
  final Future<String> createRequestFuture;

  const WaitingForWorkerScreen({
    super.key,
    required this.service,
    required this.categoryId,
    required this.createRequestFuture,
  });

  @override
  State<WaitingForWorkerScreen> createState() => _WaitingForWorkerScreenState();
}

class _WaitingForWorkerScreenState extends State<WaitingForWorkerScreen> {
  String? _requestId;
  StreamSubscription<DocumentSnapshot>? _sub;
  bool _failed = false;
  String _message = "Waiting for worker to respond...";

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() async {
    try {
      setState(() {
        _message = "Creating request...";
      });
      final requestId = await widget.createRequestFuture;
      setState(() {
        _requestId = requestId;
        _message = "Notifying nearby workers...";
      });

      // listen to request doc for status changes
      _sub = FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .snapshots()
          .listen((docSnap) {
        if (!docSnap.exists) return;
        final data = docSnap.data() as Map<String, dynamic>;
        final status = data['status'] as String? ?? 'pending';

        // if accepted, get worker details and navigate to tracking
        if (status == 'accepted' || status == 'continue') {
          final workerId = data['workerId'] as String? ?? '';
          final workerName = data['workerName'] as String? ?? '';
          final workerPhone = data['workerPhone'] as String? ?? '';
          final eta = data['eta']?.toString() ?? '';
          final serviceName = data['serviceName']?.toString() ?? widget.service.title;
          final charges = data['charges']?.toString() ?? widget.service.price;

          // cancel subscription before navigation
          _sub?.cancel();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => WorkerTrackingPage(
                workerId: workerId,
                workerName: workerName,
                workerPhone: workerPhone,
                eta: eta,
                serviceName: serviceName,
                charges: charges,
              ),
            ),
          );
        } else if (status == 'rejected') {
          setState(() {
            _message = "No worker accepted. Try again.";
          });
          // optionally navigate back after short delay
        } else {
          // still pending - keep showing
        }
      });
    } catch (e) {
      setState(() {
        _failed = true;
        _message = "Failed to create request: $e";
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // full screen waiting UI to avoid overflow dialogs
      appBar: AppBar(
        title: const Text("Waiting..."),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_failed) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 140,
                  width: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(strokeWidth: 6),
                      const Icon(Icons.hourglass_top, size: 48, color: Colors.blue),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  _message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 14),
                if (_requestId != null) SelectableText("Request ID: $_requestId"),
                const SizedBox(height: 22),
                ElevatedButton.icon(
                  onPressed: () {
                    // cancel and go back
                    _sub?.cancel();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.cancel),
                  label: const Text("Cancel Request"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                ),
              ] else ...[
                Icon(Icons.error_outline, size: 60, color: Colors.red.shade700),
                const SizedBox(height: 12),
                Text(_message, textAlign: TextAlign.center),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Back"),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
