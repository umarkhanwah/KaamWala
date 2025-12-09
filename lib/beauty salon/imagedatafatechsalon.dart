import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kam_wala_app/services/picker/picker_service.dart';
// import 'dart:html' as html;

class FetchAllProducts extends StatefulWidget {
  const FetchAllProducts({super.key});

  @override
  State<FetchAllProducts> createState() => _FetchAllProductsState();
}

class _FetchAllProductsState extends State<FetchAllProducts> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  String? _editedName;
  String? _editedPrice;
  String? _editedDescription;
  String? _editedImage;

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

  //         setState(() {
  //           onImagePicked(base64Image);
  //         });

  //         Fluttertoast.showToast(msg: "Image selected successfully");
  //       });
  //     });
  //   } else {
  //     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  //     if (image != null) {
  //       Uint8List data = await image.readAsBytes();
  //       String base64Image = base64Encode(data);

  //       setState(() {
  //         onImagePicked(base64Image);
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
      setState(() => onImagePicked(base64Image));
      Fluttertoast.showToast(msg: "Image selected successfully");
    } catch (e) {
      Fluttertoast.showToast(msg: "Image pick error: $e");
    }
  }

  void _editProduct(String docId, Map<String, dynamic> product) {
    _editedName = product['Name'];
    _editedPrice = product['Price'];
    _editedDescription = product['Description'];
    _editedImage = product['Image'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.pink[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "Edit Product",
            style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap:
                      () => _pickImage((newImage) {
                        _editedImage = newImage;
                      }),
                  child: CircleAvatar(
                    radius: 45,
                    backgroundImage:
                        _editedImage != null
                            ? MemoryImage(base64Decode(_editedImage!))
                            : null,
                    backgroundColor: Colors.pink[100],
                    child:
                        _editedImage == null
                            ? const Icon(Icons.camera_alt, color: Colors.white)
                            : null,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Product Name",
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: _editedName),
                  onChanged: (value) => _editedName = value,
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Price",
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: _editedPrice),
                  onChanged: (value) => _editedPrice = value,
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: _editedDescription),
                  onChanged: (value) => _editedDescription = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
              child: const Text(
                "Update",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                await _firestore.collection('Products').doc(docId).update({
                  'Name': _editedName,
                  'Price': _editedPrice,
                  'Description': _editedDescription,
                  'Image': _editedImage,
                });
                Fluttertoast.showToast(msg: "Product updated successfully");
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteProduct(String docId) async {
    await _firestore.collection('Products').doc(docId).delete();
    Fluttertoast.showToast(msg: "Product deleted successfully");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: const Text("All Products"),
        centerTitle: true,
        elevation: 5,
      ),
      body: StreamBuilder(
        stream: _firestore.collection('Products').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.pink),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Products Found"));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var product = snapshot.data!.docs[index];
              var productData = product.data() as Map<String, dynamic>;

              return Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: MemoryImage(
                        base64Decode(productData['Image']),
                      ),
                      backgroundColor: Colors.pink[100],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      productData['Name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.pink,
                      ),
                    ),
                    Text(
                      "Rs. ${productData['Price']}",
                      style: const TextStyle(color: Colors.black54),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        productData['Description'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.pink),
                          onPressed:
                              () => _editProduct(product.id, productData),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteProduct(product.id),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
