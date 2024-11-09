import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/features/chat/widgets/message/body_message.dart';
import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Body(),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.lightBlueColor,
      title: Row(
        children: [
          const BackButton( color: AppColors.whiteColor),
          const CircleAvatar(
            backgroundImage: AssetImage('assets/images/user/aki.jpg'),
          ),
          const SizedBox(width: 20 * 0.75),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('User 2', style: TextStyle(fontSize: 16, color: AppColors.whiteColor, fontWeight: FontWeight.w600,)),
              Text('Active 3m ago', style: TextStyle(fontSize: 12, color: AppColors.whiteColor))
            ],
          )
        ],
      ),
      actions: [
        IconButton(onPressed: () {}, icon: Icon(Icons.call, color: AppColors.whiteColor,)),
        IconButton(onPressed: () {}, icon: Icon(Icons.videocam, color: AppColors.whiteColor)),
        SizedBox(
          width: 20 / 2,
        )
      ],
    );
  }
}


