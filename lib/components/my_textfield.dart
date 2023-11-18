// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:smart_wd/constants/colors.dart';

class MyTextField extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;
  final Icon prefixIcon;
  final Function()? onChanged;
  final TextInputType keyBoardType;
  final String? label;

  const MyTextField(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.obscureText,
      required this.prefixIcon,
      this.onChanged,
      this.keyBoardType = TextInputType.text,
      this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      cursorColor: HexColor("#4f4f4f"),
      keyboardType: keyBoardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          fontSize: 24,
          color: Colors.grey,
        ),
        hintText: hintText,
        fillColor: HexColor("#f0f3f1"),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        hintStyle: GoogleFonts.poppins(
          fontSize: 15,
          color: HexColor("#8d8d8d"),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: label == null ? BorderSide.none : const BorderSide(),
        ),
        prefixIcon: prefixIcon,
        prefixIconColor: HexColor("#4f4f4f"),
        filled: true,
      ),
    );
  }
}
