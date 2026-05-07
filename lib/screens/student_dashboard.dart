import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'menu_screen.dart';
import 'my_orders_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  @override
  void initState() {
    super.initState();

    requestPermission();
    saveDeviceToken();
  }

  // REQUEST NOTIFICATION PERMISSION
  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(alert: true, badge: true, sound: true);
  }

  // SAVE DEVICE TOKEN TO FIREBASE
  void saveDeviceToken() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    String? token = await FirebaseMessaging.instance.getToken();

    print("DEVICE TOKEN: $token");

    await FirebaseDatabase.instance.ref("users").child(user.uid).set({
      "phone": user.phoneNumber ?? "Unknown",
      "token": token ?? "",
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Dashboard")),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text("View Menu"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MenuScreen()),
                );
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              child: const Text("My Orders"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MyOrdersScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
