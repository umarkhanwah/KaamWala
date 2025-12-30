import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminWorkerWalletScreen extends StatefulWidget {
  const AdminWorkerWalletScreen({super.key});

  @override
  State<AdminWorkerWalletScreen> createState() =>
      _AdminWorkerWalletScreenState();
}

class _AdminWorkerWalletScreenState extends State<AdminWorkerWalletScreen> {
  final TextEditingController amountController = TextEditingController();

  /// 🔁 Update Wallet
  Future<void> _updateWallet({
    required String uid,
    required double currentAmount,
    required bool isAdd,
    required String workerName,
  }) async {
    final enteredAmount = double.tryParse(amountController.text.trim());

    if (enteredAmount == null || enteredAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid amount")),
      );
      return;
    }

    final newAmount =
        isAdd ? currentAmount + enteredAmount : currentAmount - enteredAmount;

    if (newAmount < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Wallet cannot go negative")),
      );
      return;
    }

    /// 🔐 Confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Action"),
        content: Text(
          "${isAdd ? "Add" : "Subtract"} Rs $enteredAmount "
          "${isAdd ? "to" : "from"} $workerName's wallet?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    /// 🔥 Firestore Update
    await FirebaseFirestore.instance.collection("users").doc(uid).update({
      "walletAmount": newAmount,
      "walletUpdatedAt": FieldValue.serverTimestamp(),
    });

    amountController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Wallet updated successfully",
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text("Worker Wallet Management"),
        backgroundColor: const Color(0xFF1E3C72),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .where("role", isEqualTo: "worker")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No workers found"));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final name = data['name'] ?? "Worker";
              final wallet =
                  (data['walletAmount'] ?? 0).toDouble();

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 👤 Worker Info
                      Row(
                        children: [
                          const Icon(Icons.person, color: Color(0xFF1E3C72)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            "Rs ${wallet.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      /// 💰 Amount Field
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Enter amount",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// ➕➖ Actions
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text("Add"),
                              onPressed: () => _updateWallet(
                                uid: doc.id,
                                currentAmount: wallet,
                                isAdd: true,
                                workerName: name,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.remove),
                              label: const Text("Subtract"),
                              onPressed: () => _updateWallet(
                                uid: doc.id,
                                currentAmount: wallet,
                                isAdd: false,
                                workerName: name,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
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
