import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpController extends GetxController {
  static SignUpController get instance => Get.find();

  String? uid;

  String? _name;

  String? get name => _name;

  void setName(String? text) {
    _name = text;
    debugPrint("Updated name: $name");
    update();
  }

  String? _doc;

  String? get doc => _doc;

  void setDoc(String? text) {
    _doc = text;
    debugPrint("Updated doc: $doc");
    update();
  }

  String? _email;

  String? get email => _email;

  void setEmail(String? text) {
    _email = text;
    debugPrint("Updated email: $email");
    update();
  }

  String? _password;

  String? get password => _password;

  void setPassword(String? text) {
    _password = text;
    debugPrint("Updated password: $password");
    update();
  }

  String? _mobileNumber;

  String? get mobileNumber => _mobileNumber;

  void setMobileNumber(String? text) {
    _mobileNumber = text;
    debugPrint("Updated mobileNumber: $mobileNumber");
    update();
  }

  String? _age;

  String? get age => _age;

  void setAge(String? text) {
    _age = text;
    debugPrint("Updated Age: $age");
    update();
  }

  Future postSignUpDetails(String password) async {
    await FirebaseFirestore.instance.collection("user").doc(uid).set({
      "email": email,
      "mobileNumber": mobileNumber,
      "password": password,
    });
  }

  Future<bool> registerUser(String email, String password) async {
    try {
      var response = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        uid = response.user!.uid;
      }
      return true;
    } catch (error) {
      if (error is FirebaseAuthException) {
        Get.showSnackbar(GetSnackBar(
          message: error.toString(),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ));
      }
    }
    return false;
  }
}
