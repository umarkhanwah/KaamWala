// import 'dart:convert';
// import 'dart:html' as html;

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:image_picker/image_picker.dart';

// import 'package:kam_wala_app/dashboard/admin_drawer.dart';

// class FatchAllSalon extends StatefulWidget {
//   const FatchAllSalon({super.key});

//   @override
//   State<FatchAllSalon> createState() => _FatchAllSalonState();
// }

// class _FatchAllSalonState extends State<FatchAllSalon> {
//   final ImagePicker _picker = ImagePicker();
//   String? _uploadedImageBase64;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: Admindrawer(),
//       appBar: AppBar(title: const Text("Fetching Data"), centerTitle: true),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Adding a new product
//           editproduct(context, null, {});
//         },
//         child: const Icon(Icons.add),
//       ),
//       body: StreamBuilder(
//         stream: FirebaseFirestore.instance.collection('products').snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text("Error : ${snapshot.error}"));
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text('No products found.'));
//           }

//           final products = snapshot.data!.docs;

//           return ListView.builder(
//             itemCount: products.length,
//             itemBuilder: (context, index) {
//               final product = products[index].data() as Map<String, dynamic>;
//               final productId = products[index].id;

//               return Card(
//                 margin: const EdgeInsets.symmetric(
//                   vertical: 10,
//                   horizontal: 15,
//                 ),
//                 elevation: 3,
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Row(
//                     children: [
//                       product['Image'] != null
//                           ? SizedBox(
//                             height: 80,
//                             width: 80,
//                             child: CircleAvatar(
//                               radius: 50,
//                               backgroundImage: MemoryImage(
//                                 base64Decode(product['Image']),
//                               ),
//                             ),
//                           )
//                           : Container(
//                             width: 80,
//                             height: 80,
//                             color: Colors.grey,
//                           ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               product['protitle'] ?? 'No Title',
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               product['Description'] ?? 'No Description',
//                               style: const TextStyle(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.normal,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               'Price: \$${product['price'] ?? 'N/A'}',
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.edit),
//                         onPressed: () {
//                           editproduct(context, productId, product);
//                         },
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.delete, color: Colors.red),
//                         onPressed: () {
//                           _deleteProduct(productId);
//                         },
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

//   /// ====================== EDIT / ADD PRODUCT ======================
//   void editproduct(
//     BuildContext context,
//     String? productId,
//     Map<String, dynamic> product,
//   ) {
//     final proController = TextEditingController(text: product['protitle']);
//     final desController = TextEditingController(text: product['Description']);
//     final priceController = TextEditingController(
//       text: product['price']?.toString() ?? "",
//     );
//     String? uploadedImageBase64 = product['Image'];

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(productId == null ? "Add Product" : "Edit Product"),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _buildTextField(proController, "Product Title"),
//                 _buildTextField(desController, "Description"),
//                 _buildTextField(priceController, "Price", isNumber: true),
//                 const SizedBox(height: 8),
//                 ElevatedButton(
//                   onPressed:
//                       () => _pickImage((base64) {
//                         setState(() {
//                           uploadedImageBase64 = base64;
//                         });
//                       }),
//                   child: const Text("Select Image"),
//                 ),
//                 if (uploadedImageBase64 != null)
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Image.memory(
//                       base64Decode(uploadedImageBase64!),
//                       height: 80,
//                       width: 80,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           actions: [
//             ElevatedButton(
//               onPressed: () {
//                 if (productId == null) {
//                   _addProduct(
//                     proController.text,
//                     desController.text,
//                     priceController.text,
//                     uploadedImageBase64,
//                   );
//                 } else {
//                   _updateProduct(
//                     productId,
//                     proController.text,
//                     desController.text,
//                     priceController.text,
//                     uploadedImageBase64,
//                   );
//                 }
//                 Navigator.pop(context);
//               },
//               child: Text(productId == null ? "Add" : "Update"),
//             ),
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Cancel"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   /// ====================== IMAGE PICKER ======================
//   Future<void> _pickImage(Function(String) onImagePicked) async {
//     if (kIsWeb) {
//       final html.FileUploadInputElement uploadInput =
//           html.FileUploadInputElement();
//       uploadInput.accept = "image/*";
//       uploadInput.click();

//       uploadInput.onChange.listen((e) async {
//         final files = uploadInput.files;
//         if (files!.isEmpty) return;
//         final reader = html.FileReader();

//         reader.readAsArrayBuffer(files[0]);
//         reader.onLoadEnd.listen((e) async {
//           final Uint8List data = reader.result as Uint8List;
//           String base64Image = base64Encode(data);
//           onImagePicked(base64Image);
//           Fluttertoast.showToast(msg: "Image selected successfully");
//         });
//       });
//     } else {
//       final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//       if (image != null) {
//         Uint8List data = await image.readAsBytes();
//         String base64Image = base64Encode(data);
//         onImagePicked(base64Image);
//         Fluttertoast.showToast(msg: "Image selected successfully");
//       }
//     }
//   }

//   /// ====================== FIRESTORE CRUD ======================
//   Future<void> _addProduct(
//     String title,
//     String description,
//     String price,
//     String? imageBase64,
//   ) async {
//     try {
//       await FirebaseFirestore.instance.collection('products').add({
//         'protitle': title,
//         'Description': description,
//         'price': price,
//         'Image': imageBase64,
//       });
//       Fluttertoast.showToast(msg: "Product added successfully");
//     } catch (error) {
//       Fluttertoast.showToast(msg: "Error adding product: $error");
//     }
//   }

//   Future<void> _updateProduct(
//     String productId,
//     String title,
//     String description,
//     String price,
//     String? imageBase64,
//   ) async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('products')
//           .doc(productId)
//           .update({
//             'protitle': title,
//             'Description': description,
//             'price': price,
//             'Image': imageBase64,
//           });
//       Fluttertoast.showToast(msg: "Product updated successfully");
//     } catch (error) {
//       Fluttertoast.showToast(msg: "Error updating product: $error");
//     }
//   }

//   Future<void> _deleteProduct(String productId) async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('products')
//           .doc(productId)
//           .delete();
//       Fluttertoast.showToast(msg: "Product deleted successfully");
//     } catch (error) {
//       Fluttertoast.showToast(msg: "Error deleting product: $error");
//     }
//   }

//   /// ====================== HELPER WIDGET ======================
//   Widget _buildTextField(
//     TextEditingController controller,
//     String hint, {
//     bool isNumber = false,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.all(10.0),
//       child: TextField(
//         controller: controller,
//         keyboardType: isNumber ? TextInputType.number : TextInputType.text,
//         decoration: InputDecoration(
//           hintText: hint,
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:convert';
// import 'dart:html' as html; // safe: guarded by kIsWeb

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kam_wala_app/services/picker/picker_service.dart';

// import 'package:kam_wala_app/dashboard/admin_drawer.dart'; // uncomment if you have it

class FatchAllSalon extends StatefulWidget {
  const FatchAllSalon({super.key});

  @override
  State<FatchAllSalon> createState() => _FatchAllSalonState();
}

class _FatchAllSalonState extends State<FatchAllSalon> {
  static const String kCollection = 'salonProducts';
  final ImagePicker _picker = ImagePicker();

  // Optional: load categories from Realtime DB like your add page
  // If you don't need dropdown-driven categories in edit/add dialog, you can remove this block
  List<String> categoryList = [];
  bool _loadingCats = false;

  @override
  void initState() {
    super.initState();
    _maybeLoadCategoriesFromRTDB();
  }

  Future<void> _maybeLoadCategoriesFromRTDB() async {
    // If you're not using RTDB for categories, comment this whole function.
    try {
      setState(() => _loadingCats = true);
      // Mirror of your add page path/shape:
      // FirebaseDatabase.instance.ref('saloonCategory')...
      // Since this file doesn't have firebase_database import, we keep category editable as free text.
      // TIP: If you need RTDB dropdown here too, add firebase_database and copy the same loader.
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _loadingCats = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: Admindrawer(),
      appBar: AppBar(
        title: const Text("All Salon Services"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Option A: Open Dialog (keeps UX in one page)
          _openEditDialog(context, null, {});
          // Option B: Navigate to your add page instead:
          // Navigator.push(context, MaterialPageRoute(builder: (_) => const SalonDataAdd()));
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection(kCollection)
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text("Error: ${snap.error}"));
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(child: Text("No salon services found."));
          }

          final docs = snap.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final doc = docs[i];
              final data = doc.data() as Map<String, dynamic>? ?? {};
              final imageB64 = data['image'] as String?;
              final title = (data['title'] ?? '').toString();
              final desc = (data['description'] ?? '').toString();
              final price = (data['price'] ?? '').toString();
              final category = (data['category'] ?? '').toString();

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildThumb(imageB64),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    title.isEmpty ? 'Untitled Service' : title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                if (category.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.pink.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      category,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.pink,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              desc.isEmpty ? 'No description' : desc,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              price.isEmpty ? 'Price: N/A' : 'Price: $price',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                IconButton(
                                  tooltip: 'Edit',
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed:
                                      () => _openEditDialog(
                                        context,
                                        doc.id,
                                        data,
                                      ),
                                ),
                                IconButton(
                                  tooltip: 'Delete',
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _delete(doc.id),
                                ),
                              ],
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

  Widget _buildThumb(String? base64) {
    if (base64 == null || base64.isEmpty) {
      return Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.image_not_supported),
      );
    }
    Uint8List bytes;
    try {
      bytes = base64Decode(base64);
    } catch (_) {
      return Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.broken_image),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.memory(bytes, width: 84, height: 84, fit: BoxFit.cover),
    );
  }

  // ========= Add / Edit Dialog =========
  void _openEditDialog(
    BuildContext context,
    String? id,
    Map<String, dynamic> data,
  ) {
    final titleC = TextEditingController(
      text: (data['title'] ?? '').toString(),
    );
    final descC = TextEditingController(
      text: (data['description'] ?? '').toString(),
    );
    final priceC = TextEditingController(
      text: (data['price'] ?? '').toString(),
    );
    final catC = TextEditingController(
      text: (data['category'] ?? '').toString(),
    );

    String? imageB64 =
        (data['image'] ?? '') is String ? data['image'] as String : null;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(id == null ? 'Add Salon Service' : 'Edit Salon Service'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _tf(titleC, 'Title'),
                _tf(descC, 'Description'),
                _tf(priceC, 'Price', isNumber: true),
                _tf(catC, 'Category'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final picked = await _pickImageBase64();
                        if (picked != null) {
                          setState(() => imageB64 = picked);
                          Fluttertoast.showToast(msg: "Image selected");
                        }
                      },
                      icon: const Icon(Icons.add_a_photo),
                      label: const Text('Select Image'),
                    ),
                    const SizedBox(width: 10),
                    if (imageB64 != null && imageB64!.isNotEmpty)
                      const Icon(Icons.check_circle, color: Colors.green),
                  ],
                ),
                const SizedBox(height: 8),
                if (imageB64 != null && imageB64!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      base64Decode(imageB64!),
                      height: 90,
                      width: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final payload = {
                  'title': titleC.text.trim(),
                  'description': descC.text.trim(),
                  'price': priceC.text.trim(),
                  'category': catC.text.trim(),
                  'image': imageB64,
                };

                if (id == null) {
                  await FirebaseFirestore.instance.collection(kCollection).add({
                    ...payload,
                    'createdAt': DateTime.now(),
                  });
                  Fluttertoast.showToast(msg: "Service added");
                } else {
                  await FirebaseFirestore.instance
                      .collection(kCollection)
                      .doc(id)
                      .update(payload);
                  Fluttertoast.showToast(msg: "Service updated");
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(id == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  Widget _tf(TextEditingController c, String hint, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  // Future<String?> _pickImageBase64() async {
  //   try {
  //     if (kIsWeb) {
  //       final input = html.FileUploadInputElement()..accept = 'image/*';
  //       input.click();
  //       final c = Completer<String?>();
  //       input.onChange.listen((event) {
  //         final file = input.files?.first;
  //         if (file == null) return c.complete(null);
  //         final reader = html.FileReader();
  //         reader.readAsArrayBuffer(file);
  //         reader.onLoadEnd.listen((e) {
  //           final data = reader.result as Uint8List;
  //           c.complete(base64Encode(data));
  //         });
  //       });
  //       return c.future;
  //     } else {
  //       final XFile? image = await _picker.pickImage(
  //         source: ImageSource.gallery,
  //       );
  //       if (image == null) return null;
  //       final bytes = await image.readAsBytes();
  //       return base64Encode(bytes);
  //     }
  //   } catch (e) {
  //     Fluttertoast.showToast(msg: "Image pick error: $e");
  //     return null;
  //   }
  // }
Future<String?> _pickImageBase64() async {
  try {
    final bytes = await pickerService.pickImageBytes();
    if (bytes == null) return null;
    return base64Encode(bytes);
  } catch (e) {
    Fluttertoast.showToast(msg: "Image pick error: $e");
    return null;
  }
}
  Future<void> _delete(String id) async {
    try {
      await FirebaseFirestore.instance.collection(kCollection).doc(id).delete();
      Fluttertoast.showToast(msg: "Service deleted");
    } catch (e) {
      Fluttertoast.showToast(msg: "Delete failed: $e");
    }
  }
}
