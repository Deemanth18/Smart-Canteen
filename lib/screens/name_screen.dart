import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'menu_screen.dart';

class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final TextEditingController nameController = TextEditingController();

  final DatabaseReference ref = FirebaseDatabase.instance.ref("users");

  void saveUser() {
    final user = FirebaseAuth.instance.currentUser;

    ref.child(user!.uid).set({
      "name": nameController.text,
      "phone": user.phoneNumber,
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MenuScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter Name")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Your Name"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(onPressed: saveUser, child: const Text("Continue")),
          ],
        ),
      ),
    );
  }
}
