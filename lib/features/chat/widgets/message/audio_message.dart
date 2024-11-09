import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/models/message_model.dart';
import 'package:facebook/utils/prefs_user.dart';
import 'package:flutter/material.dart';


class AudioMessage extends StatelessWidget {
  const AudioMessage({super.key, required this.message});
  final MessageModel message;
  @override
  Widget build(BuildContext context) {
  UserServicePref userServicePref = UserServicePref();
    bool isSender = userServicePref.getUserInfo!.id == message.sender?.id;
    
    return Container(
      width: MediaQuery.of(context).size.width * 0.55,
      padding: const EdgeInsets.symmetric(
        horizontal: 20 * 0.75,
        vertical: 20 / 2.5,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: AppColors.lightBlueColor.withOpacity(isSender ? 1 : 0.1),
      ),
      child: Row(
        children: [
          Icon(Icons.play_arrow, color: isSender ? Colors.white : AppColors.lightBlueColor),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20 / 2),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: 2,
                    color: isSender ? Colors.white : AppColors.lightBlueColor.withOpacity(0.4),
                  ),
                  Positioned(
                    left: 0,
                    child: Container(
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(
                        color: isSender ? Colors.white : AppColors.lightBlueColor.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text('0.37', style: TextStyle(fontSize: 12, color: isSender ? Colors.white : null))
        ],
      ),
    );
  }
}
