import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:smart_wd/constants/keys.dart';

Future callWeatherApi(String lat, String lon) async {
  var response = await http.get(Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=${APIKeys.weatherAPiKey}"));
  return jsonDecode(response.body);
}
