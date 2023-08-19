import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:smart_wd/screens/signup/components/flow_one.dart';
import 'package:smart_wd/screens/signup/components/flow_two.dart';
import 'package:smart_wd/controller/flow_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpBodyScreen extends StatefulWidget {
  const SignUpBodyScreen({super.key});

  @override
  State<SignUpBodyScreen> createState() => _SignUpBodyScreenState();
}

class _SignUpBodyScreenState extends State<SignUpBodyScreen> {
  FlowController flowController = Get.put(FlowController());

  late int _currentFlow;
  @override
  void initState() {
    _currentFlow = FlowController().currentFlow;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: HexColor("#FFB133"),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Stack(
              children: [
                Transform.translate(
                    offset: const Offset(0, -200),
                    child: Image.asset(
                      'assets/Images/login_background.png',
                      scale: 1,
                    )
                ),
                Transform.translate(
                  offset: const Offset(10, -100),
                  child: Text(
                    "Register",
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                    height: 600,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: HexColor("#ffffff"),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: GetBuilder<FlowController>(
                      builder: (context) {
                        if (flowController.currentFlow == 1) {
                          return const SignUpOne();
                        } else {
                          return const SignUpTwo();
                        }
                      },
                    ))
              ],
            ),
          ],
        )
      ),
    );
  }
}
