import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/constants/enum_common.dart';
import 'package:facebook/constants/global_variables.dart';
import 'package:facebook/controllers/socket_controller.dart';
import 'package:facebook/controllers/user_controller/user_controller.dart';
import 'package:facebook/features/comment/screens/comment_screen.dart';
import 'package:facebook/features/news-feed/widgets/post_1_child.dart';
import 'package:facebook/features/news-feed/widgets/post_content.dart';
import 'package:facebook/features/news-feed/widgets/reaction_button.dart';
import 'package:facebook/features/news-feed/widgets/single_image.dart';
import 'package:facebook/models/post_model.dart';
import 'package:facebook/utils/convert_time.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class MultipleImagesPostScreen extends StatefulWidget {
  static const String routeName = '/multiple-images';
  final PostModel post;
  const MultipleImagesPostScreen({super.key, required this.post});

  @override
  State<MultipleImagesPostScreen> createState() =>
      _MultipleImagesPostScreenState();
}

class _MultipleImagesPostScreenState extends State<MultipleImagesPostScreen> {
  List<String> icons = [];
  final Random random = Random();
  int totalReactions = 0;
  Map<String, dynamic> userHasLike = {
    'image': 'assets/images/like.png',
    'color': Colors.black87,
    'text': 'Thích',
    'isLiked': false,
  };
  bool isLoadingLike = false;
  late io.Socket? socket;
  late int numLike;
  late int numComment;
  late int numShare;
  late List<Map<String, dynamic>> reactions;
  UserController userController = UserController();

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
    connectionSocket();
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
  }

  void disConnectionSocket() {
    if (socket != null) {
      socket!.emit('leave_post_noti', {"postId": widget.post.id});
      socket!.off('notification_for_post_${widget.post.id}');
    }
  }

  @override
  void dispose() {
    super.dispose();
    disConnectionSocket();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  top: 10,
                ),
                child: Row(
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
                                Text(
                                  widget.post.user!.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                // (widget.post.user.verified == true
                                //     ? const Padding(
                                //         padding: EdgeInsets.only(left: 5),
                                //         child: Icon(
                                //           Icons.verified,
                                //           color: Colors.blue,
                                //           size: 15,
                                //         ),
                                //       )
                                //     : const SizedBox()),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 300,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    convertToTimeAgo(widget.post.time),
                                    style: const TextStyle(
                                        color: Colors.black54, fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 2),
                                  child: Icon(
                                    Icons.circle,
                                    size: 3,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Icon(
                                  Icons.public,
                                  color: Colors.black54,
                                  size: 14,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              PostContent(text: widget.post.content!),
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
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
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
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
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
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
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
                              padding: EdgeInsets.symmetric(horizontal: 5),
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
                    onTap: () {
                      Navigator.pushNamed(context, CommentScreen.routeName,
                          arguments: widget.post);
                    },
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
              Container(
                width: double.infinity,
                height: 5,
                color: Colors.black26,
              ),
              for (int i = 0; i < widget.post.image!.length; i++)
                Column(
                  children: [
                    SingleImage(
                      post: widget.post.copyWith(
                        image: [widget.post.image![i]],
                        content: '',
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 5,
                      color: Colors.black26,
                    ),
                  ],
                ),
              for (int i = 0; i < widget.post.video!.length; i++)
                Column(
                  children: [
                    PostWidget1Child(
                      post: widget.post.copyWith(
                        image: [widget.post.video![i]],
                        content: '',
                      ),
                      isImage: false,
                      index: 0,
                    ),
                    Container(
                      width: double.infinity,
                      height: 5,
                      color: Colors.black26,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
