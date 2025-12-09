import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kam_wala_app/services/picker/picker_service.dart';
// import 'dart:html' as html;

class SalonDataAdd extends StatefulWidget {
  const SalonDataAdd({super.key});

  @override
  State<SalonDataAdd> createState() => _SalonDataAddState();
}

class _SalonDataAddState extends State<SalonDataAdd> {
  final productController = TextEditingController();
  final descController = TextEditingController();
  final priceController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _uploadedImageBase64;
  String? selectedCategory;
  List<String> categoryList = [];

  final databaseRef = FirebaseDatabase.instance.ref('saloonCategory');

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  void loadCategories() async {
    DatabaseEvent event = await databaseRef.once();
    DataSnapshot dataSnapshot = event.snapshot;
    Map<dynamic, dynamic>? data = dataSnapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      List<String> titles = [];
      data.forEach((key, value) {
        if (value is Map && value.containsKey("productName")) {
          titles.add(value['productName'].toString());
        }
      });
      setState(() {
        categoryList = titles;
      });
    }
  }

  // Future<void> pickImage() async {
  //   if (kIsWeb) {
  //     final html.FileUploadInputElement uploadInput =
  //         html.FileUploadInputElement();
  //     uploadInput.accept = "image/*";
  //     uploadInput.click();

  //     uploadInput.onChange.listen((e) async {
  //       final files = uploadInput.files;
  //       if (files!.isEmpty) return;
  //       final reader = html.FileReader();

  //       reader.readAsArrayBuffer(files[0]);
  //       reader.onLoadEnd.listen((e) async {
  //         final Uint8List data = reader.result as Uint8List;
  //         setState(() {
  //           _uploadedImageBase64 = base64Encode(data);
  //         });
  //         Fluttertoast.showToast(msg: "Image selected successfully");
  //       });
  //     });
  //   } else {
  //     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  //     if (image != null) {
  //       Uint8List data = await image.readAsBytes();
  //       setState(() {
  //         _uploadedImageBase64 = base64Encode(data);
  //       });
  //       Fluttertoast.showToast(msg: "Image selected successfully");
  //     }
  //   }
  // }

  Future<void> pickImage() async {
    try {
      final bytes = await pickerService.pickImageBytes();
      if (bytes == null) return;
      setState(() {
        _uploadedImageBase64 = base64Encode(bytes);
      });
      Fluttertoast.showToast(msg: "Image selected successfully");
    } catch (e) {
      Fluttertoast.showToast(msg: "Image pick error: $e");
    }
  }

  Future<void> addSalonProduct() async {
    if (productController.text.isNotEmpty &&
        descController.text.isNotEmpty &&
        priceController.text.isNotEmpty &&
        _uploadedImageBase64 != null &&
        selectedCategory != null) {
      try {
        await FirebaseFirestore.instance.collection('salonProducts').add({
          'title': productController.text,
          'description': descController.text,
          'price': priceController.text,
          'category': selectedCategory,
          'image': _uploadedImageBase64,
          'createdAt': DateTime.now(),
        });

        EasyLoading.showSuccess("Salon Product added successfully");

        productController.clear();
        descController.clear();
        priceController.clear();
        setState(() {
          _uploadedImageBase64 = null;
        });
      } catch (error) {
        EasyLoading.showError("Error adding product: $error");
      }
    } else {
      EasyLoading.showError("Please fill all fields before submitting");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "💇 Add Salon Service",
          style: TextStyle(
            color: Color(0xFFD81B60),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFFCE4EC), Color(0xFFF8BBD0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header
                const Text(
                  "Upload Salon serivce",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD81B60),
                  ),
                ),
                const SizedBox(height: 25),
                Image.asset("assets/pic/hairicon4.png", height: 240),
                const SizedBox(height: 20),

                // Card Container
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pinkAccent.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  width: screenWidth > 600 ? 600 : screenWidth,
                  child: Column(
                    children: [
                      // Dropdown
                      DropdownButtonFormField(
                        decoration: InputDecoration(
                          labelText: "Category",
                          labelStyle: const TextStyle(color: Color(0xFFD81B60)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        items:
                            categoryList.map((String title) {
                              return DropdownMenuItem<String>(
                                value: title,
                                child: Text(title),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCategory = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 15),

                      // Product TextField
                      TextField(
                        controller: productController,
                        decoration: const InputDecoration(
                          labelText: "Salon Name",
                          prefixIcon: Icon(Icons.spa, color: Color(0xFFD81B60)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Description TextField
                      TextField(
                        controller: descController,
                        decoration: const InputDecoration(
                          labelText: "Description",
                          prefixIcon: Icon(
                            Icons.description,
                            color: Color(0xFFD81B60),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Price TextField
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Price",
                          prefixIcon: Icon(
                            Icons.attach_money,
                            color: Color(0xFFD81B60),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Image preview
                      if (_uploadedImageBase64 != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Container(
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: const Color.fromARGB(255, 253, 123, 166),
                              ),
                              image: DecorationImage(
                                image: MemoryImage(
                                  base64Decode(_uploadedImageBase64!),
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),

                      // Upload Image Button
                      ElevatedButton.icon(
                        onPressed: pickImage,
                        icon: const Icon(Icons.add_a_photo),
                        label: const Text("Upload Image"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            228,
                            93,
                            142,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Post Button
                      ElevatedButton.icon(
                        onPressed: addSalonProduct,
                        icon: const Icon(Icons.send, color: Colors.white),
                        label: const Text(
                          "Post Salon Product",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD81B60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          elevation: 5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 125),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
