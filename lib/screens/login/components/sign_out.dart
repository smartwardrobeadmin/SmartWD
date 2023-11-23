import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_wd/screens/login/components/auth_page.dart';

Future<void> signUserOut(BuildContext context) async {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  DataSnapshot data = await dbRef
      .child('devices')
      .child('e4:5f:01:f5:f7:b8')
      .child('switch_data')
      .child('lock_switch')
      .child('is_pressed')
      .get();
  if (data.value == false) {
    Get.snackbar('Error Happened', 'the switch lock is false');
    return;
  }
  dbRef.child('lock').child('lock_state').set(false);
  // dbRef.child('perfume').child('perfume_state').set(true);
  dbRef
      .child('sanitizers')
      .child('sanitizer1')
      .child('sanitizer_state')
      .set(true);
  dbRef
      .child('sanitizers')
      .child('sanitizer2')
      .child('sanitizer_state')
      .set(true);
  FirebaseAuth.instance.signOut();
  if (context.mounted) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (builder) => const AuthPage()),
            (route) => false);
  }
}
