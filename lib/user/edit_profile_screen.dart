import 'package:flutter/material.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.person, size: 100, color: Colors.grey),
            SizedBox(height: 20),
            Text("Edit Profile Screen (Demo)",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
