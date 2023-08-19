import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:get/get.dart';
import '../../../screens/enterclothes/enter_clothes.dart';
import 'package:smart_wd/controller/flow_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_wd/components/my_button2.dart';

class HomeScreenBody extends StatefulWidget {
  const HomeScreenBody({super.key});

  @override
  State<HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<HomeScreenBody> {
  final user = FirebaseAuth.instance.currentUser!;
  FlowController flowController = Get.put(FlowController());


  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: HexColor("#FFB133"),
      statusBarBrightness: Brightness.dark,
    ));
    return Scaffold(
        appBar: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            // Status bar color
            statusBarColor: Colors.red,
          ),
          centerTitle: false,
          backgroundColor: HexColor("#FFB133"),
          title: Text('Welcome!',
              style: GoogleFonts.poppins(
                fontSize: 30,
                color: Colors.white,
              )),
          actions: [
            IconButton(
                onPressed: signUserOut, icon: const Icon(Icons.exit_to_app))
          ],
          bottom: AppBar(
            backgroundColor: HexColor("#FFB133"),
            title: Container(
              width: double.infinity,
              height: 40,
              color: HexColor("#FFB133"),
              child: Center(
                child: TextField(
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(0.0),
                      fillColor: HexColor("#FFFFFF"),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: const Icon(Icons.mic)),
                ),
              ),
            ),
          ),
        ),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Text('My Clothes',
                  style: GoogleFonts.poppins(
                    fontSize: 35,
                    color: Colors.black,
                  ))),
          const SizedBox(
            height: 300,
          ),
          MyButton2(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EnterClothesScreen()),
              );
            },
            buttonText: 'Enter New Clothes',
          ),
          MyButton2(
            onPressed: () {},
            buttonText: 'Get Clothes',
          ),
          MyButton2(
            onPressed: () {},
            buttonText: 'Return Clothes',
          )
        ])
    );
  }
}
