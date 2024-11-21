import 'package:facebook/constants/global_variables.dart';
import 'package:flutter/material.dart';

class InputTextFieldWidget extends StatefulWidget {
  final TextEditingController textEditingController;
  final String hintText;
  final bool isPassword;
  final String? initialValue; 

  const InputTextFieldWidget(
    this.textEditingController,
    this.hintText, {
    this.isPassword = false,
    this.initialValue,
    Key? key,
  }) : super(key: key);

  @override
  State<InputTextFieldWidget> createState() => _InputTextFieldWidgetState();
}

class _InputTextFieldWidgetState extends State<InputTextFieldWidget> {
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      widget.textEditingController.text = widget.initialValue!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: widget.textEditingController,
        obscureText: widget.isPassword ? _isObscured : false,
        cursorWidth: 1.3,
        cursorColor: GlobalVariables.secondaryColor,
        decoration: InputDecoration(
          border: InputBorder.none,
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: Colors.transparent),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: Colors.transparent),
          ),
          fillColor: Colors.white54,
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          contentPadding: EdgeInsets.symmetric(
              vertical: 12, horizontal: 16),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[600],
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                )
              : null,
        ),
        style: TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
      ),
    );
  }
}
