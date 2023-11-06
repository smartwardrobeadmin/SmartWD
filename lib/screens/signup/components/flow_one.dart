import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:smart_wd/screens/homepage/home_page.dart';

import 'package:smart_wd/screens/login/login.dart';

// ignore: unused_import
import 'package:smart_wd/components/my_button.dart';
import 'package:smart_wd/controller/flow_controller.dart';
import 'package:smart_wd/controller/sign_up_controller.dart';
import 'package:email_validator/email_validator.dart';

List<String> list = <String>['Student', 'Teacher', 'Alumni'];

class SignUpOne extends StatefulWidget {
  const SignUpOne({super.key});

  @override
  State<SignUpOne> createState() => _SignUpOneState();
}

class _SignUpOneState extends State<SignUpOne> {
  final Rx<TextEditingController> emailController = TextEditingController().obs;
  final Rx<TextEditingController> passwordController =
      TextEditingController().obs;
  final Rx<TextEditingController> passwordRetypeController =
      TextEditingController().obs;
  SignUpController signUpController = Get.put(SignUpController());
  FlowController flowController = Get.put(FlowController());
  final mobileNumberController = TextEditingController().obs;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String dropdownValue = list.first;
  String _errorMessage = "";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 0, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 1,
                    ),
                    Text(
                      "Email",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: HexColor("#8d8d8d"),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextFormField(
                      controller: emailController.value,
                      onChanged: (value) {
                        // validateEmail(value);
                        signUpController.setEmail(value);
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      // onSubmitted: (value) {
                      //   signUpController.setEmail(value);
                      // },
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.email(),
                      ]),
                      cursorColor: HexColor("#4f4f4f"),
                      decoration: InputDecoration(
                        hintText: "hello@gmail.com",
                        fillColor: HexColor("#f0f3f1"),
                        contentPadding:
                            const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 15,
                          color: HexColor("#8d8d8d"),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                      ),
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
                      height: 5,
                    ),
                    Text(
                      "Mobile Number",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: HexColor("#8d8d8d"),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    TextFormField(
                      onChanged: (value) {
                        signUpController.setMobileNumber(value);
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.numeric(
                            errorText: 'not a valid Phone Number'),
                      ]),
                      controller: mobileNumberController.value,
                      keyboardType: TextInputType.number,
                      cursorColor: HexColor("#4f4f4f"),
                      decoration: InputDecoration(
                        hintText: "1234567890",
                        fillColor: HexColor("#f0f3f1"),
                        contentPadding:
                            const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 15,
                          color: HexColor("#8d8d8d"),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      "Password",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: HexColor("#8d8d8d"),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextFormField(
                      onChanged: (value) {
                        signUpController.setPassword(value);
                        passwordController.value.text = value;
                        setState(() {});
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      // onSubmitted: (value) {
                      //   signUpController.setPassword(value);
                      // },
                      obscureText: true,
                      controller: passwordController.value,
                      cursorColor: HexColor("#4f4f4f"),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.match(
                          r'^(?=.*?[a-z])(?=.*?[0-9]).{6,}$',
                          errorText:
                              'Password must contain string and numbers and 6 haracters length',
                        ),
                      ]),
                      decoration: InputDecoration(
                        hintText: "*************",
                        fillColor: HexColor("#f0f3f1"),
                        contentPadding:
                            const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 15,
                          color: HexColor("#8d8d8d"),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        focusColor: HexColor("#44564a"),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      "Confirm Password",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: HexColor("#8d8d8d"),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextFormField(
                      obscureText: true,
                      cursorColor: HexColor("#4f4f4f"),
                      controller: passwordRetypeController.value,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.equal(
                            passwordController.value.text),
                      ]),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        hintText: "*************",
                        fillColor: HexColor("#f0f3f1"),
                        contentPadding:
                            const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 15,
                          color: HexColor("#8d8d8d"),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        focusColor: HexColor("#44564a"),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    MyButton(
                        buttonText: 'Register',
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            bool isRegistered =
                                await signUpController.registerUser(
                                    signUpController.email.toString(),
                                    signUpController.password.toString());
                            debugPrint(isRegistered.toString());
                            if (isRegistered) {
                              Get.snackbar("Success", "User Registered");
                              signUpController.postSignUpDetails(
                                  signUpController.password.toString());
                              if (context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) => const HomeScreen()),
                                  (route) => false,
                                );
                              }
                            } else {
                              Get.snackbar("Error",
                                  "Please fill all the fields with valid data");
                            }
                          }
                        }),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(35, 0, 0, 0),
                      child: Row(
                        children: [
                          Text("Already have an account?",
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: HexColor("#8d8d8d"),
                              )),
                          TextButton(
                            child: Text(
                              "Log In",
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: HexColor("#44564a"),
                              ),
                            ),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
}
