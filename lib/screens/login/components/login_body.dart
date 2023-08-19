import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:smart_wd/components/my_button.dart';
import 'package:smart_wd/components/my_textfield.dart';
import 'package:smart_wd/screens/homepage/home_page.dart';
import 'package:smart_wd/screens/signup/sign_up.dart';

class LoginBodyScreen extends StatefulWidget {
  const LoginBodyScreen({super.key});

  @override
  State<LoginBodyScreen> createState() => _LoginBodyScreenState();
}

class _LoginBodyScreenState extends State<LoginBodyScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      Navigator.push(context, MaterialPageRoute(builder: (builder)=> HomeScreen()));
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error Happened', e.code);
    }
  }

  void showErrorMessage(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(message),
          );
        });
  }

  String _errorMessage = "";

  void validateEmail(String val) {
    if (val.isEmpty) {
      setState(() {
        _errorMessage = "Email can not be empty";
      });
    } else if (!EmailValidator.validate(val, true)) {
      setState(() {
        _errorMessage = "Invalid Email Address";
      });
    } else {
      setState(() {
        _errorMessage = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Container(
      color: HexColor("#FFB133"),
      child: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Stack(
                children: [
                  Transform.translate(
                      offset: const Offset(0, -250),
                      child: Image.asset(
                        'assets/Images/login_background_login.png',
                        scale: 1,
                      )),
                  Container(
                    height: size.height * (5/7),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: HexColor("#ffffff"),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 0, 0, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Email",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: HexColor("#8d8d8d"),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                MyTextField(
                                  onChanged: (() {
                                    validateEmail(emailController.text);
                                  }),
                                  controller: emailController,
                                  hintText: "hello@gmail.com",
                                  obscureText: false,
                                  prefixIcon: const Icon(Icons.mail_outline),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                  child: Text(
                                    _errorMessage,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Password",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: HexColor("#8d8d8d"),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                MyTextField(
                                  controller: passwordController,
                                  hintText: "**************",
                                  obscureText: true,
                                  prefixIcon: const Icon(Icons.lock_outline),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                MyButton(
                                  onPressed: signUserIn,
                                  buttonText: 'Login',
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(35, 0, 0, 0),
                                  child: Row(
                                    children: [
                                      Text("Don't have an account?",
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            color: HexColor("#8d8d8d"),
                                          )),
                                      TextButton(
                                        child: Text(
                                          "Register",
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            color: HexColor("#44564a"),
                                          ),
                                        ),
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const SignUpScreen(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(10, -100),
                    child: Text(
                      "Welcome back! Glad to see you, Again!",
                      style: GoogleFonts.poppins(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
