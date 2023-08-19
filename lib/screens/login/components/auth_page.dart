import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_wd/screens/homepage/home_page.dart';
import 'package:smart_wd/screens/login/login.dart';
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  static String uid = '';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            uid = snapshot.data!.uid;
            debugPrint(snapshot.data!.toString());
            return const HomeScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
