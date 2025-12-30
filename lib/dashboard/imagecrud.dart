import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kam_wala_app/dashboard/admin_drawer.dart';
import 'package:kam_wala_app/services/picker/picker_service.dart';

class DataAdd extends StatefulWidget {
  const DataAdd({super.key});

  @override
  State<DataAdd> createState() => _DataAddState();
}

class _DataAddState extends State<DataAdd> {
  final TextEditingController ProductController = TextEditingController();
  final TextEditingController DescController = TextEditingController();
  final TextEditingController PriceController = TextEditingController();

  String? _uploadedImageBase64;

  List<Map<String, String>> categories = [];
  Map<String, String>? selectedCategory;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  /// 🔹 Fetch categories
  Future<void> fetchCategories() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    setState(() {
      categories = snapshot.docs
          .map((d) => {'id': d.id, 'name': d['name'].toString()})
          .toList();
    });
  }

  /// 🔹 Pick Image
  Future<void> pickImage() async {
    final bytes = await pickerService.pickImageBytes();
    if (bytes == null) return;
    setState(() => _uploadedImageBase64 = base64Encode(bytes));
    Fluttertoast.showToast(msg: "Image selected");
  }

  /// 🔹 Add Service
  Future<void> addServiceToFirestore() async {
    if (ProductController.text.isEmpty ||
        DescController.text.isEmpty ||
        PriceController.text.isEmpty ||
        selectedCategory == null ||
        _uploadedImageBase64 == null) {
      EasyLoading.showError("Please fill all fields");
      return;
    }

    await FirebaseFirestore.instance.collection('services').add({
      'categoryId': selectedCategory!['id'],
      'categoryName': selectedCategory!['name'],
      'title': ProductController.text.trim(),
      'description': DescController.text.trim(),
      'price': PriceController.text.trim(),
      'imageBase64': _uploadedImageBase64,
      'createdAt': FieldValue.serverTimestamp(),
    });

    EasyLoading.showSuccess("Service Added");

    ProductController.clear();
    DescController.clear();
    PriceController.clear();

    setState(() {
      selectedCategory = null;
      _uploadedImageBase64 = null;
    });
  }

  /// 🔥 Delete confirmation
  Future<void> confirmDelete(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Service"),
        content: const Text("Are you sure you want to delete this service?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('services')
          .doc(docId)
          .delete();
      EasyLoading.showSuccess("Service deleted");
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      drawer: Admindrawer(),
      body: Container(
        height: double.infinity,
        
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
        
          child: SingleChildScrollView(
            
            padding: const EdgeInsets.all(25),
            child: Column(
              
              children: [
                const Text(
                  "Manage Services",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                /// 🧾 FORM CARD
                Container(
                  width: width > 600 ? 600 : width,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    children: [
                      /// Category
                      DropdownButtonFormField<Map<String, String>>(
                        value: selectedCategory,
                        decoration: const InputDecoration(labelText: "Category"),
                        items: categories
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c['name']!),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => selectedCategory = v),
                      ),

                      _field(ProductController, "Service Title", Icons.work),
                      _field(DescController, "Description", Icons.description),
                      _field(
                        PriceController,
                        "Price",
                        Icons.attach_money,
                        type: TextInputType.number,
                      ),

                      const SizedBox(height: 15),

                      /// 📷 IMAGE PICKER CARD
                      GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          height: 160,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blue),
                            image: _uploadedImageBase64 != null
                                ? DecorationImage(
                                    image: MemoryImage(
                                      base64Decode(_uploadedImageBase64!),
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _uploadedImageBase64 == null
                              ? Column(
                                
                                  mainAxisAlignment: MainAxisAlignment.center,
                              
                                  children: const [
                                    Icon(Icons.cloud_upload,
                                        size: 40, color: Colors.blue),
                                    SizedBox(height: 10),
                                    Text("Tap to upload image"),
                                  ],
                                )
                              : const Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Icon(Icons.edit, color: Colors.white),
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// 🚀 SUBMIT BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: addServiceToFirestore,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            backgroundColor: Colors.blue.shade900,
                          ),
                          child: const Text(
                            "Publish Service",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// 📋 SERVICES LIST
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('services')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    return Column(
                      children: snapshot.data!.docs.map((doc) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: MemoryImage(
                                base64Decode(doc['imageBase64']),
                              ),
                            ),
                            title: Text(doc['title']),
                            subtitle: Text("PKR ${doc['price']}"),
                            trailing: IconButton(
                              icon:
                                  const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => confirmDelete(doc.id),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String l, IconData i,
      {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: c,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: l,
          prefixIcon: Icon(i),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
