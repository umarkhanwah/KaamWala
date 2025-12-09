
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(home: AdminServicePage()));
}

class AdminServicePage extends StatefulWidget {
  const AdminServicePage({super.key});

  @override
  State<AdminServicePage> createState() => _AdminServicePageState();
}

class _AdminServicePageState extends State<AdminServicePage> {
  final TextEditingController _titleController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  XFile? _pickedImageFile;

  bool _isAdding = false;
  double _uploadProgress = 0.0;

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _pickedImageFile = pickedFile);
    }
  }

  Future<void> _addService() async {
    if (_titleController.text.isEmpty || _pickedImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter title & pick an image')),
      );
      return;
    }

    setState(() {
      _isAdding = true;
      _uploadProgress = 0.0;
    });

    try {
      // Step 1: Upload image to Firebase Storage
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref('service_images/$fileName');

      UploadTask uploadTask;
      if (kIsWeb) {
        final bytes = await _pickedImageFile!.readAsBytes();
        uploadTask = ref.putData(bytes);
      } else {
        uploadTask = ref.putFile(File(_pickedImageFile!.path));
      }

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        setState(() {
          _uploadProgress =
              snapshot.bytesTransferred / snapshot.totalBytes.toDouble();
        });
      });

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Step 2: Save service in Firestore
      await FirebaseFirestore.instance.collection('services').add({
        'title': _titleController.text.trim(),
        'imageUrl': downloadUrl,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Service added!')));

      // Reset
      _titleController.clear();
      setState(() {
        _pickedImageFile = null;
        _isAdding = false;
        _uploadProgress = 0.0;
      });
    } catch (e) {
      setState(() => _isAdding = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  Widget _buildImagePreview() {
    if (_pickedImageFile == null) return const SizedBox();
    if (kIsWeb) {
      return FutureBuilder<Uint8List>(
        future: _pickedImageFile!.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            );
          }
          return const SizedBox(
            width: 60,
            height: 60,
            child: Center(child: CircularProgressIndicator()),
          );
        },
      );
    } else {
      return Image.file(
        File(_pickedImageFile!.path),
        width: 60,
        height: 60,
        fit: BoxFit.cover,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Services")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Service Title'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Pick Image'),
                ),
                const SizedBox(width: 10),
                _buildImagePreview(),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isAdding ? null : _addService,
              child:
                  _isAdding
                      ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                          ),
                        ],
                      )
                      : const Text("Add Service"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('services')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(child: Text('No services'));
                  }
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      return ListTile(
                        leading:
                            data['imageUrl'] != null
                                ? Image.network(
                                  data['imageUrl'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                                : const Icon(Icons.broken_image),
                        title: Text(data['title']),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed:
                              () =>
                                  FirebaseFirestore.instance
                                      .collection('services')
                                      .doc(docs[index].id)
                                      .delete(),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
