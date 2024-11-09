import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/models/message_model.dart';
import 'package:flutter/material.dart';


class VideoMessage extends StatelessWidget {
  const VideoMessage({super.key, required this.message});
  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.45,
        child: AspectRatio(
          aspectRatio: 1.6,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset('assets/images/avatar.png'),
              ),
              Container(
                height: 25,
                width: 25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.lightBlueColor,
                ),
                child: Icon(
                  Icons.play_arrow,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ));
  }
}
