import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkerWallet extends StatefulWidget {
  const WorkerWallet({super.key});

  @override
  State<WorkerWallet> createState() => _WorkerWalletState();
}

class _WorkerWalletState extends State<WorkerWallet> {
  double walletAmount = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final snap =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();

    if (snap.exists) {
      setState(() {
        walletAmount = (snap.data()?['walletAmount'] ?? 0).toDouble();
        loading = false;
      });
    } else {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      // ❌ No AppBar Title (WorkerPanel already shows header)

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
                    icon: const Icon(Icons.add , color:  Colors.white),
                    label: const Text("Deposit", style: TextStyle(color: Colors.white , fontWeight: FontWeight.bold),),
                    onPressed: () {
                      // TODO: Deposit logic
                    },
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
                    icon: const Icon(Icons.remove , color: Colors.black,),
                    label: const Text("Withdraw", style: TextStyle(color: const Color(0xFF1E3C72), fontWeight: FontWeight.bold),),
                    onPressed: walletAmount <= 0
                        ? null
                        : () {
                            // TODO: Withdraw logic
                          },
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
              child: Row(
                children: const [
                  Icon(Icons.info_outline, color: Color(0xFF1E3C72)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Wallet system is under enhancement. Deposits & withdrawals will be enabled soon.",
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
