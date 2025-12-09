import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kam_wala_app/image%20crud%20hamdeling/product_model.dart';
import 'package:kam_wala_app/image%20crud%20hamdeling/worker_tracking_page.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductListScreennew extends StatefulWidget {
  final String category;
  final String currentUserId;

  const ProductListScreennew({
    super.key,
    required this.category,
    required this.currentUserId,
  });

  @override
  State<ProductListScreennew> createState() => _ProductListScreennewState();

  // Worker acceptance helper (used in WorkerRequestsPage)
  static Future<void> workerAcceptRequest({
    required String requestId,
    required String workerId,
    required String workerName,
    required String eta,
    String? workerPhone,
  }) async {
    final requestRef = FirebaseFirestore.instance
        .collection("requests")
        .doc(requestId);

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snapshot = await tx.get(requestRef);
      if (!snapshot.exists) throw Exception("Request not found");
      final data = snapshot.data() as Map<String, dynamic>;
      final status = data['status'] ?? 'pending';

      if (status == 'pending') {
        tx.update(requestRef, {
          "status": "accepted",
          "workerId": workerId,
          "workerName": workerName,
          "eta": eta,
          "workerPhone": workerPhone ?? FieldValue.delete(),
          "acceptedAt": FieldValue.serverTimestamp(),
        });
      } else {
        throw Exception("Request already taken");
      }
    });
  }
}

class _ProductListScreennewState extends State<ProductListScreennew> {
  final Duration requestTimeout = const Duration(seconds: 30);

  /// 🔔 FCM server key (tum apni Firebase console → Project Settings → Cloud Messaging se copy karna)
  static const String serverKey = "YOUR_FIREBASE_SERVER_KEY";

  Future<List<ProductModel>> fetchProductsByCategory() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('products')
            .where('Category', isEqualTo: widget.category)
            .get();

    return snapshot.docs
        .map((doc) => ProductModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<List<Map<String, dynamic>>> fetchWorkers() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection("users")
            .where("role", isEqualTo: "worker")
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['uid'] = doc.id;
      return data;
    }).toList();
  }

  /// 🔔 Send push notification to worker
  Future<void> sendNotificationToWorker(
    String token,
    String title,
    String body,
  ) async {
    final response = await http.post(
      Uri.parse("https://fcm.googleapis.com/fcm/send"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "key=$serverKey",
      },
      body: jsonEncode({
        "to": token,
        "notification": {"title": title, "body": body, "sound": "default"},
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "status": "new_request",
        },
      }),
    );

    if (response.statusCode != 200) {
      debugPrint("❌ Failed to send notification: ${response.body}");
    }
  }

  /// Create request + notify nearby workers
  Future<String> _createServiceRequest(ProductModel product) async {
    final workers = await fetchWorkers();
    final nearbyWorkerIds = workers.map((w) => w['uid']).toList();

    final docRef = await FirebaseFirestore.instance.collection("requests").add({
      "userId": widget.currentUserId,
      "serviceName": product.protitle,
      "charges": product.price,
      "status": "pending",
      "workerId": null,
      "workerName": null,
      "eta": null,
      "workerPhone": null,
      "nearbyWorkers": nearbyWorkerIds,
      "productId": product.id,
      "productSnapshot": {
        "title": product.protitle,
        "price": product.price,
        "description": product.description,
      },
      "timestamp": FieldValue.serverTimestamp(),
    });

    /// 🔔 Send notification to each worker
    for (final worker in workers) {
      if (worker['fcmToken'] != null) {
        await sendNotificationToWorker(
          worker['fcmToken'],
          "New Request: ${product.protitle}",
          "Charges: Rs.${product.price}",
        );
      }
    }

    return docRef.id;
  }

  void _startServiceRequestFlow(
    BuildContext context,
    ProductModel product,
  ) async {
    String requestId;
    try {
      requestId = await _createServiceRequest(product);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create request.")),
      );
      return;
    }

    _showRadarAnimation(context);

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      _showPendingRequestSheet(context, product, requestId);
    });
  }

  // Radar animation (no change)
  void _showRadarAnimation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ...List.generate(3, (i) {
                    return AnimatedContainer(
                      duration: Duration(seconds: 2 + i),
                      curve: Curves.easeInOutCubic,
                      width: 220 - (i * 60).toDouble(),
                      height: 220 - (i * 60).toDouble(),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.cyanAccent.withOpacity(0.25),
                            Colors.teal.withOpacity(0.05),
                          ],
                          stops: const [0.2, 1],
                        ),
                      ),
                    );
                  }),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.cyanAccent.withOpacity(0.8),
                          Colors.tealAccent.withOpacity(0.6),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.radar,
                      size: 70,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // Bottom sheet (same as before)
  void _showPendingRequestSheet(
    BuildContext context,
    ProductModel product,
    String requestId,
  ) {
    StreamSubscription<DocumentSnapshot>? subscription;
    Timer? timeoutTimer;

    timeoutTimer = Timer(requestTimeout, () async {
      final doc =
          await FirebaseFirestore.instance
              .collection("requests")
              .doc(requestId)
              .get();
      if (doc.exists && doc.data()?['status'] == 'pending') {
        await FirebaseFirestore.instance
            .collection("requests")
            .doc(requestId)
            .update({"status": "timeout"});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No worker accepted within time. Try again."),
            ),
          );
        }
      }
      try {
        Navigator.of(context).maybePop();
      } catch (_) {}
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color.fromARGB(255, 140, 212, 245),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (contextSheet) {
        return StatefulBuilder(
          builder: (context2, setState) {
            String currentStatus = "pending";
            String workerName = "";
            String workerId = "";
            String eta = "";
            String workerPhone = "";

            subscription ??= FirebaseFirestore.instance
                .collection("requests")
                .doc(requestId)
                .snapshots()
                .listen((docSnap) {
                  if (!docSnap.exists) return;
                  final data = docSnap.data() as Map<String, dynamic>;
                  final newStatus = data['status'] as String? ?? 'pending';
                  setState(() {
                    currentStatus = newStatus;
                    workerName = data['workerName'] ?? "";
                    workerId = data['workerId'] ?? "";
                    eta = data['eta'] ?? "";
                    workerPhone = data['workerPhone'] ?? "";
                  });

                  if (newStatus == 'accepted') {
                    timeoutTimer?.cancel();
                    subscription?.cancel();
                    Navigator.of(context2).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => WorkerTrackingPage(
                              workerId: workerId,
                              workerName: workerName,
                              workerPhone: workerPhone,
                              eta: eta,
                              serviceName: product.protitle,
                              charges: product.price,
                            ),
                      ),
                    );
                  } else if (newStatus == 'rejected' ||
                      newStatus == 'timeout') {
                    timeoutTimer?.cancel();
                    subscription?.cancel();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Request ended with status: $newStatus",
                          ),
                        ),
                      );
                    }
                    Navigator.of(context2).pop();
                  }
                });

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context2).viewInsets.bottom + 20,
                left: 22,
                right: 22,
                top: 18,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 5,
                    width: 60,
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  Text(
                    currentStatus == 'pending'
                        ? "Searching for Worker..."
                        : "Status: ${currentStatus.toUpperCase()}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (currentStatus == 'pending') ...[
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    const Text(
                      "We're notifying nearby workers. Please wait...",
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          243,
                          204,
                          114,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 20,
                        ),
                      ),
                      icon: const Icon(Icons.cancel),
                      label: const Text("Cancel Request"),
                      onPressed: () async {
                        timeoutTimer?.cancel();
                        subscription?.cancel();
                        await FirebaseFirestore.instance
                            .collection("requests")
                            .doc(requestId)
                            .update({"status": "cancelled"});
                        Navigator.of(context2).pop();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Request cancelled")),
                          );
                        }
                      },
                    ),
                  ] else if (currentStatus == 'accepted') ...[
                    const SizedBox(height: 8),
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        workerName.isNotEmpty
                            ? workerName[0].toUpperCase()
                            : "W",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text("Worker: $workerName"),
                    Text("Worker ID: $workerId"),
                    Text("ETA: $eta"),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.phone),
                      label: const Text("Call Worker"),
                      onPressed: () {
                        if (workerPhone.isNotEmpty) {
                          launchUrl(Uri.parse("tel:$workerPhone"));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      timeoutTimer?.cancel();
      subscription?.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff1f7fe),
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
          widget.category,
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
      body: FutureBuilder<List<ProductModel>>(
        future: fetchProductsByCategory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error fetching products"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No Products Found"));
          }

          final products = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return GestureDetector(
                onTap: () => _startServiceRequestFlow(context, product),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.blue.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.15),
                        blurRadius: 8,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child:
                            product.image.isNotEmpty
                                ? Image.memory(
                                  base64Decode(product.image),
                                  width: 180,
                                  height: 150,
                                  fit: BoxFit.cover,
                                )
                                : Container(
                                  width: 200,
                                  height: 200,
                                  color: Colors.blue.shade100,
                                  child: const Icon(
                                    Icons.image,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.protitle,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff0a7bfc),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              product.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Rs. ${product.price}",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
