import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:smart_wd/api/weather_api.dart';
import 'package:smart_wd/components/my_button2.dart';
import 'package:smart_wd/constants/colors.dart';
import 'package:smart_wd/screens/login/components/auth_page.dart';

class GetClothes extends StatefulWidget {
  const GetClothes({super.key});

  @override
  State<GetClothes> createState() => _GetClothesState();
}

class _GetClothesState extends State<GetClothes> {
  num temp = 0;
  String weatherCondition = '';
  String addresses = '';
  Position? position;
  List<Placemark> placeMarks = [];
  bool isLoading = true;
  Map clothesByTemp = {};
  List<bool> selectedClothes = [];
  final ref = FirebaseFirestore.instance.collection('user').doc(AuthPage.uid);
  final DatabaseReference suitableDb =
      FirebaseDatabase.instance.ref().child('suitability_leds');
  final DatabaseReference dbRef = FirebaseDatabase.instance
      .ref()
      .child('devices')
      .child('e4:5f:01:f5:f7:b8')
      .child('switch_data');
  late LocationPermission permission;
  String selectedDestination = 'All';
  List destinations = [];

  Future fetchDesOptions() async {
    final QuerySnapshot<Map<String, dynamic>> ref =
        await (FirebaseFirestore.instance.collection('clothes_des')).get();
    destinations = ref.docs[0].data()['destinations'];
    debugPrint(destinations.toString());
  }

  Future<void> resetSuitable() async {
    await suitableDb.child('switch1').child('is_suitable').set(false);
    await suitableDb.child('switch2').child('is_suitable').set(false);
    await suitableDb.child('switch3').child('is_suitable').set(false);
  }

  Future<void> getClothes() async {
    await resetSuitable();
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
      bool condition =
          temp > 20 ? clothesMap[k]['temp'] >= 50 : clothesMap[k]['temp'] < 50;
      if (condition &&
          selectedDestination == 'All' &&
          clothesMap[k]['isGet'] == false) {
        clothesByTemp[k] = clothesMap[k];
      } else if (condition &&
          (selectedDestination == clothesMap[k]['destination'] ||
              clothesMap[k]['destination'] == 'All') &&
          clothesMap[k]['isGet'] == false) {
        clothesByTemp[k] = clothesMap[k];
      }
    }
    selectedClothes =
        List.generate(clothesByTemp.keys.toList().length, (index) => false);

    for (var i in clothesByTemp.keys.toList()) {
      var item = clothesByTemp[i];
      await suitableDb
          .child('switch${item['Hanger']}')
          .child('is_suitable')
          .set(true);
    }
  }

  Future<void> getPosition() async {
    permission = await Geolocator.requestPermission();
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium);
    placeMarks =
        await placemarkFromCoordinates(position!.latitude, position!.longitude);
  }

  Future<void> getTemp() async {
    Map weatherResponse = await callWeatherApi(
        position!.latitude.toString(), position!.longitude.toString());
    debugPrint(weatherResponse.toString());
    temp = weatherResponse['main']['temp'];
    weatherCondition = weatherResponse['weather'][0]['description'];
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero).then((value) async {
      await getPosition();
      await fetchDesOptions();
      await getTemp();
      await getClothes();
    }).then((value) => setState(() {
          isLoading = false;
        }));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
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
                    Image.asset('assets/Images/login_background_login.png',
                        scale: 1),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              'Get Clothes',
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.brown,
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.black,
                                    Colors.black87,
                                    Colors.black54,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$temp',
                                        style: GoogleFonts.poppins(
                                            fontSize: 64, color: Colors.white),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            'LAT:${position!.latitude.round()}',
                                            style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: Colors.grey),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'LON:${position!.longitude.round()}',
                                            style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 180,
                                        child: Text(
                                          "${placeMarks[0].administrativeArea ?? placeMarks[0].country!}, ${placeMarks[0].locality!}",
                                          style: GoogleFonts.poppins(
                                              fontSize: 18,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Image.asset(
                                        "assets/Images/weather.png",
                                        width: 120,
                                      ),
                                      const SizedBox(height: 30),
                                      Text(
                                        weatherCondition,
                                        style: GoogleFonts.poppins(
                                            fontSize: 14, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 25),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Destination Location',
                          style: GoogleFonts.poppins(fontSize: 22),
                        ),
                        SizedBox(
                          width: size.width,
                          height: 42,
                          child: DropdownButton<String>(
                              value: selectedDestination,
                              onChanged: (value) {
                                clothesByTemp.clear();
                                setState(() {
                                  selectedDestination = value!;
                                });
                                getClothes().then(
                                    (value) => setState(() => clothesByTemp));
                              },
                              borderRadius: BorderRadius.circular(12),
                              items: destinations.map((item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: SizedBox(
                                      width: size.width - 56,
                                      child: Text(item)),
                                );
                              }).toList(),
                              hint: const Text('Select a Destination'),
                              style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                        ),
                        SingleChildScrollView(
                          child: GridView.builder(
                            shrinkWrap: true,
                            itemCount: clothesByTemp.keys.toList().length,
                            itemBuilder: (BuildContext context, int index) {
                              List keysList = clothesByTemp.keys.toList();
                              Map item = clothesByTemp[keysList[index]];
                              debugPrint(item.toString());

                              return InkWell(
                                onTap: () => setState(() {
                                  selectedClothes[index] =
                                      !selectedClothes[index];
                                }),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.network(
                                        item['imageUrl'],
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    Checkbox(
                                        fillColor:
                                            MaterialStateProperty.resolveWith(
                                                (Set states) {
                                          if (states.contains(
                                              MaterialState.selected)) {
                                            return AppColors.defaultYellow;
                                          }
                                          return null;
                                        }),
                                        shape: const CircleBorder(),
                                        value: selectedClothes[index],
                                        onChanged: (bool? i) {})
                                  ],
                                ),
                              );
                            },
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 150,
                                    mainAxisExtent: 300,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 20),
                          ),
                        ),
                        MyButton2(
                            onPressed: selectedClothes
                                    .any((element) => element == true)
                                ? () async => giveClothesToUser()
                                : null,
                            buttonText: 'Get The Selected Clothes'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> giveClothesToUser() async {
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
    for (var i = 0; i < clothesByTemp.keys.toList().length; i++) {
      if (selectedClothes[i] == true) {
        List keysList = clothesByTemp.keys.toList();
        Map item = clothesByTemp[keysList[i]];
        item['isGet'] = true;
        clothesMap[item['path']] = item;
        dbRef.child('switch${item['Hanger']}').child('is_pressed').set(false);
      }
    }
    await FirebaseFirestore.instance
        .collection('user')
        .doc(AuthPage.uid)
        .update({
      'clothes': clothesMap,
    });
    await resetSuitable();
    setState(() => isLoading = false);
    Get.snackbar('Successfully', 'Clothes are returned successfully');
    if (context.mounted) {
      Navigator.pop(context);
    }
  }
}
