
// import 'dart:ui';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:kam_wala_app/dashboard/fatchdata.dart';

// class Post extends StatefulWidget {
//   const Post({super.key});

//   @override
//   State<Post> createState() => _PostState();
// }

// class _PostState extends State<Post> {
//   final productController = TextEditingController();
//   final descriptionController = TextEditingController();

//   final DatabaseReference databaseRef = FirebaseDatabase.instance.ref(
//     "category",
//   );

//   void addPost() async {
//     final title = productController.text.trim();
//     final desc = descriptionController.text.trim();

//     if (title.isEmpty || desc.isEmpty) {
//       EasyLoading.showError('All fields are required!');
//       return;
//     }

//     EasyLoading.show(
//       status: "Uploading post...",
//       maskType: EasyLoadingMaskType.none,
//       dismissOnTap: false,
//     );

//     try {
//       final String postId = DateTime.now().microsecondsSinceEpoch.toString();

//       await databaseRef.child(postId).set({
//         'productName': title,
//         'description': desc,
//         'createdAt': DateTime.now().toIso8601String(),
//       });

//       EasyLoading.dismiss();
//       EasyLoading.showSuccess("Post Uploaded Successfully!");

//       productController.clear();
//       descriptionController.clear();

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const Fatechdata()),
//       );
//     } catch (error) {
//       EasyLoading.dismiss();
//       EasyLoading.showError("Error: $error");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       backgroundColor: const Color(0xFFEAF4FF), // light blue background
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: const Text(
//           '🚀 Add Post',
//           style: TextStyle(
//             color: Color(0xFF0A3D91), // navy blue text
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             letterSpacing: 1,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Stack(
//         children: [
//           // Background gradient
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Color.fromARGB(255, 235, 242, 246),
//                   Color.fromARGB(255, 126, 180, 242),
//                 ], // light → deep blue
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),

//           // Main card with blur effect
//           SingleChildScrollView(
//             padding: const EdgeInsets.fromLTRB(20, 100, 20, 30),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(30),
//               child: BackdropFilter(
//                 filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
//                 child: Container(
//                   padding: const EdgeInsets.all(24),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.3),
//                     borderRadius: BorderRadius.circular(30),
//                     border: Border.all(color: Colors.white38),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.blue.withOpacity(0.15),
//                         blurRadius: 25,
//                         offset: const Offset(0, 10),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       Image.asset("assets/pic/22.png", height: 150),
//                       const SizedBox(height: 20),
//                       const Text(
//                         "Fill your Service Name",
//                         style: TextStyle(
//                           color: Color(0xFF0A3D91), // navy blue
//                           fontSize: 18,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                       const SizedBox(height: 25),

//                       // Country Name Input
//                       _glassTextField(
//                         controller: productController,
//                         hint: "Service Name",
//                         icon: Icons.flag,
//                         color: Colors.blueAccent,
//                       ),
//                       const SizedBox(height: 18),

//                       // Description Input
//                       _glassTextField(
//                         controller: descriptionController,
//                         hint: "Description",
//                         icon: Icons.description,
//                         color: Colors.lightBlue,
//                       ),
//                       const SizedBox(height: 35),

//                       // Upload Button
//                       _glowButton(),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _glassTextField({
//     required TextEditingController controller,
//     required String hint,
//     required IconData icon,
//     required Color color,
//   }) {
//     return TextField(
//       controller: controller,
//       cursorColor: color,
//       style: const TextStyle(
//         color: Colors.black87,
//         fontWeight: FontWeight.w600,
//       ),
//       decoration: InputDecoration(
//         filled: true,
//         fillColor: Colors.white.withOpacity(0.85),
//         prefixIcon: Icon(icon, color: color),
//         hintText: hint,
//         hintStyle: const TextStyle(color: Colors.black45),
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 20,
//           vertical: 16,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(18),
//           borderSide: BorderSide(color: color.withOpacity(0.4)),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(18),
//           borderSide: BorderSide(color: color, width: 1.5),
//         ),
//       ),
//     );
//   }

//   Widget _glowButton() {
//     return GestureDetector(
//       onTap: addPost,
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             colors: [
//               Color.fromARGB(255, 188, 220, 252),
//               Color.fromARGB(255, 77, 157, 248),
//             ], // blue gradient
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.blue.withOpacity(0.5),
//               blurRadius: 20,
//               spreadRadius: 1,
//               offset: const Offset(0, 6),
//             ),
//           ],
//           borderRadius: BorderRadius.circular(40),
//         ),
//         child: const Center(
//           child: Text(
//             "✨ Upload Now",
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 17,
//               fontWeight: FontWeight.bold,
//               letterSpacing: 1,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// /// ✅ Global EasyLoading config (Blue + White theme, no freeze)
// void configLoading() {
//   EasyLoading.instance
//     ..loadingStyle = EasyLoadingStyle.light
//     ..maskType = EasyLoadingMaskType.none
//     ..indicatorType = EasyLoadingIndicatorType.fadingCircle
//     ..indicatorSize = 45.0
//     ..radius = 12.0
//     ..progressColor = Colors.blue
//     ..backgroundColor = Colors.white
//     ..indicatorColor = Colors.blue
//     ..textColor = Colors.blue
//     ..userInteractions = true;
// }



// chalta hua 


// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';

// class CategoryCrud extends StatefulWidget {
//   const CategoryCrud({super.key});

//   @override
//   State<CategoryCrud> createState() => _CategoryCrudState();
// }

// class _CategoryCrudState extends State<CategoryCrud> {
//   final nameController = TextEditingController();
//   final descController = TextEditingController();

//   void addCategory() async {
//     if (nameController.text.isEmpty || descController.text.isEmpty) {
//       EasyLoading.showError("All fields required!");
//       return;
//     }

//     try {
//       EasyLoading.show(status: "Adding Category...");
//       await FirebaseFirestore.instance.collection('categories').add({
//         "name": nameController.text.trim(),
//         "description": descController.text.trim(),
//         "createdAt": DateTime.now(),
//       });

//       nameController.clear();
//       descController.clear();

//       EasyLoading.showSuccess("Category Added");
//     } catch (e) {
//       EasyLoading.showError("Error: $e");
//     }
//   }

//   void deleteCategory(String id) async {
//     try {
//       await FirebaseFirestore.instance.collection('categories').doc(id).delete();
//       EasyLoading.showSuccess("Deleted");
//     } catch (e) {
//       EasyLoading.showError("Error deleting: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Category Management"),
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: const InputDecoration(
//                 labelText: "Category Name",
//                 prefixIcon: Icon(Icons.category),
//               ),
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: descController,
//               decoration: const InputDecoration(
//                 labelText: "Description",
//                 prefixIcon: Icon(Icons.description),
//               ),
//             ),
//             const SizedBox(height: 15),
//             ElevatedButton.icon(
//               onPressed: addCategory,
//               icon: const Icon(Icons.add),
//               label: const Text("Add Category"),
//             ),
//             const SizedBox(height: 25),
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('categories')
//                     .orderBy('createdAt', descending: true)
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData) {
//                     return const Center(child: CircularProgressIndicator());
//                   }

//                   final categories = snapshot.data!.docs;

//                   if (categories.isEmpty) {
//                     return const Center(child: Text("No Categories Found"));
//                   }

//                   return ListView.builder(
//                     itemCount: categories.length,
//                     itemBuilder: (context, index) {
//                       final cat = categories[index];
//                       return Card(
//                         child: ListTile(
//                           title: Text(cat['name']),
//                           subtitle: Text(cat['description']),
//                           trailing: IconButton(
//                             icon: const Icon(Icons.delete, color: Colors.red),
//                             onPressed: () =>
//                                 deleteCategory(cat.id),
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class CategoryCrud extends StatefulWidget {
  const CategoryCrud({super.key});

  @override
  State<CategoryCrud> createState() => _CategoryCrudState();
}

class _CategoryCrudState extends State<CategoryCrud> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  // 🔹 Icon Chooser Logic
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase().trim()) {
      case "plumbing":
      case "plumber":
        return Icons.plumbing;
      case "electrician":
        return Icons.electrical_services;
      case "ac repair":
      case "ac services":
      case "ac technician":
        return Icons.ac_unit;
      case "geyser repair":
      case "geyser":
      case "geyser services":
        return Icons.water_damage_outlined;
      case "cleaner":
      case "cleaning services":
      case "cleaning":
        return Icons.cleaning_services;
      case "painter":
        return Icons.format_paint;
      case "carpenter":
        return Icons.handyman;
      case "handy man":
      case "handyman":
        return Icons.build;
      default:
        return Icons.miscellaneous_services;
    }
  }

  // 🔹 Icon Guide Sheet
  void _showIconGuide() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        // Guide data
        final Map<String, IconData> guide = {
          "Plumber / Plumbing": Icons.plumbing,
          "Electrician": Icons.electrical_services,
          "AC Repair / Services": Icons.ac_unit,
          "Geyser / Services": Icons.water_damage_outlined,
          "Cleaning / Cleaner": Icons.cleaning_services,
          "Painter": Icons.format_paint,
          "Carpenter": Icons.handyman,
          "Handyman": Icons.build,
          "Others": Icons.miscellaneous_services,
        };

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Icon Keyword Guide", 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("Use these names to auto-assign icons:"),
              const Divider(),
              Expanded(
                child: ListView(
                  children: guide.entries.map((e) => ListTile(
                    leading: Icon(e.value, color: Colors.blue.shade900),
                    title: Text(e.key),
                  )).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
/// 🔥 Strict Delete Confirmation
  Future<void> confirmDelete(String docId, String categoryName) async {
    final TextEditingController confirmController = TextEditingController();
    
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // User ko bahar click karke band nahi karne dega
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
            SizedBox(width: 10),
            Text("Critical Action", style: TextStyle(color: Colors.red)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Are you sure you want to delete '$categoryName'?",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Warning: Deleting this category may cause the app to crash if services are still linked to it!",
              style: TextStyle(color: Colors.red, fontSize: 13),
            ),
            const SizedBox(height: 20),
            const Text("Type 'DELETE' to confirm:"),
            const SizedBox(height: 10),
            TextField(
              controller: confirmController,
              decoration: InputDecoration(
                hintText: "DELETE",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("CANCEL"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (confirmController.text.trim() == "DELETE") {
                Navigator.pop(context, true);
              } else {
                EasyLoading.showError("Please type DELETE correctly");
              }
            },
            child: const Text("DELETE PERMANENTLY", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        EasyLoading.show(status: "Deleting...");
        await FirebaseFirestore.instance.collection('categories').doc(docId).delete();
        EasyLoading.showSuccess("Category Deleted Successfully");
      } catch (e) {
        EasyLoading.showError("Error: $e");
      }
    }
  }
  void addCategory() async {
    if (nameController.text.isEmpty || descController.text.isEmpty) {
      EasyLoading.showError("All fields required!");
      return;
    }
    try {
      EasyLoading.show(status: "Adding...");
      await FirebaseFirestore.instance.collection('categories').add({
        "name": nameController.text.trim(),
        "description": descController.text.trim(),
        "createdAt": FieldValue.serverTimestamp(),
      });
      nameController.clear();
      descController.clear();
      EasyLoading.showSuccess("Category Added");
    } catch (e) {
      EasyLoading.showError("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: const BackButton(color: Colors.white),
                  title: const Text("Manage Categories", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.info_outline, color: Colors.white),
                      onPressed: _showIconGuide,
                    )
                  ],
                ),
                
                // Form Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: [
                      _field(nameController, "Category Name (e.g. Plumber)", Icons.category),
                      _field(descController, "Description", Icons.description),
                      const SizedBox(height: 10),
                      
                      // View Guide Button
                      TextButton.icon(
                        onPressed: _showIconGuide, 
                        icon: const Icon(Icons.help_outline, size: 18),
                        label: const Text("View Icon Name Guide"),
                      ),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: addCategory,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade900,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            padding: const EdgeInsets.all(15)
                          ),
                          child: const Text("Add Category", style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // List
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('categories').orderBy('createdAt', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator(color: Colors.white);
                    
                    return Column(
                      children: snapshot.data!.docs.map((doc) {
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade50,
                              // Yahan icon auto-detect ho raha hai
                              child: Icon(_getCategoryIcon(doc['name']), color: Colors.blue.shade900),
                            ),
                            title: Text(doc['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(doc['description']),
                            trailing: IconButton(
  icon: const Icon(Icons.delete, color: Colors.red),
  onPressed: () => confirmDelete(doc.id, doc['name']), // doc id aur name pass karein
),
                            
                            // trailing: IconButton(
                            //   icon: const Icon(Icons.delete, color: Colors.red),
                            //   onPressed: () => FirebaseFirestore.instance.collection('categories').doc(doc.id).delete(),
                            // ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String l, IconData i) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: l, prefixIcon: Icon(i),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}