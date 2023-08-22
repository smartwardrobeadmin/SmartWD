import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:smart_wd/constants/colors.dart';
import 'package:smart_wd/screens/enterclothes/enter_clothes_core.dart';
import 'package:smart_wd/screens/login/components/sign_out.dart';

class EnterClothesScreen extends StatefulWidget {
  const EnterClothesScreen({super.key});

  @override
  EnterClothesScreenState createState() => EnterClothesScreenState();
}

class EnterClothesScreenState extends State<EnterClothesScreen> {
  EnterClothesCore enterClothesCore = EnterClothesCore();

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
            IconButton(
                onPressed: () => signUserOut(context),
                icon: const Icon(Icons.exit_to_app))
          ]),
      body: Center(
        child: Column(
          children: <Widget>[
            enterClothesCore.img == null
                ? Text(
                    enterClothesCore.txt1,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 32.0,
                    ),
                  )
                : Image.file(enterClothesCore.img!,
                    height: MediaQuery.of(context).size.height * 0.6,
                    width: MediaQuery.of(context).size.width * 0.8),
            Text(
              enterClothesCore.txt,
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
                heroTag: 'camera',
                backgroundColor: AppColors.defaultYellow,
                onPressed: () => imagePickUILevel(0),
                child: const Icon(Icons.camera_alt),
              )),
          Align(
              alignment: const Alignment(1.0, 0.8),
              child: FloatingActionButton(
                  heroTag: 'gallery',
                  backgroundColor: AppColors.defaultYellow,
                  onPressed: () async => imagePickUILevel(1),
                  child: const Icon(Icons.file_upload))),
        ],
      ),
    );
  }

  Future<void> imagePickUILevel(int i) async {
    await Future.delayed(const Duration(milliseconds: 0))
        .then((value) async => await enterClothesCore.imagePicker(1))
        .then((value) => setState(() {}))
        .then((value) async =>
            await enterClothesCore.callApi(enterClothesCore.img!))
        .then((value) => setState(() {}));
  }
}
