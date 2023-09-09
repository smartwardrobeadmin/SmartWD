import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:get/get.dart';
import 'package:smart_wd/constants/colors.dart';
import 'package:smart_wd/screens/login/components/auth_page.dart';
import 'package:smart_wd/screens/login/components/sign_out.dart';
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
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  StreamSubscription? userDocSubscription;
  Map? userData = {};
  bool isLoading = true;
  List clothes = [];

  late DocumentReference<Map<String, dynamic>> ref;

  Future<void> getData() async {
    ref = firestore.collection('user').doc(AuthPage.uid);
    var snapshot = ref.snapshots();
    userDocSubscription = snapshot.listen((doc) {
      setState(() {
        userData = doc.data();
      });
    });
    await snapshot.first;
    if (userData != null) {
      if (userData!.containsKey('clothes')) {
        for (var key in userData!['clothes'].keys) {
          Map map = userData!['clothes'][key];
          map['path'] = key;
          clothes.add(map);
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    initFn();
  }

  Future<void> initFn() async {
    await Future.delayed(const Duration(seconds: 0))
        .then((value) async => await getData())
        .then((value) => setState(() => isLoading = false));
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColors.defaultYellow,
      statusBarBrightness: Brightness.dark,
    ));
    return Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
            // Status bar color
            statusBarColor: AppColors.defaultYellow,
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
                onPressed: () => signUserOut(context),
                icon: const Icon(Icons.exit_to_app))
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
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text('My Clothes',
                      style: GoogleFonts.poppins(
                        fontSize: 35,
                        color: Colors.black,
                      ))),
              Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                            color: AppColors.defaultYellow))
                    : RefreshIndicator(
                        color: AppColors.defaultYellow,
                        onRefresh: () async {
                          setState(() {
                            isLoading = true;
                            clothes.clear();
                          });
                          await initFn();
                        },
                        child: clothes.isEmpty
                            ? const SingleChildScrollView(
                                physics: AlwaysScrollableScrollPhysics(),
                                child: Padding(
                                    padding: EdgeInsets.fromLTRB(0, 24, 0, 32),
                                    child: Center(
                                        child: Text('No Clothes Found'))),
                              )
                            : ListView.builder(
                                itemCount: clothes.length,
                                itemBuilder: (context, i) {
                                  Map item = clothes[i];
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.grey[900],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Image.network(
                                            item['imageUrl'],
                                            width: 80,
                                            height: 80,
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                "Type: ${item['type']}",
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                "Color: ${item['color']}",
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              )
                                            ],
                                          ),
                                          Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              CircularProgressIndicator(
                                                value: item['temp'] / 100,
                                                color: Colors.white,
                                              ),
                                              Text(
                                                "${item['temp']}%",
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                      ),
              ),
              MyButton2(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (builder) => const EnterClothesScreen()),
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
            ]));
  }
}
