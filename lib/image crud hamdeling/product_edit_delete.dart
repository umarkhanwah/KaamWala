import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'dart:html' as html;

import 'package:kam_wala_app/dashboard/admin_drawer.dart';
import 'package:kam_wala_app/image%20crud%20hamdeling/product_list_screen.dart';
import 'package:kam_wala_app/services/picker/picker_service.dart';

class FatchAll extends StatefulWidget {
  const FatchAll({super.key});

  @override
  State<FatchAll> createState() => _FatchAllState();
}

class _FatchAllState extends State<FatchAll> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Admindrawer(),
      appBar: AppBar(title: Text("Fetching Data"), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => ProductListScreen(category: category)),
          // );
        },
        child: Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            Center(child: Text("Error : ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No products found.'));
          }
          final products = snapshot.data!.docs;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index].data();
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
                              radius: 50, // Half of the container size
                              backgroundImage: MemoryImage(
                                base64Decode(product['Image']),
                              ),
                            ),
                          )
                          : Container(),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['protitle'] ?? 'No Title',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              product['Description'] ?? 'No Description',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            SizedBox(height: 8),
                            SizedBox(height: 8),
                            Text(
                              'Price: \$${product['price'] ?? 'N/A'}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // Call edit function and pass product data
                          editproduct(context, productId, product);
                        },
                      ),
                      // Delete button
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          // Call delete function
                          // _deleteProduct(productId);
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

  void editproduct(
    BuildContext context,
    String productId,
    Map<String, dynamic> product,
  ) {
    final proController = TextEditingController(text: product['protitle']);
    final desController = TextEditingController(text: product['Description']);
    final priceController = TextEditingController(
      text: product['price'].toString(),
    );
    String? uploadedImageBase64 = product['Image'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Product"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    controller: proController,
                    cursorColor: Colors.black,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      hintText: "Product",
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    controller: desController,
                    cursorColor: Colors.black,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      hintText: "Description",
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    controller: priceController,
                    cursorColor: Colors.black,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      hintText: "Price",
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),

                ElevatedButton(
                  onPressed:
                      () => _pickImage((base64) {
                        setState(() {
                          uploadedImageBase64 =
                              base64; // Update with new image data
                        });
                      }),
                  child: Text("Select Image"),
                ),
                if (uploadedImageBase64 != null)
                  Image.memory(
                    base64Decode(uploadedImageBase64!),
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                  ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _updateProduct(
                  productId,
                  proController.text,
                  desController.text,
                  priceController.text,
                  uploadedImageBase64,
                );
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Update"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context), // Close the dialog
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  final ImagePicker _picker = ImagePicker();
  String? _uploadedImageBase64;
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
  //       setState(() {
  //         _uploadedImageBase64 = base64Encode(data);
  //       });
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
}
