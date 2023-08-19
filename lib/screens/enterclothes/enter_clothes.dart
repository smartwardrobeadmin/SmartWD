import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:smart_wd/constants/colors.dart';
import 'package:smart_wd/models/ai_model.dart';
import 'package:smart_wd/screens/login/components/auth_page.dart';

String txt = "";
String txt1 = "Upload or take an image";

class EnterClothesScreen extends StatefulWidget {
  const EnterClothesScreen({super.key});

  @override
  EnterClothesScreenState createState() => EnterClothesScreenState();
}

class EnterClothesScreenState extends State<EnterClothesScreen> {
  String imagePath = '';
  File? img;

  Future<void> uploadToStorage(File imageFile) async {
    // Create the file metadata
    final metadata = SettableMetadata(contentType: "image/jpeg");

    // Create a reference to the Firebase Storage bucket
    final storageRef = FirebaseStorage.instance.ref();

    var time = DateTime.now().millisecondsSinceEpoch.toString();
    // Upload file and metadata to the path 'images/mountains.jpg'
    imagePath = "images/$time.jpg";
    final uploadTask = storageRef.child(imagePath).putFile(imageFile, metadata);

    // Listen for state changes, errors, and completion of the upload.
    uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
      switch (taskSnapshot.state) {
        case TaskState.running:
          final progress =
              100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
          debugPrint("Upload is $progress% complete.");
          break;
        case TaskState.paused:
          Get.snackbar('Pause', "Upload is paused.");
          break;
        case TaskState.canceled:
          Get.snackbar('Canceled', "Upload was canceled");
          break;
        case TaskState.error:
          Get.snackbar('Error', "Upload had an error");
          break;
        case TaskState.success:
          Get.snackbar('Success', "Upload was Success");
          // ...
          break;
      }
    });
  }

  // The function which will upload the image as a file
  void upload(File imageFile) async {
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

    await Future.delayed(const Duration(milliseconds: 0)).then((value) async =>
        await uploadToStorage(imageFile).then(
            (value) => response.stream.transform(utf8.decoder).listen((value)async {
                  debugPrint(value);
                  // int l = value.length;
                  AnalyzeModel responseTxt =
                      AnalyzeModel.fromJson(jsonDecode(value));
                  txt =
                      'Type: ${responseTxt.result}\nColor: ${responseTxt.color}';

                  /// color analysis
                  Color color = HexColor(responseTxt.color ?? '#000000');
                  var grayscale = (0.299 * color.red) +
                      (0.587 * color.green) +
                      (0.114 * color.blue);

                  await createDataInFireStore(
                      imagePath: imagePath,
                      type: responseTxt.result ?? 'Unknown',
                      color: responseTxt.color ?? '#000000',
                      temp: (grayscale ~/ 1.28));
                  setState(() {});
                })));
  }

  Future<void> createDataInFireStore({
    required String imagePath,
    required String type,
    required String color,
    required int temp,
  }) async {
    await FirebaseFirestore.instance.collection('user').doc(AuthPage.uid).update({
      'clothes': {
        imagePath: {
          'type': type,
          'color': color,
          'temp': temp,
        }
      }
    });
  }

  void imagePicker(int a) async {
    txt1 = "";
    setState(() {});
    debugPrint("Image Picker Activated");
    if (a == 0) {
      XFile? xImg = await ImagePicker().pickImage(source: ImageSource.camera);
      img = File(xImg!.path);
    } else {
      XFile? xImg = await ImagePicker().pickImage(source: ImageSource.gallery);
      img = File(xImg!.path);
    }

    txt = "Analysing...";
    debugPrint(img.toString());
    upload(img!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
            // Status bar color
            statusBarColor: AppColors.defaultYellow,
          ),
          centerTitle: false,
          backgroundColor: AppColors.defaultYellow,
          title: Text('Enter Clothes',
              style: GoogleFonts.poppins(
                fontSize: 30,
                color: Colors.white,
              )),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.exit_to_app))
          ]),
      body: Center(
        child: Column(
          children: <Widget>[
            img == null
                ? Text(
                    txt1,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 32.0,
                    ),
                  )
                : Image.file(img!,
                    height: MediaQuery.of(context).size.height * 0.6,
                    width: MediaQuery.of(context).size.width * 0.8),
            Text(
              txt,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 32.0,
              ),
            )
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Align(
              alignment: const Alignment(1.0, 1.0),
              child: FloatingActionButton(
                heroTag: 'upload',
                backgroundColor: AppColors.defaultYellow,
                onPressed: () {
                  imagePicker(0);
                },
                child: const Icon(Icons.camera_alt),
              )),
          Align(
              alignment: const Alignment(1.0, 0.8),
              child: FloatingActionButton(
                  heroTag: 'camera pick',
                  backgroundColor: AppColors.defaultYellow,
                  onPressed: () {
                    imagePicker(1);
                  },
                  child: const Icon(Icons.file_upload))),
        ],
      ),
    );
  }
}
