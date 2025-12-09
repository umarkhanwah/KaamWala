import 'dart:convert';
// import 'dart:html' as html;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import 'package:kam_wala_app/dashboard/admin_drawer.dart';
import 'package:kam_wala_app/services/picker/picker_service.dart';

class FatchAllplumber extends StatefulWidget {
  const FatchAllplumber({super.key});

  @override
  State<FatchAllplumber> createState() => _FatchAllplumberState();
}

class _FatchAllplumberState extends State<FatchAllplumber> {
  final ImagePicker _picker = ImagePicker();
  String? _uploadedImageBase64;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Admindrawer(),
      appBar: AppBar(title: const Text("Fetching Data"), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Adding a new product
          editproduct(context, null, {});
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error : ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No products found.'));
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index].data() as Map<String, dynamic>;
              final productId = products[index].id;

              return Card(
                margin: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 15,
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      product['Image'] != null
                          ? SizedBox(
                            height: 80,
                            width: 80,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: MemoryImage(
                                base64Decode(product['Image']),
                              ),
                            ),
                          )
                          : Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey,
                          ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['protitle'] ?? 'No Title',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product['Description'] ?? 'No Description',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Price: \$${product['price'] ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          editproduct(context, productId, product);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteProduct(productId);
                        },
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

  /// ====================== EDIT / ADD PRODUCT ======================
  void editproduct(
    BuildContext context,
    String? productId,
    Map<String, dynamic> product,
  ) {
    final proController = TextEditingController(text: product['protitle']);
    final desController = TextEditingController(text: product['Description']);
    final priceController = TextEditingController(
      text: product['price']?.toString() ?? "",
    );
    String? uploadedImageBase64 = product['Image'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(productId == null ? "Add Product" : "Edit Product"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(proController, "Product Title"),
                _buildTextField(desController, "Description"),
                _buildTextField(priceController, "Price", isNumber: true),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed:
                      () => _pickImage((base64) {
                        setState(() {
                          uploadedImageBase64 = base64;
                        });
                      }),
                  child: const Text("Select Image"),
                ),
                if (uploadedImageBase64 != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.memory(
                      base64Decode(uploadedImageBase64!),
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (productId == null) {
                  _addProduct(
                    proController.text,
                    desController.text,
                    priceController.text,
                    uploadedImageBase64,
                  );
                } else {
                  _updateProduct(
                    productId,
                    proController.text,
                    desController.text,
                    priceController.text,
                    uploadedImageBase64,
                  );
                }
                Navigator.pop(context);
              },
              child: Text(productId == null ? "Add" : "Update"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  /// ====================== IMAGE PICKER ======================
  // Future<void> _pickImage(Function(String) onImagePicked) async {
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
  //         String base64Image = base64Encode(data);
  //         onImagePicked(base64Image);
  //         Fluttertoast.showToast(msg: "Image selected successfully");
  //       });
  //     });
  //   } else {
  //     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  //     if (image != null) {
  //       Uint8List data = await image.readAsBytes();
  //       String base64Image = base64Encode(data);
  //       onImagePicked(base64Image);
  //       Fluttertoast.showToast(msg: "Image selected successfully");
  //     }
  //   }
  // }
  Future<void> _pickImage(Function(String) onImagePicked) async {
    try {
      final bytes = await pickerService.pickImageBytes();
      if (bytes == null) return;
      final base64Image = base64Encode(bytes);
      onImagePicked(base64Image);
      Fluttertoast.showToast(msg: "Image selected successfully");
    } catch (e) {
      Fluttertoast.showToast(msg: "Image pick error: $e");
    }
  }

  /// ====================== FIRESTORE CRUD ======================
  Future<void> _addProduct(
    String title,
    String description,
    String price,
    String? imageBase64,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('products').add({
        'protitle': title,
        'Description': description,
        'price': price,
        'Image': imageBase64,
      });
      Fluttertoast.showToast(msg: "Product added successfully");
    } catch (error) {
      Fluttertoast.showToast(msg: "Error adding product: $error");
    }
  }

  Future<void> _updateProduct(
    String productId,
    String title,
    String description,
    String price,
    String? imageBase64,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .update({
            'protitle': title,
            'Description': description,
            'price': price,
            'Image': imageBase64,
          });
      Fluttertoast.showToast(msg: "Product updated successfully");
    } catch (error) {
      Fluttertoast.showToast(msg: "Error updating product: $error");
    }
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .delete();
      Fluttertoast.showToast(msg: "Product deleted successfully");
    } catch (error) {
      Fluttertoast.showToast(msg: "Error deleting product: $error");
    }
  }

  /// ====================== HELPER WIDGET ======================
  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
      ),
    );
  }
}
