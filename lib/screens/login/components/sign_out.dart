import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_wd/screens/login/components/auth_page.dart';

void signUserOut(BuildContext context) {
  FirebaseAuth.instance.signOut();
  Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (builder) => const AuthPage()),
      (route) => false);
}
