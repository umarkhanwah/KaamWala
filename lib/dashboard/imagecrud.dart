// import 'dart:convert';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:kam_wala_app/dashboard/admin_drawer.dart';
// import 'package:kam_wala_app/dashboard/imagedatafatech.dart';
// import 'dart:html' as html;

// class DataAdd extends StatefulWidget {
//   const DataAdd({super.key});

//   @override
//   State<DataAdd> createState() => _DataAddState();
// }

// class _DataAddState extends State<DataAdd> {
//   final ProductController = TextEditingController();
//   final DescController = TextEditingController();
//   final PriceController = TextEditingController();
//   bool isUploading = false;
//   final ImagePicker _picker = ImagePicker();
//   String? _uploadedImageBase64;

//   Future<void> pickImage() async {
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
//           setState(() {
//             _uploadedImageBase64 = base64Encode(data);
//           });

//           Fluttertoast.showToast(msg: "Image selected successfully");
//         });
//       });
//     } else {
//       final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//       if (image != null) {
//         Uint8List data = await image.readAsBytes();
//         setState(() {
//           _uploadedImageBase64 = base64Encode(data);
//         });
//         Fluttertoast.showToast(msg: "Image selected successfully");
//       }
//     }
//   }

//   Future<void> addProductToFirestore() async {
//     if (ProductController.text.isNotEmpty &&
//         DescController.text.isNotEmpty &&
//         PriceController.text.isNotEmpty &&
//         _uploadedImageBase64 != null &&
//         SelectedTitle != null) {
//       try {
//         await FirebaseFirestore.instance.collection('products').add({
//           'protitle': ProductController.text,
//           'Description': DescController.text,
//           'price': PriceController.text,
//           'Category': SelectedTitle,
//           'Image': _uploadedImageBase64,
//         });
//         EasyLoading.showSuccess("Product added successfully");

//         ProductController.clear();
//         DescController.clear();
//         PriceController.clear();
//         setState(() {
//           _uploadedImageBase64 = null;
//         });

//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => FatchAll()),
//         );
//       } catch (error) {
//         EasyLoading.showError("Error adding product: $error");
//       }
//     } else {
//       EasyLoading.showError("Please fill all fields before submitting");
//     }
//   }

//   final databaseRef = FirebaseDatabase.instance.ref('category');
//   String? SelectedTitle;
//   List<String> PostTitle = [];

//   @override
//   void initState() {
//     super.initState();
//     category();
//   }

//   void category() async {
//     DatabaseEvent event = await databaseRef.once();
//     DataSnapshot dataSnapshot = event.snapshot;
//     Map<dynamic, dynamic>? data = dataSnapshot.value as Map<dynamic, dynamic>?;

//     if (data != null) {
//       List<String> titles = [];
//       data.forEach((key, value) {
//         if (value is Map && value.containsKey("productName")) {
//           titles.add(value['productName'].toString());
//         }
//       });
//       setState(() {
//         PostTitle = titles;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;

//     return Scaffold(
//       drawer: Admindrawer(),
//       body: Container(
//         width: screenWidth,
//         height: screenHeight,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.blue.shade700, Colors.blue.shade300],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // Header
//                 Text(
//                   "Upload Product Data",
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                     letterSpacing: 1.2,
//                   ),
//                 ),
//                 SizedBox(height: 20),

//                 // Card Container
//                 Container(
//                   padding: EdgeInsets.all(25),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(25),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black12,
//                         blurRadius: 15,
//                         offset: Offset(0, 8),
//                       ),
//                     ],
//                   ),
//                   width: screenWidth > 600 ? 600 : screenWidth,
//                   child: Column(
//                     children: [
//                       // Dropdown
//                       Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 8.0),
//                         child: Material(
//                           elevation: 3,
//                           borderRadius: BorderRadius.circular(20),
//                           child: DropdownButtonFormField(
//                             decoration: InputDecoration(
//                               labelText: "Category",
//                               labelStyle: TextStyle(
//                                 color: Colors.blue.shade800,
//                               ),
//                               filled: true,
//                               fillColor: Colors.white,
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(20),
//                                 borderSide: BorderSide.none,
//                               ),
//                             ),
//                             items:
//                                 PostTitle.map((String title) {
//                                   return DropdownMenuItem<String>(
//                                     value: title,
//                                     child: Text(
//                                       title,
//                                       style: TextStyle(
//                                         color: Colors.blueGrey.shade900,
//                                       ),
//                                     ),
//                                   );
//                                 }).toList(),
//                             onChanged: (String? NewValue) {
//                               setState(() {
//                                 SelectedTitle = NewValue;
//                               });
//                             },
//                           ),
//                         ),
//                       ),

//                       // Product TextField
//                       Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 8.0),
//                         child: Material(
//                           elevation: 3,
//                           borderRadius: BorderRadius.circular(15),
//                           shadowColor: Colors.blue.shade100,
//                           child: TextField(
//                             controller: ProductController,
//                             cursorColor: Colors.blue.shade700,
//                             keyboardType: TextInputType.name,
//                             decoration: InputDecoration(
//                               hintText: "Product",
//                               prefixIcon: Icon(
//                                 Icons.person,
//                                 color: Colors.blue.shade700,
//                               ),
//                               filled: true,
//                               fillColor: Colors.white,
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(15.0),
//                                 borderSide: BorderSide.none,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),

//                       // Description TextField
//                       Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 8.0),
//                         child: Material(
//                           elevation: 3,
//                           borderRadius: BorderRadius.circular(15),
//                           shadowColor: Colors.blue.shade100,
//                           child: TextField(
//                             controller: DescController,
//                             cursorColor: Colors.blue.shade700,
//                             keyboardType: TextInputType.name,
//                             decoration: InputDecoration(
//                               hintText: "Description",
//                               prefixIcon: Icon(
//                                 Icons.description,
//                                 color: Colors.blue.shade700,
//                               ),
//                               filled: true,
//                               fillColor: Colors.white,
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(15.0),
//                                 borderSide: BorderSide.none,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),

//                       // Price TextField
//                       Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 8.0),
//                         child: Material(
//                           elevation: 3,
//                           borderRadius: BorderRadius.circular(15),
//                           shadowColor: Colors.blue.shade100,
//                           child: TextField(
//                             controller: PriceController,
//                             cursorColor: Colors.blue.shade700,
//                             keyboardType: TextInputType.number,
//                             decoration: InputDecoration(
//                               hintText: "Price",
//                               prefixIcon: Icon(
//                                 Icons.attach_money,
//                                 color: Colors.blue.shade700,
//                               ),
//                               filled: true,
//                               fillColor: Colors.white,
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(15.0),
//                                 borderSide: BorderSide.none,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),

//                       // Upload Image Button
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton.icon(
//                           onPressed: pickImage,
//                           icon: Icon(Icons.add_a_photo, size: 28),
//                           label: Text(
//                             "Upload Image",
//                             style: TextStyle(fontSize: 18),
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue.shade700,
//                             elevation: 5,
//                             padding: EdgeInsets.symmetric(vertical: 15),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                           ),
//                         ),
//                       ),

//                       SizedBox(height: 20),

//                       // Post Button
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton.icon(
//                           onPressed: addProductToFirestore,
//                           icon: Icon(Icons.send, color: Colors.white),
//                           label: Text(
//                             "Post Product",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 18,
//                             ),
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue.shade900,
//                             elevation: 7,
//                             padding: EdgeInsets.symmetric(vertical: 15),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(25),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kam_wala_app/dashboard/admin_drawer.dart';
import 'package:kam_wala_app/dashboard/imagedatafatech.dart';
import 'package:kam_wala_app/services/picker/picker_service.dart';
// import 'dart:html' as html;

class DataAdd extends StatefulWidget {
  const DataAdd({super.key});

  @override
  State<DataAdd> createState() => _DataAddState();
}

class _DataAddState extends State<DataAdd> {
  final ProductController = TextEditingController();
  final DescController = TextEditingController();
  final PriceController = TextEditingController();
  bool isUploading = false;
  final ImagePicker _picker = ImagePicker();
  String? _uploadedImageBase64;

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
  Future<void> addProductToFirestore() async {
    if (ProductController.text.isNotEmpty &&
        DescController.text.isNotEmpty &&
        PriceController.text.isNotEmpty &&
        _uploadedImageBase64 != null &&
        SelectedTitle != null) {
      try {
        await FirebaseFirestore.instance.collection('products').add({
          'protitle': ProductController.text,
          'Description': DescController.text,
          'price': PriceController.text,
          'Category': SelectedTitle,
          'Image': _uploadedImageBase64,
        });
        EasyLoading.showSuccess("Product added successfully");

        ProductController.clear();
        DescController.clear();
        PriceController.clear();
        setState(() {
          _uploadedImageBase64 = null;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FatchAllplumber()),
        );
      } catch (error) {
        EasyLoading.showError("Error adding product: $error");
      }
    } else {
      EasyLoading.showError("Please fill all fields before submitting");
    }
  }

  final databaseRef = FirebaseDatabase.instance.ref('category');
  String? SelectedTitle;
  List<String> PostTitle = [];

  @override
  void initState() {
    super.initState();
    category();
  }

  void category() async {
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
        PostTitle = titles;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      drawer: Admindrawer(),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade300],
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
                Text(
                  "Upload Product Data",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 20),

                // Card Container
                Container(
                  padding: EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  width: screenWidth > 600 ? 600 : screenWidth,
                  child: Column(
                    children: [
                      // Dropdown
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Material(
                          elevation: 3,
                          borderRadius: BorderRadius.circular(20),
                          child: DropdownButtonFormField(
                            decoration: InputDecoration(
                              labelText: "Category",
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
                              labelStyle: TextStyle(
                                color: Colors.blue.shade800,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items:
                                PostTitle.map((String title) {
                                  return DropdownMenuItem<String>(
                                    value: title,
                                    child: Text(
                                      title,
                                      style: TextStyle(
                                        color: Colors.blueGrey.shade900,
                                      ),
                                    ),
                                  );
                                }).toList(),
                            onChanged: (String? NewValue) {
                              setState(() {
                                SelectedTitle = NewValue;
                              });
                            },
                          ),
                        ),
                      ),

                      // Product TextField
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Material(
                          elevation: 3,
                          borderRadius: BorderRadius.circular(15),
                          shadowColor: Colors.blue.shade100,
                          child: TextField(
                            controller: ProductController,
                            cursorColor: Colors.blue.shade700,
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                              labelText: "Product",
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
                              prefixIcon: Icon(
                                Icons.person,
                                color: Colors.blue.shade700,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Description TextField
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Material(
                          elevation: 3,
                          borderRadius: BorderRadius.circular(15),
                          shadowColor: Colors.blue.shade100,
                          child: TextField(
                            controller: DescController,
                            cursorColor: Colors.blue.shade700,
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                              labelText: "Description",
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
                              prefixIcon: Icon(
                                Icons.description,
                                color: Colors.blue.shade700,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Price TextField
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Material(
                          elevation: 3,
                          borderRadius: BorderRadius.circular(15),
                          shadowColor: Colors.blue.shade100,
                          child: TextField(
                            controller: PriceController,
                            cursorColor: Colors.blue.shade700,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Price",
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
                              prefixIcon: Icon(
                                Icons.attach_money,
                                color: Colors.blue.shade700,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Image preview
                      if (_uploadedImageBase64 != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Container(
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.blue.shade300),
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
                      SizedBox(
                        width: double.infinity,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: ElevatedButton.icon(
                            onPressed: pickImage,
                            icon: Icon(Icons.add_a_photo, size: 28),
                            label: Text(
                              "Upload Image",
                              style: TextStyle(fontSize: 18),
                            ),
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.resolveWith<Color>((
                                    states,
                                  ) {
                                    if (states.contains(WidgetState.hovered)) {
                                      return Colors.blue.shade900;
                                    }
                                    return Colors.blue.shade700;
                                  }),
                              elevation: WidgetStateProperty.all<double>(5),
                              padding: WidgetStateProperty.all(
                                EdgeInsets.symmetric(vertical: 15),
                              ),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Post Button
                      SizedBox(
                        width: double.infinity,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: ElevatedButton.icon(
                            onPressed: addProductToFirestore,
                            icon: Icon(Icons.send, color: Colors.white),
                            label: Text(
                              "Post Product",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.resolveWith<Color>((
                                    states,
                                  ) {
                                    if (states.contains(WidgetState.hovered)) {
                                      return Colors.blue.shade900;
                                    }
                                    return Colors.blue.shade800;
                                  }),
                              elevation: WidgetStateProperty.all<double>(7),
                              padding: WidgetStateProperty.all(
                                EdgeInsets.symmetric(vertical: 15),
                              ),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
