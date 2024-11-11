import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/constants/router_constants.dart';
import 'package:facebook/features/chat/widgets/body_chat_list.dart';
import 'package:facebook/models/user_model.dart';
import 'package:facebook/utils/prefs_user.dart';
import 'package:flutter/material.dart';

class ChatsScreen extends StatefulWidget {
  static const String routeName = RouterConstants.chat;
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  int _selectedIndex = 1;
  UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    setState(() {
      currentUser = UserServicePref.instance.getUserInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.lightBlueColor,
            actions: [
              IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.search,
                    color: AppColors.whiteColor,
                  ))
            ],
            title: const Text(
              'Đoạn chat',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.whiteColor,
              ),
            )),
        body: const Body(),
        floatingActionButton: FloatingActionButton(
          onPressed: (() {}),
          backgroundColor: AppColors.darkGreyColor,
          child: const Icon(Icons.person_add_alt_1, color: Colors.white),
        ),
        bottomNavigationBar: buildBottomNavigationBar());
  }

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (value) {
        setState(() {
          _selectedIndex = value;
        });
      },
      // type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
            icon: Icon(
              Icons.message,
              color: AppColors.blackColor,
            ),
            label: 'Chats'),
        BottomNavigationBarItem(
            icon: Icon(Icons.people, color: AppColors.blackColor),
            label: 'People'),
        BottomNavigationBarItem(
            icon: Icon(Icons.call, color: AppColors.blackColor),
            label: 'Calls'),
        BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 16,
              backgroundImage:
                  NetworkImage('${ApiConfig.linkImage}${currentUser?.avatar}'),
            ),
            label: 'Profile'),
      ],
    );
  }
}
