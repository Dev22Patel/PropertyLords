import 'package:flutter/material.dart';
import 'package:realestate/features/app/splash_screen/splash_screen.dart';
import 'package:realestate/features/user_auth/presentation/pages/home_page.dart';
import 'package:realestate/features/user_auth/presentation/pages/login_page.dart';
import 'package:realestate/features/user_auth/presentation/pages/sign_up_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';
import 'dart:io' as io;
Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  io.Platform.isAndroid?
  await Firebase.initializeApp(
    options:const FirebaseOptions(
      apiKey: "AIzaSyBDmZjJ2SDQatkr3vy0kcmy9CtdrHY8-lE",
      appId: "1:508354716022:android:dedad05a6f9cb04bc89a57",
      messagingSenderId: "508354716022",
      projectId: "flutter-firebase-3c0d2",
    ),
  )
  :
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
     routes: {
        '/': (context) => const SplashScreen(
          // Here, you can decide whether to show the LoginPage or HomePage based on user authentication
          child: LoginPage(),
        ),
        '/login': (context) => LoginPage(),
        '/signUp': (context) => SignUpPage(),
        '/home': (context) => PropertiesListScreen(),
      },
    );
  }
}
