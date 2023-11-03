import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smart_wd/models/ai_model.dart';
import 'package:smart_wd/screens/login/components/auth_page.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EnterClothesCore {
  /// 100%
  /// parameters
  /// * color 20% ex white +20%
  /// * type 80% ex: winter 5%, body 80%
  ///
  ///

  String imagePath = '';
  String imageUrl = '';
  String txt = "";
  String txt1 = "Upload or take an image";
  List responsesResults = [
    "T-Shirt", // 60%
    "Longsleeve", // 50%
    "Pants", // 40%
    "Shoes", // 30%
    "Shirt", // 70%
    "Dress", // 30%
    "Outwear", // 5%
    "Shorts", // 80%
    "Not_sure", // 0%
    "Hat", // 30%
    "Skirt", // 80%
    "Polo", // 70%
    "Undershirt", // 80%
    "Blazer", // 25%
    "Hoodie", // 20%
    "Thawb", // 50%
    "Body", // 80%
    'Other', // 0%
    "Top", // 70%
    "Blouse", // 60%
    "Skip", // 70%
    "Unknown", // 0%
  ];
  File? img;

  Future<void> uploadToStorage(File imageFile) async {
    // Create the file metadata
    final metadata = SettableMetadata(contentType: "image/jpeg");

    // Create a reference to the Firebase Storage bucket
    final storageRef = FirebaseStorage.instance.ref();

    var time = DateTime.now().millisecondsSinceEpoch.toString();
    // Upload file and metadata to the path 'images/mountains.jpg'
    imagePath = "images/$time.jpg";
    await Future.delayed(const Duration(milliseconds: 0)).then((value) async =>
        await storageRef
            .child(imagePath)
            .putFile(imageFile, metadata)
            .then((p0) async {
          imageUrl =
              await FirebaseStorage.instance.ref(imagePath).getDownloadURL();
          debugPrint("url is $imageUrl");
        }));
  }

// The function which will upload the image as a file
  Future<void> callApi(File imageFile) async {
    // ignore: deprecated_member_use
    var stream = http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();

    String base = "https://smartwd-model.onrender.com";

    var uri = Uri.parse('$base/analyze');
    debugPrint('making request');

    var request = http.MultipartRequest("POST", uri);
    var multipartFile = http.MultipartFile('file', stream, length,
        filename: basename(imageFile.path));
    //contentType: new MediaType('image', 'png'));

    request.files.add(multipartFile);
    var response = await request.send();
    debugPrint(response.statusCode.toString());

    await streamToStorage(imageFile, response);
  }

  Future<void> streamToStorage(
      File imageFile, http.StreamedResponse response) async {
    await uploadToStorage(imageFile).then((value) =>
        response.stream.transform(utf8.decoder).listen((value) async {
          debugPrint(value);
          // int l = value.length;
          AnalyzeModel responseTxt = AnalyzeModel.fromJson(jsonDecode(value));
          txt = 'Type: ${responseTxt.result}\nColor: ${responseTxt.color}';

          await createDataInFireStore(
              imagePath: imagePath,
              imageUrl: imageUrl,
              type: responseTxt.result ?? 'Unknown',
              color: responseTxt.color ?? '#000000',
              temp: tempCalc(
                responseTxt.color,
                responseTxt.result,
              ));
        }));
  }

  int tempCalc(String? hexColor, String? type) {
    int result = 0;

    /// color analysis
    Color color = HexColor(hexColor ?? '#000000');
    var grayscale = (0.299 * color.red) +
        (0.587 * color.green) +
        (0.114 * color.blue); // 225

    if (type == 'Thawb') {
      return (grayscale ~/ (2.25));
    }
    result += (grayscale ~/ (2.25 * 5)); // 20%
    result += clothSwitchCase(type ?? 'Unknown'); // 80%
    return result;
  }

  Future<void> createDataInFireStore({
    required String imagePath,
    required String imageUrl,
    required String type,
    required String color,
    required int temp,
  }) async {
    final ref = FirebaseFirestore.instance.collection('user').doc(AuthPage.uid);
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
    clothesMap[imagePath] = {
      'imageUrl': imageUrl,
      'type': type,
      'color': await getColorName(color),
      'temp': temp,
    };
    await FirebaseFirestore.instance
        .collection('user')
        .doc(AuthPage.uid)
        .update({
      'clothes': clothesMap,
    });
  }

  Future<String> getColorName(String hex) async {
    List hexList = (hex.split(''));
    hexList.removeAt(0);
    String hexString = hexList.join('');
    debugPrint(hexString);
    var response = await http.get(
        Uri.parse("https://www.thecolorapi.com/id?hex=$hexString"),
        headers: {"Content-Type": "application/json"});

    Map decodedBody = jsonDecode(response.body);

    return decodedBody['name']['value'];
  }

  Future<void> imagePicker(int a) async {
    txt1 = "";
    debugPrint("Image Picker Activated");
    if (a == 0) {
      XFile? xImg = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 50,maxHeight: 324, maxWidth: 324);
      img = File(xImg!.path);
    } else {
      XFile? xImg = await ImagePicker().pickImage(source: ImageSource.gallery,imageQuality: 50, maxHeight: 324, maxWidth: 324);
      img = File(xImg!.path);
    }

    txt = "Analysing...";
    debugPrint(img.toString());
  }

  int clothSwitchCase(String result) {
    switch (result) {
      case "T-Shirt": // 60%
        return 60;
      case "Longsleeve": // 50%
        return 50;
      case "Pants": // 40%
        return 40;
      case "Shoes": // 30%
        return 30;
      case "Shirt": // 70%
        return 70;
      case "Dress": // 30%
        return 30;
      case "Outwear": // 5%
        return 5;
      case "Shorts": // 80%
        return 80;
      case "Not_sure": // 0%
        return 0;
      case "Hat": // 30%
        return 30;
      case "Skirt": // 80%
        return 80;
      case "Polo": // 70%
        return 70;
      case "Undershirt": // 80%
        return 80;
      case "Blazer": // 25%
        return 25;
      case "Hoodie": // 20%
        return 20;
      case "Thawb": // 50%
        return 50;
      case "Body": // 80%
        return 80;
      case 'Other': // 0%
        return 0;
      case "Top": // 70%
        return 70;
      case "Blouse": // 60%
        return 60;
      case "Skip": // 70%
        return 70;
      case "Unknown": // 0%
        return 0;
      default:
        return 0;
    }
  }
}
