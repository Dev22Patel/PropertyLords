import 'package:flutter/material.dart';
import 'package:realestate/features/app/splash_screen/splash_screen.dart';
import 'package:realestate/features/user_auth/presentation/pages/AdminScreen.dart';
import 'package:realestate/features/user_auth/presentation/pages/home_page.dart';
import 'package:realestate/features/user_auth/presentation/pages/login_page.dart';
import 'package:realestate/features/user_auth/presentation/pages/sign_up_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io' as io;
import 'package:realestate/features/user_auth/presentation/services/firestore_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase depending on the platform (Android or others)
  if (io.Platform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBDmZjJ2SDQatkr3vy0kcmy9CtdrHY8-lE",
        appId: "1:508354716022:android:dedad05a6f9cb04bc89a57",
        messagingSenderId: "508354716022",
        projectId: "flutter-firebase-3c0d2",
        storageBucket: 'flutter-firebase-3c0d2.appspot.com',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  final firestoreService = FirestoreService(); // Firestore service instance

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      routes: {
        '/': (context) => const SplashScreen(
          child: LoginPage(),
        ),
        '/login': (context) => const LoginPage(),
        '/signUp': (context) => const SignUpPage(),
        '/home': (context) => const PropertiesListScreen(),
        '/admin': (context) => AdminPropertiesListScreen(),
        // '/add-property': (context) => const PropertyFormScreen(), // Uncomment if you have this screen
      },
    );
  }
}
