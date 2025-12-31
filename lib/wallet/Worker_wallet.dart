import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert'; // ✅ JSON encoding ke liye
import 'package:http/http.dart' as http; // ✅ API call ke liye
import 'package:url_launcher/url_launcher.dart'; // ✅ Browser kholne ke liye

class WorkerWallet extends StatefulWidget {
  const WorkerWallet({super.key});

  @override
  State<WorkerWallet> createState() => _WorkerWalletState();
}

class _WorkerWalletState extends State<WorkerWallet> {
  double walletAmount = 0;
  bool loading = true;
  bool isProcessing = false; // ✅ Payment loading state

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

Future<void> _handleWithdraw() async {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController bankDetailsController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Withdraw Money"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: amountController, decoration: const InputDecoration(labelText: "Amount"), keyboardType: TextInputType.number),
          TextField(controller: bankDetailsController, decoration: const InputDecoration(labelText: "Bank Name & Account No"), maxLines: 2),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () async {
            double amount = double.tryParse(amountController.text) ?? 0;
            if (amount > 0 && amount <= walletAmount) {
              final uid = FirebaseAuth.instance.currentUser!.uid;
              
              // 1. Create a request in Firestore
              await FirebaseFirestore.instance.collection("withdraw_requests").add({
                "workerId": uid,
                "amount": amount,
                "bankDetails": bankDetailsController.text,
                "status": "pending",
                "createdAt": FieldValue.serverTimestamp(),
              });

              // 2. Temporarily deduct/hold amount (Optional but recommended)
              await FirebaseFirestore.instance.collection("users").doc(uid).update({
                "walletAmount": walletAmount - amount,
              });

              Navigator.pop(context);
              _showError("Withdraw request submitted!");
            } else {
              _showError("Invalid amount or insufficient balance");
            }
          },
          child: const Text("Submit Request"),
        ),
      ],
    ),
  );
}
  Future<void> _loadWallet() async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  
  FirebaseFirestore.instance.collection("users").doc(uid).snapshots().listen((snap) {
    if (snap.exists) {
      if (mounted) {
        setState(() {
          // Humne yahan 'walletAmount' use kiya hai
          walletAmount = (snap.data()?['walletAmount'] ?? 0).toDouble();
          loading = false;
        });
      }
    }
  });
}

Future<void> _showDepositDialog() async {
  final TextEditingController amountController = TextEditingController();
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Deposit Money"),
      content: TextField(
        controller: amountController,
        decoration: const InputDecoration(
          hintText: "Enter amount (e.g. 500)",
          prefixText: "Rs ",
        ),
        keyboardType: TextInputType.number,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () {
            double amt = double.tryParse(amountController.text) ?? 0;
            if (amt >= 100) { // Safepay minimum limit aksar 100 hoti hai
              Navigator.pop(context);
              _handleDeposit(amt); // Amount pass kar rahe hain
            } else {
              _showError("Minimum deposit is Rs 100");
            }
          },
          child: const Text("Proceed"),
        ),
      ],
    ),
  );
}
  // ✅ DEPOSIT FUNCTION
  Future<void> _handleDeposit(double amount) async {
    // setState(() => isProcessing = true);

    // try {
    //   final String uid = FirebaseAuth.instance.currentUser!.uid;
    //   const double amount = 500.0; // Filhal fix amount, aap input le sakte hain

    //   final response = await http.post(
    //     // 🚨 APNA FUNCTION URL YAHAN PASTE KAREIN
    //     Uri.parse('https://createsafepaycheckout-bmy5zehieq-uc.a.run.app'),
    //     headers: {"Content-Type": "application/json"},
    //     body: jsonEncode({
    //       "amount": amount,
    //       "workerId": uid,
    //     }),
    //   );
setState(() => isProcessing = true);
  try {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    final response = await http.post(
      Uri.parse('https://createsafepaycheckout-bmy5zehieq-uc.a.run.app'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "amount": amount,
        "workerId": uid,
      }),
    );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String checkoutUrl = data['url'];

        if (await canLaunchUrl(Uri.parse(checkoutUrl))) {
          await launchUrl(Uri.parse(checkoutUrl), mode: LaunchMode.externalApplication);
        }
      } else {
        _showError("Failed to initialize payment. Please try again.");
      }
    } catch (e) {
      _showError("Connection error. Check your internet.");
      print(e);
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 💳 WALLET CARD
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Available Balance",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Rs ${walletAmount.toStringAsFixed(0)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    const Spacer(),
                    const Align(
                      alignment: Alignment.bottomRight,
                      child: Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white70,
                        size: 42,
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// ➕➖ ACTION BUTTONS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: isProcessing 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.add, color: Colors.white),
                    label: Text(
                      isProcessing ? "Wait..." : "Deposit", 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    onPressed: isProcessing ? null : _showDepositDialog, // ✅ Logic Linked
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3C72),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.remove, color: Colors.white),
                    label: const Text("Withdraw", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                   onPressed: walletAmount <= 0 ? null : _handleWithdraw,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            /// ℹ️ INFO CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.security, color: Color(0xFF1E3C72)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Payments are secured by Safepay. Your balance will be updated instantly after a successful transaction.",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}