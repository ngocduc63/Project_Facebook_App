import 'dart:async';
import 'dart:math';

import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/constants/enum_common.dart';
import 'package:facebook/constants/global_variables.dart';
import 'package:facebook/controllers/socket_controller.dart';
import 'package:facebook/controllers/user_controller/user_controller.dart';
import 'package:facebook/features/comment/screens/comment_screen.dart';
import 'package:facebook/features/news-feed/screen/multiple_images_post_screen.dart';
import 'package:facebook/features/news-feed/widgets/post_1_child.dart';
import 'package:facebook/features/news-feed/widgets/post_content.dart';
import 'package:facebook/features/news-feed/widgets/reaction_button.dart';
import 'package:facebook/features/news-feed/widgets/video_widget.dart';
import 'package:facebook/models/post_model.dart';
import 'package:facebook/utils/convert_time.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../personal-page/screens/personal_page_screen.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class PostCard extends StatefulWidget {
  final PostModel post;
  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool postVisible = true;
  bool isLoadingLike = false;
  bool isLoading = false;
  List<String> icons = [];
  double maxHeight = 400;
  int totalItem = 0;

  UserController userController = UserController();
  Map<String, dynamic> userHasLike = {
    'image': 'assets/images/like.png',
    'color': Colors.black87,
    'text': 'Thích',
    'isLiked': false,
  };

  late io.Socket? socket;
  bool connectedSocket = false;
  late int numLike;
  late int numComment;
  late int numShare;
  late List<Map<String, dynamic>> reactions;

  Future<void> handleLike(Emotion likeCategory) async {
    setState(() {
      isLoadingLike = true;
    });

    if (!userHasLike['isLiked'] || likeCategory != Emotion.none) {
      final check =
          await userController.likePostController(widget.post.id, likeCategory);

      if (check) {
        await setUserHasLike(likeCategory);
      }
    } else {
      final check = await userController.unLikePostController(widget.post.id);

      if (check) {
        await setUserHasLike(null);
      }
    }

    setState(() {
      isLoadingLike = false;
    });
  }

  Future<void> handleChangeLike(Emotion likeCategory) async {
    final check = await userController.updateLikePostController(
        widget.post.id, likeCategory);

    if (check) {
      await setUserHasLike(likeCategory);
    }
  }

  Future<void> setUserHasLike(Emotion? react) async {
    setState(() {
      final reaction = react?.value;
      if (reaction == Emotion.like.value) {
        userHasLike['image'] = 'assets/images/reactions/like.png';
        userHasLike['text'] = 'Thích';
        userHasLike['color'] = GlobalVariables.secondaryColor;
        userHasLike['isLiked'] = true;
      } else if (reaction == Emotion.haha.value) {
        userHasLike['image'] = 'assets/images/reactions/haha.png';
        userHasLike['text'] = 'Haha';
        userHasLike['color'] = const Color.fromARGB(247, 226, 195, 18);
        userHasLike['isLiked'] = true;
      } else if (reaction == Emotion.love.value) {
        userHasLike['image'] = 'assets/images/reactions/love.png';
        userHasLike['text'] = 'Yêu thích';
        userHasLike['color'] = Colors.red;
        userHasLike['isLiked'] = true;
      } else if (reaction == Emotion.lovelove.value) {
        userHasLike['image'] = 'assets/images/reactions/care.png';
        userHasLike['text'] = 'Thương Thương';
        userHasLike['color'] = Colors.red;
        userHasLike['isLiked'] = true;
      } else if (reaction == Emotion.wow.value) {
        userHasLike['image'] = 'assets/images/reactions/wow.png';
        userHasLike['text'] = 'Wow';
        userHasLike['color'] = const Color.fromARGB(247, 226, 195, 18);
        userHasLike['isLiked'] = true;
      } else if (reaction == Emotion.sad.value) {
        userHasLike['image'] = 'assets/images/reactions/sad.png';
        userHasLike['text'] = 'Buồn';
        userHasLike['color'] = const Color.fromARGB(247, 226, 195, 18);
        userHasLike['isLiked'] = true;
      } else if (reaction == Emotion.angry.value) {
        userHasLike['image'] = 'assets/images/reactions/angry.png';
        userHasLike['text'] = 'Tức giận';
        userHasLike['color'] = Colors.deepOrange;
        userHasLike['isLiked'] = true;
      } else {
        userHasLike['image'] = 'assets/images/like.png';
        userHasLike['text'] = 'Thích';
        userHasLike['color'] = Colors.black87;
        userHasLike['isLiked'] = false;
      }
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    setupNotiPost();
    setUserHasLike(widget.post.reaction);
    setListReactions(widget.post.reactions ?? []);
    setState(() {
      totalItem =
          (widget.post.image?.length ?? 0) + (widget.post.video?.length ?? 0);
    });
  }

  void setListReactions(List<Map<String, dynamic>> dataReactions) {
    setState(() {
      reactions = dataReactions;
      icons = [];
      if (reactions.isNotEmpty) {
        reactions.sort((a, b) => b['count'].compareTo(a['count']));

        var topReations = reactions.take(3);

        for (var reaction in topReations) {
          if (reaction['type'] == Emotion.like.value) {
            icons.add('assets/images/reactions/like.png');
          } else if (reaction['type'] == Emotion.haha.value) {
            icons.add('assets/images/reactions/haha.png');
          } else if (reaction['type'] == Emotion.love.value) {
            icons.add('assets/images/reactions/love.png');
          } else if (reaction['type'] == Emotion.lovelove.value) {
            icons.add('assets/images/reactions/care.png');
          } else if (reaction['type'] == Emotion.wow.value) {
            icons.add('assets/images/reactions/wow.png');
          } else if (reaction['type'] == Emotion.sad.value) {
            icons.add('assets/images/reactions/sad.png');
          } else if (reaction['type'] == Emotion.angry.value) {
            icons.add('assets/images/reactions/angry.png');
          }
        }
      }
    });
  }

  void setupNotiPost() {
    socket = SocketController.instance.getSocket();
    numLike = widget.post.numLike ?? 0;
    numComment = widget.post.numShare ?? 0;
    numShare = widget.post.numComment ?? 0;
  }

  void connectionSocket() {
    if (connectedSocket) return;

    if (socket != null) {
      socket!.emit('join_post_noti', {"postId": widget.post.id});

      socket!.on('notification_for_post_${widget.post.id}', (data) {
        final postData = PostModel.fromJson(data);

        if (postData.id == widget.post.id) {
          setState(() {
            numLike = postData.numLike ?? 0;
            numComment = postData.numComment ?? 0;
            numShare = postData.numShare ?? 0;
            setListReactions(postData.reactions ?? []);
          });
        }
      });
    }

    connectedSocket = true;
  }

  void disConnectionSocket() {
    if (socket != null) {
      socket!.emit('leave_post_noti', {"postId": widget.post.id});
    }

    connectedSocket = false;
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.post.id),
      onVisibilityChanged: (info) {
        if (info.visibleFraction <= 0 && connectedSocket) {
          disConnectionSocket();
        } else {
          connectionSocket();
        }
      },
      child: postVisible
          ? isLoading
              ? const CircularProgressIndicator(
                  color: GlobalVariables.secondaryColor,
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.black12,
                                    width: 0.5,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundImage: CachedNetworkImageProvider(
                                      '${ApiConfig.linkImage}${widget.post.user!.avatar}'),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 2),
                                      child: Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                PersonalPageScreen.routeName,
                                                arguments: widget.post.user,
                                              );
                                            },
                                            child: Text(
                                              widget.post.user!.name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          (widget.post.user!.verified == true
                                              ? const Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 5),
                                                  child: Icon(
                                                    Icons.verified,
                                                    color: Colors.blue,
                                                    size: 15,
                                                  ),
                                                )
                                              : const SizedBox()),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          convertToTimeAgo(widget.post.time),
                                          style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 14),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.only(top: 2),
                                          child: Icon(
                                            Icons.circle,
                                            size: 2,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Icon(
                                          widget.post.shareWith ==
                                                  PostStatus.public
                                              ? Icons.public
                                              : widget.post.shareWith ==
                                                      PostStatus.friend
                                                  ? Icons.people
                                                  : Icons.lock,
                                          color: Colors.black54,
                                          size: 14,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: PostContent(text: widget.post.content!),
                    ),
                    ((widget.post.video != null
                                    ? widget.post.video!.length
                                    : 0) +
                                (widget.post.image != null
                                    ? widget.post.image!.length
                                    : 0) ==
                            1)
                        ? PostWidget1Child(
                            post: widget.post,
                            isImage:
                                widget.post.image!.isNotEmpty ? true : false,
                            index: 0,
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.post.image != null ||
                                  widget.post.video != null) ...[
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      MultipleImagesPostScreen.routeName,
                                      arguments: widget.post,
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      if (widget.post.image != null &&
                                          widget.post.image!.isNotEmpty)
                                        FadeInImage(
                                          placeholder:
                                              AssetImage('assets/loading.gif'),
                                          image: NetworkImage(
                                            '${ApiConfig.linkImage}${widget.post.image![0]}',
                                          ),
                                          fit: BoxFit.cover,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              1 /
                                              2 *
                                              0.99, // Chiều rộng
                                          height: maxHeight, // Chiều cao
                                        )
                                      else if (widget.post.video != null &&
                                          widget.post.video!.isNotEmpty)
                                        VideoWidget(
                                            videoUrl:
                                                '${ApiConfig.linkVideo}${widget.post.video![0]}',
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                1 /
                                                2 *
                                                0.99,
                                            height: maxHeight),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.01),
                                Expanded(
                                  child: Column(
                                    children: [
                                      for (int i = 1;
                                          i < min(totalItem, 4);
                                          i++)
                                        Padding(
                                          padding: EdgeInsets.only(
                                            bottom: i < min(totalItem, 4) - 1
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.01
                                                : 0,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                MultipleImagesPostScreen
                                                    .routeName,
                                                arguments: widget.post,
                                              );
                                            },
                                            child: Stack(
                                              children: [
                                                if (i <
                                                    widget.post.image!.length)
                                                  FadeInImage(
                                                    placeholder: AssetImage(
                                                        'assets/loading.gif'),
                                                    image: NetworkImage(
                                                      '${ApiConfig.linkImage}${widget.post.image![i]}',
                                                    ),
                                                    fit: BoxFit.cover,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            1 /
                                                            2 *
                                                            0.99, // Chiều rộng
                                                    height: totalItem == 2
                                                        ? maxHeight
                                                        : totalItem == 3
                                                            ? maxHeight / 2
                                                            : maxHeight /
                                                                3, // Chiều cao
                                                  ),
                                                if (i >=
                                                    widget.post.image!.length)
                                                  VideoWidget(
                                                    videoUrl:
                                                        '${ApiConfig.linkVideo}${widget.post.video![i - widget.post.image!.length]}',
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            2 *
                                                            0.99,
                                                    height: totalItem == 2
                                                        ? maxHeight
                                                        : totalItem == 3
                                                            ? maxHeight / 2
                                                            : maxHeight / 3,
                                                  ),
                                                if (i == 3 && totalItem > 4)
                                                  Positioned.fill(
                                                    child: Center(
                                                      child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        color: Colors.black
                                                            .withOpacity(0.3),
                                                        child: Text(
                                                          '+${widget.post.image!.length + widget.post.video!.length - 4}',
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 18,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, CommentScreen.routeName,
                              arguments: widget.post);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 10,
                            bottom: 8,
                            left: 15,
                            right: 15,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  icons.isNotEmpty
                                      ? Row(
                                          children: [
                                            SizedBox(
                                              width: icons.length < 3
                                                  ? icons.length * 20
                                                  : 60,
                                              height: 24,
                                              child: Stack(
                                                children: [
                                                  // Kiểm tra và hiển thị hình ảnh đầu tiên nếu có
                                                  if (icons.isNotEmpty)
                                                    Positioned(
                                                      top: 0,
                                                      left: 0,
                                                      child: Container(
                                                        width: 20,
                                                        height: 20,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          border: Border.all(
                                                            color: Colors.white,
                                                            width: 2,
                                                          ),
                                                        ),
                                                        child: Image.asset(
                                                          icons[0],
                                                          width: 20,
                                                          height: 20,
                                                          fit: BoxFit
                                                              .cover, // Đảm bảo ảnh không vượt quá kích thước
                                                        ),
                                                      ),
                                                    ),

                                                  // Kiểm tra và hiển thị hình ảnh thứ hai nếu có
                                                  if (icons.length > 1)
                                                    Positioned(
                                                      top: 2,
                                                      left: 18,
                                                      child: Container(
                                                        width: 20,
                                                        height: 20,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          border: Border.all(
                                                            color: Colors.white,
                                                            width: 2,
                                                          ),
                                                        ),
                                                        child: Image.asset(
                                                          icons[1],
                                                          width: 20,
                                                          height: 20,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),

                                                  // Kiểm tra và hiển thị hình ảnh thứ ba nếu có
                                                  if (icons.length > 2)
                                                    Positioned(
                                                      top: 4,
                                                      left: 36,
                                                      child: Container(
                                                        width: 20,
                                                        height: 20,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          border: Border.all(
                                                            color: Colors.white,
                                                            width: 2,
                                                          ),
                                                        ),
                                                        child: Image.asset(
                                                          icons[2],
                                                          width: 20,
                                                          height: 20,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),

                                            // Khoảng cách giữa văn bản và biểu tượng kiểm tra
                                            const SizedBox(
                                                width:
                                                    4), // Khoảng cách giữa biểu tượng và văn bản
                                            Text(
                                              '$numLike',
                                              style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                          ],
                                        )
                                      : Container(),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    '$numComment bình luận',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5),
                                    child: Icon(
                                      Icons.circle,
                                      size: 3,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    '$numShare lượt chia sẻ',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black54,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Divider(
                        color: Colors.black38,
                        height: 0,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ReactionButton(
                          initialReaction: widget.post.reaction ?? Emotion.none,
                          onReactionChanged: (reaction) {
                            handleChangeLike(reaction);
                          },
                          userHasLike: userHasLike,
                          handleLike: (reaction) {
                            handleLike(reaction);
                          },
                        ),
                        InkWell(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            alignment: Alignment.center,
                            width: (MediaQuery.of(context).size.width) / 3,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ImageIcon(
                                  AssetImage('assets/images/comment.png'),
                                  size: 22,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text(
                                    'Bình luận',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            alignment: Alignment.center,
                            width: (MediaQuery.of(context).size.width) / 3,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ImageIcon(
                                  AssetImage('assets/images/share.png'),
                                  size: 27,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text(
                                    'Chia sẻ',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                )
          : Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Row(
                    children: [
                      Icon(
                        Icons.visibility_off_rounded,
                        color: GlobalVariables.secondaryColor,
                        size: 14,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Đã ẩn',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Việc ẩn bài viết giúp Facebook cá nhân hóa Bảng feed của bạn.',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            postVisible = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          shadowColor: Colors.transparent,
                        ),
                        child: const Text(
                          'Hoàn tác',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    color: Colors.black12,
                    thickness: 0.5,
                    height: 20,
                  ),
                  Row(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black12,
                            width: 0.5,
                          ),
                        ),
                        child: CircleAvatar(
                          backgroundImage: AssetImage(
                            widget.post.user!.avatar,
                          ),
                          radius: 15,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Tạm ẩn ${widget.post.user!.name} trong 30 ngày',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Icon(
                        Icons.feedback_rounded,
                        color: Colors.black,
                        size: 30,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Báo cáo bài viết',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Row(
                    children: [
                      Icon(
                        Icons.view_list_rounded,
                        color: Colors.black,
                        size: 30,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Quản lý Bảng feed',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
    );
  }
}
