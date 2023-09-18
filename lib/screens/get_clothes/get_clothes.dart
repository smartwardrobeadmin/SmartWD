import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:smart_wd/api/weather_api.dart';
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
      bool condition =
          temp > 30 ? clothesMap[k]['temp'] >= 50 : clothesMap[k]['temp'] < 50;
      if (condition) {
        clothesByTemp[k] = clothesMap[k];
      }
    }
    selectedClothes =
        List.generate(clothesByTemp.keys.toList().length, (index) => false);
  }

  Future<void> getPosition() async {
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
    Future.delayed(const Duration(milliseconds: 0)).then((value) async {
      await getPosition();
      await getTemp();
      await getClothes();
    }).then((value) => setState(() {
          isLoading = false;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#FFB133"),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.white,
            ))
          : Stack(
              children: [
                Image.asset('assets/Images/login_background_login.png',
                    scale: 1),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'LON:${position!.longitude.round()}',
                                          style: GoogleFonts.poppins(
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 180,
                                      child: Text(
                                        "${placeMarks[0].administrativeArea ?? placeMarks[0].country!}, ${placeMarks[0].locality!}",
                                        style: GoogleFonts.poppins(
                                            fontSize: 18, color: Colors.white),
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
                          GridView.builder(
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
                                        fit: BoxFit.fill,
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
                                    maxCrossAxisExtent: 200,
                                    crossAxisSpacing: 20,
                                    mainAxisSpacing: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
