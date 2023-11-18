import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:smart_wd/components/my_button.dart';
import 'package:smart_wd/constants/colors.dart';
import 'package:smart_wd/screens/enter_clothes/enter_clothes_core.dart';
import 'package:smart_wd/screens/login/components/sign_out.dart';

class EnterClothesScreen extends StatefulWidget {
  const EnterClothesScreen({super.key});

  @override
  EnterClothesScreenState createState() => EnterClothesScreenState();
}

class EnterClothesScreenState extends State<EnterClothesScreen> {
  // instance class EnterClotheCore
  final EnterClothesCore enterClothesCore = EnterClothesCore();
  String selectedDes = 'All';

  dynamic response;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero)
        .then((value) async => await enterClothesCore.fetchDesOptions())
        .then((value) async => await enterClothesCore.fetchHangers())
        .then((value) {
      setState(() {
        isLoading = false;
        enterClothesCore.hangers;
        enterClothesCore.clothesDestinations;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(enterClothesCore.hangers.toString());
    return Scaffold(
      appBar: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
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
                onPressed: () async => await signUserOut(context),
                icon: const Icon(Icons.exit_to_app))
          ]),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator(color: AppColors.defaultYellow)
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                            height: MediaQuery.of(context).size.height * 0.5,
                            width: MediaQuery.of(context).size.width * 0.7,
                            fit: BoxFit.contain),
                    Text(
                      enterClothesCore.txt,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32.0,
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child: DropdownButton<String>(
                          value: selectedDes,
                          onChanged: (value) {
                            setState(() {
                              selectedDes = value!;
                            });
                          },
                          items:
                              enterClothesCore.clothesDestinations.map((item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: SizedBox(width: 195, child: Text(item)),
                            );
                          }).toList(),
                          hint: const Text('Select a Destination'),
                          style: const TextStyle(
                              fontSize: 22, color: Colors.black)),
                    ),
                    if (enterClothesCore.hangers.isNotEmpty)
                      SizedBox(
                        width: 220,
                        child: DropdownButton<int>(
                            value: enterClothesCore.selectedHanger,
                            onChanged: (value) {
                              setState(() {
                                enterClothesCore.selectedHanger = value!;
                              });
                            },
                            items: enterClothesCore.hangers.map((item) {
                              return DropdownMenuItem<int>(
                                value: item,
                                child: SizedBox(
                                    width: 195, child: Text('Hanger $item')),
                              );
                            }).toList(),
                            hint: const Text('Select a Hanger'),
                            style: const TextStyle(
                                fontSize: 22, color: Colors.black)),
                      ),
                    if (enterClothesCore.hangers.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'No Hanger Available!',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.red),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(right: 32.0),
                      child: MyButton(
                          onPressed: response != null &&
                                  enterClothesCore.hangers.isNotEmpty
                              ? () async {
                                  setState(() => isLoading = true);

                                  await enterClothesCore
                                      .streamToStorage(
                                          enterClothesCore.img!,
                                          response,
                                          selectedDes)
                                      .then((value) => Get.snackbar(
                                          'Successfully',
                                          'clothes entered successfully'))
                                      .then((value) => Navigator.pop(context));
                                  setState(() => isLoading = false);
                                }
                              : null,
                          buttonText: 'Enter Clothes'),
                    ),
                    const SizedBox(height: 56),
                  ],
                ),
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
        .then((value) async => await enterClothesCore.imagePicker(i))
        .then((value) => setState(() {}))
        .then((value) async =>
            response = await enterClothesCore.callApi(enterClothesCore.img!))
        .then((value) => setState(() {}));
  }
}
