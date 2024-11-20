import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/constants/enum_common.dart';
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
  Map<String, String> getDataFriend() {
    if (widget.friendStatus == FriendStatus.friend) {
      return {'icon': 'assets/images/friend.png', 'text': 'Bạn bè'};
    } else if (widget.friendStatus == FriendStatus.follow) {
      return {'icon': 'assets/images/accept_friend.png', 'text': 'Đã gửi lời mời'};
    } else if (widget.friendStatus == FriendStatus.waitAcp) {
      return {'icon': 'assets/images/accept_friend.png', 'text': 'Chấp nhận lời mời'};
    }
    return {'icon': 'assets/images/friend.png', 'text': 'Thêm bạn bè'};
  }

  void _handlePopupMenuSelection(String value) {
    switch (value) {
      case 'block':
        print('Block friend: ${widget.friendId}');
      case 'unfriend':
        print('Unfriend: ${widget.friendId}');
      case 'report':
        print('Report: ${widget.friendId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final datafriend = getDataFriend();
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: ElevatedButton(
            onPressed: () {
              // Thêm logic xử lý nút chính
              print('Friend button clicked');
            },
            style: ElevatedButton.styleFrom(
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              backgroundColor: widget.friendStatus == FriendStatus.waitAcp
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
                    color: widget.friendStatus == FriendStatus.waitAcp
                        ? AppColors.whiteColor
                        : AppColors.blackColor,
                  ),
                const SizedBox(width: 5),
                Text(
                  datafriend['text'] ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    color: widget.friendStatus == FriendStatus.waitAcp
                        ? AppColors.whiteColor
                        : AppColors.blackColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        if (FriendStatus.friend == widget.friendStatus)
          Expanded(
            flex: 3,
            child: ElevatedButton(
              onPressed: () {
                // Logic nhắn tin
                print('Message button clicked');
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
        Expanded(
          flex: 1,
          child: PopupMenuButton<String>(
            onSelected: _handlePopupMenuSelection,
            icon: const Icon(
              Icons.more_horiz_rounded,
              size: 20,
              color: Colors.black,
            ),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
