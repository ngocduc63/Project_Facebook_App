// ignore_for_file: prefer_const_constructors

import 'package:facebook/constants/global_variables.dart';
import 'package:flutter/material.dart';

class InputTextFieldWidget extends StatelessWidget {
  final TextEditingController textEditingController;
  final String hintText;
  InputTextFieldWidget(this.textEditingController, this.hintText);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white, // Màu nền cho Container
        borderRadius: BorderRadius.circular(8), // Góc bo tròn cho Container
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2), // Màu bóng
            spreadRadius: 2, // Độ lan rộng của bóng
            blurRadius: 5, // Độ mờ của bóng
            offset: Offset(0, 3), // Vị trí bóng
          ),
        ],
      ),
      child: TextField(
        controller: textEditingController,
        cursorWidth: 1.3,
        cursorColor: GlobalVariables.secondaryColor,
        decoration: InputDecoration(
          border: InputBorder.none, // Bỏ đường viền mặc định
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: Colors.transparent), // Ẩn đường viền khi focus
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: Colors.transparent), // Ẩn đường viền khi không focus
          ),
          fillColor: Colors.white54,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400]), // Màu chữ hint
          contentPadding: EdgeInsets.symmetric(
              vertical: 12, horizontal: 16), // Padding cho TextField
        ),
        style: TextStyle(
          fontSize: 16, // Kích thước chữ
          color: Colors.black, // Màu chữ
        ),
      ),
    );
  }
}
