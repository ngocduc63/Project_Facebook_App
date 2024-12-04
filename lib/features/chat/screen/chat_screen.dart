import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/constants/router_constants.dart';
import 'package:facebook/features/chat/screen/user_online_screen.dart';
import 'package:facebook/features/chat/widgets/body_chat_list.dart';
import 'package:facebook/features/personal-page/screens/personal_page_screen.dart';
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
  int _selectedIndex = 0;
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
            ),
          )
        ],
        title: Row(
          children: [
            const BackButton(color: AppColors.whiteColor),
            const Text(
              'Đoạn chat',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.whiteColor,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Visibility(
            visible: _selectedIndex == 0,
            child: const Expanded(child: Body()),
          ),
          
          Visibility(
            visible: _selectedIndex == 1,
            child: const Expanded(child: UserOnlineScreen()),
          ),
          
          // // 3. Empty container for calls tab
          // Visibility(
          //   visible: _selectedIndex == 2,
          //   child: Container(),
          // ),
          
          Visibility(
            visible: _selectedIndex == 2,
            child: Expanded(
              child: PersonalPageScreen(user: currentUser!),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (() {
          Navigator.pushNamed(context, RouterConstants.createGroupChat);
        }),
        backgroundColor: AppColors.darkGreyColor,
        child: const Icon(Icons.person_add_alt_1, color: Colors.white),
      ),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: AppColors.lightBlueColor,
      selectedIconTheme: IconThemeData(color: AppColors.lightBlueColor),
      unselectedIconTheme: IconThemeData(color: AppColors.blackColor),
      onTap: (value) {
        setState(() {
          _selectedIndex = value;
        });
      },
      items: [
        BottomNavigationBarItem(
            icon: Icon(
              Icons.chat_bubble,
            ),
            label: 'Nhắn tin'),
        BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Mọi Người'),
        // BottomNavigationBarItem(
        //     icon: Icon(Icons.call),
        //     label: 'Gọi điện'),
        BottomNavigationBarItem(
          icon: CircleAvatar(
            radius: 16,
            backgroundImage:
                NetworkImage('${ApiConfig.linkImage}${currentUser?.avatar}'),
          ),
          label: 'Trang cá nhân',
        ),
      ],
    );
  }
}
