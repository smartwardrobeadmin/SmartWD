import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path/path.dart';
import 'package:async/async.dart';

String txt = "";
String txt1 = "Upload or take an image";

class EnterClothesScreen extends StatefulWidget {
  @override
  _EnterClothesScreenState createState() => _EnterClothesScreenState();
}

class _EnterClothesScreenState extends State<EnterClothesScreen> {
  File? img;

  void uploadToStorage(File imageFile) {
    // Create the file metadata
    final metadata = SettableMetadata(contentType: "image/jpeg");

    // Create a reference to the Firebase Storage bucket
    final storageRef = FirebaseStorage.instance.ref();

    var time = DateTime.now().millisecondsSinceEpoch.toString();
    // Upload file and metadata to the path 'images/mountains.jpg'
    final uploadTask = storageRef
        .child("images/$time.jpg")
        .putFile(imageFile, metadata);

    // Listen for state changes, errors, and completion of the upload.
    uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
      switch (taskSnapshot.state) {
        case TaskState.running:
          final progress =
              100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
          print("Upload is $progress% complete.");
          break;
        case TaskState.paused:
          print("Upload is paused.");
          break;
        case TaskState.canceled:
          print("Upload was canceled");
          break;
        case TaskState.error:
          // Handle unsuccessful uploads
          break;
        case TaskState.success:
          // Handle successful uploads on complete
          // ...
          break;
      }
    });
  }

  // The function which will upload the image as a file
  void upload(File imageFile) async {
    var stream = http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();

    String base = "https://smartwd-model.onrender.com";

    var uri = Uri.parse(base + '/analyze');

    var request = http.MultipartRequest("POST", uri);
    var multipartFile = http.MultipartFile('file', stream, length,
        filename: basename(imageFile.path));
    //contentType: new MediaType('image', 'png'));

    request.files.add(multipartFile);
    var response = await request.send();
    print(response.statusCode);
    uploadToStorage(imageFile);
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
      int l = value.length;
      txt = value;

      setState(() {});
    });
  }

  void image_picker(int a) async {
    txt1 = "";
    setState(() {});
    debugPrint("Image Picker Activated");
    if (a == 0) {
      XFile? ximg = await ImagePicker().pickImage(source: ImageSource.camera);
      img = File(ximg!.path);
    } else {
      XFile? ximg = await ImagePicker().pickImage(source: ImageSource.gallery);
      img = File(ximg!.path);
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
          systemOverlayStyle: const SystemUiOverlayStyle(
            // Status bar color
            statusBarColor: Colors.red,
          ),
          centerTitle: false,
          backgroundColor: HexColor("#FFB133"),
          title: Text('Enter Clothes',
              style: GoogleFonts.poppins(
                fontSize: 30,
                color: Colors.white,
              )),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.exit_to_app))
          ]),
      body: Container(
        child: Center(
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
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Align(
              alignment: Alignment(1.0, 1.0),
              child: FloatingActionButton(
                onPressed: () {
                  image_picker(0);
                },
                child: Icon(Icons.camera_alt),
              )),
          Align(
              alignment: Alignment(1.0, 0.8),
              child: FloatingActionButton(
                  onPressed: () {
                    image_picker(1);
                  },
                  child: Icon(Icons.file_upload))),
        ],
      ),
    );
  }
}
