import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/constants/enum_common.dart';
import 'package:facebook/controllers/api_controller.dart';
import 'package:facebook/features/chat/screen/message_screen.dart';
import 'package:facebook/models/chat_model.dart';
import 'package:flutter/material.dart';

class FriendButton extends StatefulWidget {
  final FriendStatus friendStatus;
  final String friendId;

  const FriendButton(
      {super.key, required this.friendStatus, required this.friendId});
  @override
  State<FriendButton> createState() => _FriendButtonState();
}

class _FriendButtonState extends State<FriendButton> {
  late FriendStatus dataActionFriend = widget.friendStatus;
  bool isLoading = false;
  ApiController apiController = ApiController();

  Map<String, String> getDataFriend() {
    if (dataActionFriend == FriendStatus.friend) {
      return {'icon': 'assets/images/friend.png', 'text': 'Bạn bè'};
    } else if (dataActionFriend == FriendStatus.follow) {
      return {
        'icon': 'assets/images/accept_friend.png',
        'text': 'Đã gửi lời mời'
      };
    } else if (dataActionFriend == FriendStatus.waitAcp) {
      return {
        'icon': 'assets/images/accept_friend.png',
        'text': 'Chấp nhận lời mời'
      };
    }
    return {'icon': 'assets/images/friend.png', 'text': 'Thêm bạn bè'};
  }

  Future<void> _handlePopupMenuSelection(String value) async {
    switch (value) {
      case 'block':
        print('Block friend: ${widget.friendId}');
      case 'unfriend':
        await handleUnfriend();
      case 'report':
        print('Report: ${widget.friendId}');
    }
  }

  Future<void> handleActionBtnFriend() async {
    if (dataActionFriend == FriendStatus.friend) {
      return;
    } else if (dataActionFriend == FriendStatus.follow) {
      return;
    } else if (dataActionFriend == FriendStatus.waitAcp) {
      setState(() {
        isLoading = true;
      });
      // acp friend
      try {
        final response = await apiController
            .put(ApiConfig.acpFriend, {'friendId': widget.friendId});
        if (response.statusCode == 200) {
          final roomData = response.data['roomId'];
          setState(() {
            dataActionFriend = FriendStatus.friend;
          });
        }
      } catch (e) {
        print(e);
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      // add friend
      setState(() {
        isLoading = true;
      });
      try {
        final response = await apiController
            .post(ApiConfig.addFriend, {'friendId': widget.friendId});
        if (response.statusCode == 200) {
          setState(() {
            dataActionFriend = FriendStatus.follow;
          });
        }
      } catch (e) {
        print(e);
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> handleDeclineFriend() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await apiController
          .delete(ApiConfig.declineFriend, {'friendId': widget.friendId});
      if (response.statusCode == 200) {
        setState(() {
          dataActionFriend = FriendStatus.unfriend;
        });
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> handleUnfriend() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await apiController
          .put(ApiConfig.unfriend, {'friendId': widget.friendId});
      if (response.statusCode == 200) {
        setState(() {
          dataActionFriend = FriendStatus.unfriend;
        });
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> handleNavigateChat(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await apiController.get(
        ApiConfig.getRoomInfo,
        {'friendId': widget.friendId},
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
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final datafriend = getDataFriend();
    return isLoading
        ? Center(
            child: CircularProgressIndicator(
              color: AppColors.lightBlueColor,
            ),
          )
        : Row(
            children: [
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: handleActionBtnFriend,
                  style: ElevatedButton.styleFrom(
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    backgroundColor: dataActionFriend == FriendStatus.waitAcp
                        ? AppColors.lightBlueColor
                        : Colors.grey[200],
                    padding: EdgeInsets.zero,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (datafriend['icon'] != null)
                        ImageIcon(
                          AssetImage(datafriend['icon'] ?? ''),
                          size: 16,
                          color: dataActionFriend == FriendStatus.waitAcp
                              ? AppColors.whiteColor
                              : AppColors.blackColor,
                        ),
                      const SizedBox(width: 5),
                      Text(
                        datafriend['text'] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          color: dataActionFriend == FriendStatus.waitAcp
                              ? AppColors.whiteColor
                              : AppColors.blackColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (FriendStatus.friend == dataActionFriend)
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: () {
                      handleNavigateChat(context);
                    },
                    style: ElevatedButton.styleFrom(
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      backgroundColor: Colors.blue[700],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ImageIcon(
                          AssetImage('assets/images/message.png'),
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Nhắn tin',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(width: 10),
              if (FriendStatus.waitAcp == dataActionFriend ||
                  FriendStatus.follow == dataActionFriend)
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: handleDeclineFriend,
                    style: ElevatedButton.styleFrom(
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      backgroundColor: AppColors.darkGreyColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ImageIcon(
                          AssetImage('assets/images/unfriend.png'),
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 5),
                        Text(
                          FriendStatus.waitAcp == dataActionFriend
                              ? 'Từ chối'
                              : 'Hủy lời mời',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(width: 10),
              if (FriendStatus.friend == dataActionFriend)
                Expanded(
                  flex: 1,
                  child: PopupMenuButton<String>(
                    onSelected: _handlePopupMenuSelection,
                    icon: const Icon(
                      Icons.more_horiz_rounded,
                      size: 20,
                      color: Colors.black,
                    ),
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'unfriend',
                        child: Text('Hủy kết bạn'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'block',
                        child: Text('Chặn bạn bè'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'report',
                        child: Text('Báo cáo'),
                      ),
                    ],
                  ),
                ),
            ],
          );
  }
}
