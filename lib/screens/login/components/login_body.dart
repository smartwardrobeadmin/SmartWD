import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_wd/components/my_button.dart';
import 'package:smart_wd/components/my_textfield.dart';
import 'package:smart_wd/constants/colors.dart';
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
  bool canLoginWithBiometric = false;
  bool isLoading = true;
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  static Future<bool> authenticateUser() async {
    //initialize Local Authentication plugin.
    final LocalAuthentication localAuthentication = LocalAuthentication();
    //status of authentication.
    bool isAuthenticated = false;
    //check if device supports biometrics authentication.
    bool isBiometricSupported = await localAuthentication.isDeviceSupported();
    //check if user has enabled biometrics.
    //check
    bool canCheckBiometrics = await localAuthentication.canCheckBiometrics;

    //if device supports biometrics and user has enabled biometrics, then authenticate.
    if (isBiometricSupported && canCheckBiometrics) {
      try {
        Get.snackbar('Available Biometrics',
            (await localAuthentication.getAvailableBiometrics()).toString());
        isAuthenticated = await localAuthentication.authenticate(
            // options: const AuthenticationOptions(biometricOnly: false),
            options: const AuthenticationOptions(biometricOnly: true),
            // localizedReason: 'Scan your fingerprint to authenticate');
            localizedReason: 'Scan your Face ID to authenticate');
      } on PlatformException catch (e) {
        Get.snackbar('Error', e.toString());
      }
    }
    return isAuthenticated;
  }

  Future checkLocalUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    canLoginWithBiometric = email != null;
    setState(() {});
  }

  Future<void> signUserIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('email', emailController.text);
      prefs.setString('password', passwordController.text);
      await updateFirebase();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (builder) => const HomeScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error Happened', e.code);
    }
  }

  Future<void> updateFirebase() async {
    await dbRef.child('lock').child('lock_state').set(true);
    await dbRef
        .child('sanitizers')
        .child('sanitizer1')
        .child('sanitizer_state')
        .set(false);
    await dbRef
        .child('sanitizers')
        .child('sanitizer2')
        .child('sanitizer_state')
        .set(false);
  }

  Future<void> signUserInBiometric() async {
    if (await authenticateUser()) {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: prefs.getString('email')!,
            password: prefs.getString('password')!);
        await updateFirebase();
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (builder) => const HomeScreen()),
            (route) => false,
          );
        }
      } on FirebaseAuthException catch (e) {
        Get.snackbar('Error Happened', e.code);
      }
    } else {
      Get.snackbar('Not Authenticated', 'Biometric Issue');
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
  void initState() {
    checkLocalUser().then((value) => setState(() => isLoading = false));
    super.initState();
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
                    height: size.height * (5 / 7),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: HexColor("#ffffff"),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.defaultYellow))
                        : Padding(
                            padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 0, 0, 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        keyBoardType:
                                            TextInputType.emailAddress,
                                        obscureText: false,
                                        prefixIcon:
                                            const Icon(Icons.mail_outline),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            8, 0, 0, 0),
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
                                        keyBoardType:
                                            TextInputType.visiblePassword,
                                        controller: passwordController,
                                        hintText: "**************",
                                        obscureText: true,
                                        prefixIcon:
                                            const Icon(Icons.lock_outline),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Expanded(
                                            child: MyButton(
                                              onPressed: signUserIn,
                                              buttonText: 'Login',
                                            ),
                                          ),
                                          Visibility(
                                            visible: canLoginWithBiometric,
                                            child: CircleAvatar(
                                              backgroundColor:
                                                  AppColors.defaultYellow,
                                              radius: 26,
                                              child: CircleAvatar(
                                                radius: 24,
                                                backgroundColor: Colors.white,
                                                child: Center(
                                                  child: IconButton(
                                                    onPressed: () async =>
                                                        signUserInBiometric(),
                                                    icon: const Icon(
                                                      Icons.tag_faces_rounded,
                                                      // Icons.fingerprint_rounded,
                                                      size: 32,
                                                      color: AppColors
                                                          .defaultYellow,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            35, 0, 0, 0),
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
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Welcome back! Glad to see you, Again!",
                        style: GoogleFonts.poppins(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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
