import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:smart_wd/components/my_button2.dart';
import 'package:smart_wd/constants/colors.dart';
import 'package:smart_wd/screens/login/components/auth_page.dart';

class ReturnClothes extends StatefulWidget {
  const ReturnClothes({super.key});

  @override
  State<ReturnClothes> createState() => _ReturnClothesState();
}

class _ReturnClothesState extends State<ReturnClothes> {
  bool isLoading = true;
  List clothesGet = [];
  List<bool> selectedClothes = [];
  final ref = FirebaseFirestore.instance.collection('user').doc(AuthPage.uid);
  final DatabaseReference dbRef = FirebaseDatabase.instance
      .ref()
      .child('devices')
      .child('e4:5f:01:f5:f7:b8')
      .child('switch_data');

  Future<bool> emptyHanger(Map item) async {
    bool isPressed =
        (await dbRef.child('switch${item['Hanger']}').child('is_pressed').get())
            .value! as bool;
    if (isPressed) {
      Get.snackbar('Error', 'switch${item['Hanger']} is pressed');
      return false;
    }

    await dbRef.child('switch${item['Hanger']}').child('is_pressed').set(true);
    return true;
  }

  Future<void> getClothes() async {
    Map data = {};
    var snapshot = ref.snapshots();
    snapshot.listen((doc) {
      if (doc.data() != null) {
        data = doc.data()!;
      }
    });
    await snapshot.first;
    Map clothesMap = {};
    if (data.containsKey('clothes')) {
      clothesMap = data['clothes'];
    }

    for (var k in clothesMap.keys) {
      if (clothesMap[k]['isGet'] == true) {
        clothesGet.add(clothesMap[k]);
      }
    }
    selectedClothes = List.generate(clothesGet.length, (index) => false);
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero).then((value) async {
      await getClothes();
    }).then((value) => setState(() {
          isLoading = false;
        }));
  }

  @override
  Widget build(BuildContext context) {
    // Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: HexColor("#FFB133"),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.white,
            ))
          : Column(
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 150,
                      width: double.infinity,
                      child: Image.asset(
                        'assets/Images/login_background_login.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Return Clothes',
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 12),
                        Text('Choose the Clothes you want to Return',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        SingleChildScrollView(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: clothesGet.length,
                            itemBuilder: (BuildContext context, int index) {
                              Map item = clothesGet[index];
                              debugPrint(item.toString());

                              return Container(
                                margin: const EdgeInsets.only(
                                    right: 16, bottom: 16, left: 16),
                                decoration: BoxDecoration(
                                    color: AppColors.defaultYellow,
                                    borderRadius: BorderRadius.circular(16)),
                                child: InkWell(
                                  onTap: () => setState(() {
                                    selectedClothes[index] =
                                        !selectedClothes[index];
                                  }),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            child: Image.network(
                                              item['imageUrl'],
                                              height: 150,
                                              width: 150,
                                              fit: BoxFit.fitWidth,
                                            ),
                                          ),
                                          Checkbox(
                                              fillColor: MaterialStateProperty
                                                  .resolveWith((Set states) {
                                                if (states.contains(
                                                    MaterialState.selected)) {
                                                  return AppColors
                                                      .defaultYellow;
                                                }
                                                return null;
                                              }),
                                              shape: const CircleBorder(),
                                              value: selectedClothes[index],
                                              onChanged: (bool? i) {})
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            'Destination',
                                            style: GoogleFonts.poppins(
                                              fontSize: 24,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            item['destination'],
                                            style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        height: 150,
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                            color: Colors.black87,
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                        child: Center(
                                          child: Text(
                                            item['Hanger'].toString(),
                                            style: GoogleFonts.macondo(
                                                color: Colors.white,
                                                fontSize: 72),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        MyButton2(
                            onPressed: selectedClothes
                                    .any((element) => element == true)
                                ? () async => returnClothesToUser()
                                : null,
                            buttonText: 'Return The Selected Clothes'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> returnClothesToUser() async {
    Map data = {};
    var snapshot = ref.snapshots();
    snapshot.listen((doc) {
      if (doc.data() != null) {
        data = doc.data()!;
      }
    });
    await snapshot.first;
    Map clothesMap = {};
    if (data.containsKey('clothes')) {
      clothesMap = data['clothes'];
    }
    for (var i = 0; i < clothesGet.length; i++) {
      if (selectedClothes[i] == true) {
        Map item = clothesGet[i];
        item['isGet'] = false;
        clothesMap[item['path']] = item;
        var done = await emptyHanger(item);
        if (done == false) {
          return;
        }
      }
    }
    await FirebaseFirestore.instance
        .collection('user')
        .doc(AuthPage.uid)
        .update({
      'clothes': clothesMap,
    });
    setState(() => isLoading = false);
    Get.snackbar('Successfully', 'Clothes are returned successfully');
    if (context.mounted) {
      Navigator.pop(context);
    }
  }
}
