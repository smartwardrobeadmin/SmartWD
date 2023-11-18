import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:smart_wd/components/my_button.dart';
import 'package:smart_wd/components/my_textfield.dart';
import 'package:smart_wd/constants/colors.dart';
import 'package:smart_wd/screens/login/components/auth_page.dart';

class EditClothes extends StatefulWidget {
  final Map item;

  const EditClothes({super.key, required this.item});

  @override
  State<EditClothes> createState() => _EditClothesState();
}

class _EditClothesState extends State<EditClothes> {
  final tempController = TextEditingController();
  List clothesLocation = [];
  List hangers = [];
  String selectedLocation = 'All';
  final DatabaseReference dbRef = FirebaseDatabase.instance
      .ref()
      .child('devices')
      .child('e4:5f:01:f5:f7:b8')
      .child('switch_data');

  int selectedHanger = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.wait([fetchDestinationOptions(), applyDataInUI(), fetchHangers()])
        .then((value) => setState(() => isLoading = false));

    setState(() {});
  }

  Future<void> fetchHangers() async {
    DataSnapshot data1 = await dbRef.child('switch1').child('is_pressed').get();
    DataSnapshot data2 = await dbRef.child('switch2').child('is_pressed').get();
    DataSnapshot data3 = await dbRef.child('switch3').child('is_pressed').get();
    if (data1.value == false) {
      hangers.add(1);
    }
    if (data2.value == false) {
      hangers.add(2);
    }
    if (data3.value == false) {
      hangers.add(3);
    }
    selectedHanger = widget.item['Hanger'];
    hangers.add(selectedHanger);
    setState(() {});
  }

  Future<void> applyDataInUI() async {
    tempController.text = widget.item['temp'].toString();
    selectedLocation = widget.item['destination'];
  }

  Future fetchDestinationOptions() async {
    final QuerySnapshot<Map<String, dynamic>> ref =
        await (FirebaseFirestore.instance.collection('clothes_des')).get();
    clothesLocation = ref.docs[0].data()['destinations'];
    debugPrint(clothesLocation.toString());
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return ParentWidgetEditCloth(
      image: widget.item['imageUrl'],
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.defaultYellow))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        MyTextField(
                          onChanged: (() {}),
                          controller: tempController,
                          hintText: "Temperature",
                          keyBoardType: TextInputType.number,
                          label: "Temperature",
                          obscureText: false,
                          prefixIcon: const Icon(Icons.percent),
                        ),
                        const SizedBox(height: 12),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text('Destination',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  color: Colors.grey,
                                )),
                            const SizedBox(width: 8),
                            Container(
                              width: 210,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: AppColors.defaultYellow,
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: DropdownButton<String>(
                                  value: selectedLocation,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedLocation = value!;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  dropdownColor: AppColors.defaultYellow,
                                  underline: const SizedBox(),
                                  iconEnabledColor: Colors.white,
                                  items: clothesLocation.map((item) {
                                    return DropdownMenuItem<String>(
                                      value: item,
                                      child: SizedBox(
                                          width: 150, child: Text(item)),
                                    );
                                  }).toList(),
                                  hint: const Text('Select a Destination'),
                                  style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text('Hanger',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  color: Colors.grey,
                                )),
                            const SizedBox(width: 8),
                            Container(
                              width: 210,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: AppColors.defaultYellow,
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: DropdownButton<int>(
                                  value: selectedHanger,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedHanger = value!;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  dropdownColor: AppColors.defaultYellow,
                                  underline: const SizedBox(),
                                  iconEnabledColor: Colors.white,
                                  items: hangers.map((item) {
                                    return DropdownMenuItem<int>(
                                      value: item,
                                      child: SizedBox(
                                          width: 150,
                                          child: Text('Hanger $item')),
                                    );
                                  }).toList(),
                                  hint: const Text('Select a Hanger'),
                                  style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        MyButton(
                            color: Colors.red,
                            onPressed: () async => await deleteClothes(),
                            buttonText: 'Delete'),
                        const SizedBox(height: 18),
                        MyButton(
                            onPressed: () async => await changeClothes(),
                            buttonText: 'Change Clothes'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> deleteClothes() async {
    Map<String, dynamic>? userData = (await FirebaseFirestore.instance
            .collection('user')
            .doc(AuthPage.uid)
            .snapshots()
            .first)
        .data();

    await dbRef.child('switch$selectedHanger').child('is_pressed').set(false);
    Map clothesMap = userData!['clothes'];
    clothesMap.remove(widget.item['path']);
    await FirebaseFirestore.instance
        .collection('user')
        .doc(AuthPage.uid)
        .update({
      'clothes': clothesMap,
    });
    setState(() => isLoading = false);
    Get.snackbar('Delete Successfully', 'clothes has been deleted');
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> changeClothes() async {
    setState(() => isLoading = true);
    widget.item['temp'] = num.parse(tempController.text);
    widget.item['destination'] = selectedLocation;

    await dbRef.child('switch${widget.item['Hanger']}').child('is_pressed').set(false);
    await dbRef.child('switch$selectedHanger').child('is_pressed').set(true);

    widget.item['Hanger'] = selectedHanger;
    Map<String, dynamic>? userData = (await FirebaseFirestore.instance
            .collection('user')
            .doc(AuthPage.uid)
            .snapshots()
            .first)
        .data();

    var clothesMap = userData!['clothes'];
    clothesMap[widget.item['path']] = widget.item;
    await FirebaseFirestore.instance
        .collection('user')
        .doc(AuthPage.uid)
        .update({
      'clothes': clothesMap,
    });
    setState(() => isLoading = false);
    Get.snackbar('Successfully', 'clothes changes Successfully');
    if (context.mounted) {
      Navigator.pop(context);
    }
  }
}

class ParentWidgetEditCloth extends StatelessWidget {
  final Widget child;
  final String image;

  const ParentWidgetEditCloth(
      {super.key, required this.child, required this.image});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: HexColor("#FFB133"),
          child: SizedBox(
            height: size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Stack(
                  children: [
                    Transform.translate(
                      offset: Offset(size.width * 0.3, -size.width * 0.8),
                      child: Image.network(
                        image,
                        width: MediaQuery.sizeOf(context).width * 0.4,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Container(
                        height: size.height - size.width,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: HexColor("#ffffff"),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                          ),
                        ),
                        child: child)
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
