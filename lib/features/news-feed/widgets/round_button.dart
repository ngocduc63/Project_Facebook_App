import 'package:facebook/constants/app_colors.dart';
import 'package:flutter/material.dart';

class RoundButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final double height;
  final Color color;

  const RoundButton({
    Key? key,
    required this.onPressed,
    required this.label,
    this.height = 50.0,
    this.color = AppColors.lightBlueColor,
  }) : super(key: key);

  @override
  State<RoundButton> createState() => _RoundButtonState();
}

class _RoundButtonState extends State<RoundButton> {
  Color _buttonColor = AppColors.lightBlueColor;

  @override
  void initState() {
    super.initState();
    _buttonColor = widget.color;
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _buttonColor = AppColors.darkBlueColor; // Màu khi nhấn
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _buttonColor = widget.color; // Màu khi không nhấn
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      child: Container(
        height: widget.height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: widget.onPressed == null ? Colors.transparent : _buttonColor,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: AppColors.darkBlueColor,
          ),
        ),
        child: Center(
          child: Text(
            widget.label,
            style: TextStyle(
              color: (_buttonColor == AppColors.lightBlueColor && widget.onPressed != null)
                  ? AppColors.realWhiteColor
                  : AppColors.darkBlueColor,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}


