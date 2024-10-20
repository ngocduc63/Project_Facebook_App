// ignore_for_file: prefer_const_constructors

import 'package:facebook/constants/global_variables.dart';
import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final bool isLoading; // Sửa lỗi chính tả từ isLoaing thành isLoading

  const SubmitButton({
    Key? key,
    required this.onPressed,
    required this.title,
    this.isLoading = false, // Mặc định là false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: Offset(0, 0),
            blurRadius: 2,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ElevatedButton(
        style: ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide.none,
            ),
          ),
          backgroundColor: WidgetStateProperty.all<Color>(
            GlobalVariables.secondaryColor,
          ),
        ),
        onPressed: isLoading ? null : onPressed, // Vô hiệu hóa nút khi loading
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white, // Màu của vòng tròn
                  strokeWidth: 3, // Độ dày của vòng tròn
                ),
              )
            : Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

