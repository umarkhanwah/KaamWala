// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_database/ui/firebase_animated_list.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:kam_wala_app/dashboard/AddPost.dart';

// class salonFatechdata extends StatefulWidget {
//   const salonFatechdata({super.key});

//   @override
//   State<salonFatechdata> createState() => _salonFatechdataState();
// }

// class _salonFatechdataState extends State<salonFatechdata> {
//   /// ✅ Changed "category" → "saloonCategory"
//   final DatabaseRef = FirebaseDatabase.instance.ref('saloonCategory');

//   void DataDelete(String PostId) async {
//     EasyLoading.show(status: "Deleting...");
//     DatabaseRef.child(PostId)
//         .remove()
//         .then((value) {
//           EasyLoading.showSuccess("Service Deleted");
//         })
//         .catchError((error) {
//           EasyLoading.showError("Failed To Delete $error");
//         });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: const Text(
//           "💅 Salon Services",
//           style: TextStyle(
//             color: Color(0xFFD81B60), // Dark pink
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             letterSpacing: 1,
//           ),
//         ),
//         centerTitle: true,
//       ),

//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.pinkAccent,
//         onPressed: () {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => const Post()),
//           );
//         },
//         child: const Icon(Icons.add, color: Colors.white),
//       ),

//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Color(0xFFFFFFFF), // White
//               Color(0xFFFCE4EC), // Very light pink
//               Color(0xFFF8BBD0), // Soft pink
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.only(top: 90, left: 12, right: 12),
//           child: FirebaseAnimatedList(
//             query: DatabaseRef,
//             itemBuilder: (context, snapshot, animation, index) {
//               String postid = snapshot.key!;
//               String Title =
//                   snapshot.child("productName").value as String? ??
//                   "No data found";
//               String description =
//                   snapshot.child("description").value as String? ??
//                   "No data found";

//               return Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 child: Card(
//                   elevation: 6,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   shadowColor: Colors.pinkAccent.withOpacity(0.3),
//                   child: ListTile(
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 12,
//                     ),
//                     title: Text(
//                       Title,
//                       style: const TextStyle(
//                         color: Color(0xFFD81B60), // Dark pink
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     subtitle: Padding(
//                       padding: const EdgeInsets.only(top: 6.0),
//                       child: Text(
//                         description,
//                         style: TextStyle(
//                           color: Colors.grey.shade700,
//                           fontSize: 15,
//                         ),
//                       ),
//                     ),
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         IconButton(
//                           onPressed: () {
//                             // Edit logic yaha add kar sakti ho
//                           },
//                           icon: const Icon(Icons.edit, color: Colors.pink),
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.delete, color: Colors.red),
//                           onPressed: () {
//                             showDialog(
//                               context: context,
//                               builder: (value) => AlertDialog(
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(16),
//                                 ),
//                                 title: const Text(
//                                   "Confirm Delete",
//                                   style: TextStyle(
//                                     color: Color(0xFFD81B60),
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 content: const Text(
//                                   "Are you sure you want to delete this service?",
//                                 ),
//                                 actions: [
//                                   TextButton(
//                                     onPressed: () => Navigator.pop(context),
//                                     child: const Text(
//                                       "Cancel",
//                                       style: TextStyle(
//                                         color: Colors.black54,
//                                       ),
//                                     ),
//                                   ),
//                                   ElevatedButton(
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.pinkAccent,
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(10),
//                                       ),
//                                     ),
//                                     onPressed: () {
//                                       Navigator.pop(context);
//                                       DataDelete(postid);
//                                     },
//                                     child: const Text("Delete"),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kam_wala_app/dashboard/AddPost.dart';

class salonFatechdata extends StatefulWidget {
  const salonFatechdata({super.key});

  @override
  State<salonFatechdata> createState() => _salonFatechdataState();
}

class _salonFatechdataState extends State<salonFatechdata> {
  final DatabaseRef = FirebaseDatabase.instance.ref('saloonCategory');

  void DataDelete(String postId) async {
    EasyLoading.show(status: "Deleting...");
    DatabaseRef.child(postId)
        .remove()
        .then((value) {
          EasyLoading.showSuccess("Service Deleted");
        })
        .catchError((error) {
          EasyLoading.showError("Failed To Delete $error");
        });
  }

  void DataUpdate(String postId, String oldTitle, String oldDesc) {
    final titleController = TextEditingController(text: oldTitle);
    final descController = TextEditingController(text: oldDesc);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              "✏️ Edit Service",
              style: TextStyle(
                color: Color(0xFFD81B60),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: "Service Name",
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.pinkAccent),
                    ),
                  ),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.pinkAccent),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.black54),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  EasyLoading.show(status: "Updating...");

                  DatabaseRef.child(postId)
                      .update({
                        "productName": titleController.text.trim(),
                        "description": descController.text.trim(),
                      })
                      .then((value) {
                        EasyLoading.showSuccess("Service Updated");
                      })
                      .catchError((error) {
                        EasyLoading.showError("Update Failed $error");
                      });
                },
                child: const Text("Update"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "💅 Salon Services",
          style: TextStyle(
            color: Color(0xFFD81B60),
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CategoryCrud()),
            // MaterialPageRoute(builder: (context) => const Post()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFFCE4EC), Color(0xFFF8BBD0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 90, left: 12, right: 12),
          child: FirebaseAnimatedList(
            query: DatabaseRef,
            itemBuilder: (context, snapshot, animation, index) {
              String postId = snapshot.key!;
              String title =
                  snapshot.child("productName").value as String? ??
                  "No data found";
              String description =
                  snapshot.child("description").value as String? ??
                  "No data found";

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  shadowColor: Colors.pinkAccent.withOpacity(0.3),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFFD81B60),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        description,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ✅ EDIT BUTTON
                        IconButton(
                          onPressed: () {
                            DataUpdate(postId, title, description);
                          },
                          icon: const Icon(Icons.edit, color: Colors.pink),
                        ),
                        // ✅ DELETE BUTTON
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder:
                                  (value) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    title: const Text(
                                      "Confirm Delete",
                                      style: TextStyle(
                                        color: Color(0xFFD81B60),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    content: const Text(
                                      "Are you sure you want to delete this service?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text(
                                          "Cancel",
                                          style: TextStyle(
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.pinkAccent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          DataDelete(postId);
                                        },
                                        child: const Text("Delete"),
                                      ),
                                    ],
                                  ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
