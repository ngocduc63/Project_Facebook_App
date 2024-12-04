import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/constants/router_constants.dart';
import 'package:facebook/controllers/api_controller.dart';
import 'package:facebook/features/chat/screen/message_screen.dart';
import 'package:facebook/models/chat_model.dart';
import 'package:facebook/models/user_model.dart';
import 'package:flutter/material.dart';

class UserOnlineScreen extends StatefulWidget {
  const UserOnlineScreen({Key? key}) : super(key: key);

  @override
  State<UserOnlineScreen> createState() => _UserOnlineScreenState();
}

class _UserOnlineScreenState extends State<UserOnlineScreen> {
  List<UserModel> onlineUsers = [];
  bool isLoading = true;
  ApiController apiController = ApiController();

  @override
  void initState() {
    super.initState();
    fetchFriends();
  }

  Future<void> fetchFriends() async {
    try {
      final response = await apiController.get(ApiConfig.getUserOnline, {});

      List<UserModel> data = (response.data['metadata'] as List)
          .where((user) => user != null)
          .map((user) => UserModel.fromJson(user))
          .toList();
      setState(() {
        onlineUsers.addAll(data);
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> navigateToMessageScreen(
      BuildContext context, String friendId) async {
    try {
      final response = await apiController.get(
        ApiConfig.getRoomInfo,
        {'friendId': friendId},
      );
      if (response.statusCode == 200) {
        final ChatModel dataRoom =
            ChatModel.fromJson(response.data['metadata']);

        if (context.mounted) {
          Navigator.pushNamed(
            context,
            MessagesScreen.routeName,
            arguments: dataRoom,
          );
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(
              color: AppColors.lightBlueColor,
            ),
          )
        : ListView.builder(
            itemCount: onlineUsers.length,
            itemBuilder: (context, index) {
              final user = onlineUsers[index];
              return ListTile(
                onTap: () {
                  Navigator.pushNamed(context, RouterConstants.personalScreen,
                      arguments: user);
                },
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                leading: Stack(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage:
                          NetworkImage('${ApiConfig.linkImage}${user.avatar}'),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        height: 16,
                        width: 16,
                        decoration: BoxDecoration(
                          color: Color(0xFF00BF6D),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                title: Text(user.name),
                trailing: (user.isOnline ?? false)
                    ? IconButton(
                        icon: const Icon(Icons.message),
                        onPressed: () {
                          navigateToMessageScreen(context, user.id);
                        },
                      )
                    : SizedBox(),
              );
            },
          );
  }
}
