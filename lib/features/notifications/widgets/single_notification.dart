import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/constants/enum_common.dart';
import 'package:facebook/controllers/user_controller/user_controller.dart';
import 'package:facebook/features/news-feed/screen/multiple_images_post_screen.dart';
import 'package:facebook/features/notifications/screens/list_follow_screen.dart';
import 'package:facebook/features/personal-page/screens/personal_page_screen.dart';
import 'package:facebook/models/notification_model.dart';
import 'package:facebook/utils/convert_time.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SingleNotification extends StatefulWidget {
  final NotiModel notification;
  const SingleNotification({super.key, required this.notification});

  @override
  State<SingleNotification> createState() => _SingleNotificationState();
}

class _SingleNotificationState extends State<SingleNotification> {
  String content = '';
  UserController userController = UserController();

  @override
  void initState() {
    super.initState();
    setState(() {
      if (NotificationType.addFriend.value == widget.notification.type) {
        content = ' đã gửi lời mời kết bạn cho bạn';
      } else if (NotificationType.acpFriend.value == widget.notification.type) {
        content = ' đã chấp nhận lời mời kết bạn của bạn';
      } else if (NotificationType.likePost.value == widget.notification.type) {
        content = ' đã thả cảm xúc bài viết của bạn';
      } else if (NotificationType.commentPost.value ==
          widget.notification.type) {
        content = ' đã bình luận bài viết của bạn';
      } else if (NotificationType.sharePost.value == widget.notification.type) {
        content = ' đã chia sẻ bài viết của bạn';
      }
    });
  }

  Future<void> handleAcpFriend() async {
    final check = await userController.acpFriendController(
        widget.notification.sender.id, widget.notification.id);

    if (check) {
      Fluttertoast.showToast(
          msg: "Đồng ý kết bạn thành công",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP_LEFT,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: "Có lỗi xảy ra",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP_LEFT,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<void> handleDeclineFriend() async {
    final check = await userController.declineFriendController(
        widget.notification.sender.id, widget.notification.id);

    if (check) {
      Fluttertoast.showToast(
          msg: "Từ chối kết bạn thành công",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP_LEFT,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: "Có lỗi xảy ra",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP_LEFT,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  void handleNagivateToPersonal(BuildContext context) {
    Navigator.pushNamed(
      context,
      PersonalPageScreen.routeName,
      arguments: widget.notification.sender,
    );
  }

  Future<void> handleNavigateToPost(BuildContext context) async {
    final postData = await userController
        .getPostSingle(widget.notification.options!['postId']);
    if (postData != null) {
      if (context.mounted) {
        Navigator.pushNamed(
          context,
          MultipleImagesPostScreen.routeName,
          arguments: postData,
        );
      }
    } else {
      Fluttertoast.showToast(
          msg: "Có lỗi xảy ra",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP_LEFT,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<void> handleClickNotification(BuildContext context) async {
    if (NotificationType.addFriend.value == widget.notification.type) {
      Navigator.pushNamed(
          context,
          FollowScreen.routeName,
        );
    } else if (NotificationType.acpFriend.value == widget.notification.type) {
      Navigator.pushNamed(
          context,
          FollowScreen.routeName,
        );
    } else if (NotificationType.likePost.value == widget.notification.type) {
      await handleNavigateToPost(context);
    } else if (NotificationType.commentPost.value == widget.notification.type) {
      await handleNavigateToPost(context);
    } else if (NotificationType.sharePost.value == widget.notification.type) {
      return;
    }
  }

  Widget buildNotificationIcon() {
    if (widget.notification.type == NotificationType.sharePost.value) {
      return const Icon(
        Icons.share,
        color: Colors.blue,
        size: 30,
      );
    } else if (widget.notification.type == NotificationType.acpFriend.value ||
        widget.notification.type == NotificationType.addFriend.value) {
      return const Icon(
        Icons.person_rounded,
        color: Colors.white,
        size: 22,
      );
    } else if (widget.notification.type == NotificationType.likePost.value) {
      final likeCategory = widget.notification.options!['likeCategory'];
      return _buildReactionIcon(likeCategory);
    } else if (widget.notification.type == NotificationType.commentPost.value) {
      return const ImageIcon(
        AssetImage('assets/images/white-cmt.png'),
        color: Colors.white,
        size: 16,
      );
    } else {
      return const Icon(
        Icons.facebook,
        color: Colors.blue,
        size: 30,
      );
    }
  }

  Widget _buildReactionIcon(String likeCategory) {
    if (likeCategory == Emotion.like.value) {
      return Image.asset('assets/images/reactions/like.png');
    } else if (likeCategory == Emotion.love.value) {
      return Image.asset('assets/images/reactions/love.png');
    } else if (likeCategory == Emotion.haha.value) {
      return Image.asset('assets/images/reactions/haha.png');
    } else if (likeCategory == Emotion.wow.value) {
      return Image.asset('assets/images/reactions/wow.png');
    } else if (likeCategory == Emotion.lovelove.value) {
      return Image.asset('assets/images/reactions/care.png');
    } else if (likeCategory == Emotion.sad.value) {
      return Image.asset('assets/images/reactions/sad.png');
    } else if (likeCategory == Emotion.angry.value) {
      return Image.asset('assets/images/reactions/angry.png');
    } else {
      return const Icon(
        Icons.facebook,
        color: Colors.blue,
        size: 30,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await handleClickNotification(context);
        },
        child: Container(
          decoration: BoxDecoration(
            // color: widget.notification.seen == true
            //     ? Colors.white.withOpacity(0.1)
            //     : Colors.blue.withOpacity(0.1),
            color: Colors.white.withOpacity(0.1),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 10,
              top: 10,
              bottom: 10,
              right: 0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 60,
                  width: 60,
                  child: Stack(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black54,
                            width: 3,
                          ),
                        ),
                        child: Material(
                          type: MaterialType.circle,
                          clipBehavior: Clip.hardEdge,
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              // Xử lý sự kiện click vào avatar
                              handleNagivateToPersonal(context);
                            },
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(
                                '${ApiConfig.linkImage}${widget.notification.sender.avatar}',
                              ),
                              radius: 40,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                            padding: const EdgeInsets.all(0),
                            alignment: Alignment.center,
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: widget.notification.type ==
                                            'FRIEND-002' ||
                                        widget.notification.type == 'FRIEND-001'
                                    ? Colors.blue
                                    : widget.notification.type == 'POST-003'
                                        ? Colors.green[400]
                                        : widget.notification.type == 'page'
                                            ? Colors.orange
                                            : widget.notification.type ==
                                                    'group'
                                                ? Colors.blue
                                                : widget.notification.type ==
                                                        'security'
                                                    ? Colors.blue
                                                    : widget.notification
                                                                .type ==
                                                            'date'
                                                        ? Colors.purple
                                                        : widget.notification
                                                                    .type ==
                                                                'badge'
                                                            ? Colors
                                                                .yellow.shade700
                                                            : Colors.white),
                            child: buildNotificationIcon()),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                          text: TextSpan(
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              height: 1.4,
                            ),
                            children: [
                              TextSpan(
                                text: widget.notification.sender.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.blackColor,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    handleNagivateToPersonal(context);
                                  },
                              ),
                              TextSpan(
                                text: content,
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            convertToTimeAgo(widget.notification.time),
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (widget.notification.type == 'FRIEND-001')
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: handleAcpFriend,
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.all(5),
                                  ),
                                  child: const Text(
                                    'Chấp nhận',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: const Color.fromARGB(
                                          237, 219, 218, 218),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.all(5)),
                                  child: const Text(
                                    'Từ chối',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                            ],
                          )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 30,
                  height: 30,
                  child: IconButton(
                    padding: const EdgeInsets.all(5),
                    splashRadius: 20,
                    onPressed: () {},
                    icon: const Icon(
                      Icons.more_horiz_rounded,
                      size: 20,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
