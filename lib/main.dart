import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:overlay_support/overlay_support.dart';
import 'screens/splash_screen.dart';
import 'screens/role_selection.dart';

// TRACK CURRENT ROLE
String currentRole = "student";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // REQUEST NOTIFICATION PERMISSION
  await messaging.requestPermission(alert: true, badge: true, sound: true);

  // GET DEVICE TOKEN
  String? token = await messaging.getToken();
  print("🔥 DEVICE TOKEN: $token");

  runApp(const SmartCanteenApp());

  // LISTEN FOR FOREGROUND NOTIFICATIONS
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("📩 GLOBAL FCM MESSAGE RECEIVED");

    if (message.notification != null) {
      print("Title: ${message.notification!.title}");
      print("Body: ${message.notification!.body}");

      // DO NOT SHOW NOTIFICATION IN ADMIN MODE
      if (currentRole == "admin") {
        print("Notification ignored because user is admin");
        return;
      }

      showSimpleNotification(
        Text(message.notification!.body ?? "New Notification"),
        leading: const Icon(Icons.notifications, color: Colors.white),
        background: Colors.green,
        duration: const Duration(seconds: 4),
      );
    }
  });
}

class SmartCanteenApp extends StatelessWidget {
  const SmartCanteenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Canteen',
        theme: ThemeData(
          primaryColor: Colors.orange,
          scaffoldBackgroundColor: const Color(0xffF8F8F8),
          fontFamily: "Roboto",

          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.orange,
            elevation: 0,
            centerTitle: true,
          ),

          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        // FIRST SCREEN
        home: SplashScreen(),
      ),
    );
  }
}
