import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:smart_wd/api/weather_api.dart';

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
    }).then((value) => setState(() {
          isLoading = false;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#FFB133"),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white,))
          : Stack(
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
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
