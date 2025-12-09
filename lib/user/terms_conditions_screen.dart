import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms & Conditions"),
        backgroundColor: Colors.black,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            """
Terms & Conditions (Demo)

1. This is a dummy Terms & Conditions screen.
2. You can replace this with your actual T&C content later.
3. The user must agree before using the app.
4. No actual legal binding here.
            """,
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
      ),
    );
  }
}
