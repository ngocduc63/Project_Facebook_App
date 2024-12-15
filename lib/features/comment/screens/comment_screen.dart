import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/constants/enum_common.dart';
import 'package:facebook/constants/global_variables.dart';
import 'package:facebook/controllers/api_controller.dart';
import 'package:facebook/controllers/socket_controller.dart';
import 'package:facebook/features/comment/widgets/single_comment.dart';
import 'package:facebook/models/comment_model.dart';
import 'package:facebook/models/post_model.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class CommentScreen extends StatefulWidget {
  static const String routeName = '/comment-screen';
  final PostModel post;
  const CommentScreen({super.key, required this.post});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  ApiController _apiController = ApiController();
  ScrollController scrollController = ScrollController();
  final TextEditingController commentController = TextEditingController();
  FocusNode commentFocusNode = FocusNode();
  List<String> icons = [];
  bool isInWidgetTree = true;
  final List<CommentModel> listCommnets = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasNextPage = true;
  int page = 0;
  int limit = 10;
  String? parentCommentId = "";

  late io.Socket? socket;


  Future<void> _fetchComments() async {
    setState(() {
      if (page > 0) {
        isLoadingMore = true;
      }
    });

    page++;
    try {
      final response = await _apiController.get(ApiConfig.getComments, {
        "postId": widget.post.id,
        "page": page,
        "limit": limit,
      });

      List<CommentModel> data = (response.data['metadata']['comments'] as List)
          .map((comment) => CommentModel.fromJson(comment))
          .toList();

      setState(() {
        listCommnets.addAll(data);
        isLoading = false;
        isLoadingMore = false;
        hasNextPage = response.data['metadata']['totalPage'] > page;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> createCommment() async {
    final String content = commentController.text.trim();

    try {
      final response = await _apiController.post(ApiConfig.commentPost, {
        'postId': widget.post.id,
        'content': content,
        "parentCommentId": parentCommentId
      });
      final CommentModel dataComment =
          CommentModel.fromJson(response.data['metadata']);

      setState(() {
        if (parentCommentId!.isEmpty) {
          listCommnets.insert(0, dataComment);
        } else {
          var parentComment = listCommnets.firstWhere((comment) => comment.id == parentCommentId);
          parentComment.incrementChildCount();
        }
        parentCommentId = "";
        commentController.clear();
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> onReply(String? parentId, BuildContext context) async {
    parentCommentId = parentId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(commentFocusNode);
    });
  }

  @override
  void initState() {
    setState(() {
      _fetchComments();
      final reactions = widget.post.reactions;
      icons = [];
      if (reactions != null && reactions.isNotEmpty) {
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
    connectSocket();
    super.initState();
  }

  void connectSocket() {
    socket = SocketController.instance.getSocket();
    if (socket != null) {
      socket!.emit('join_comment_noti', {"postId": widget.post.id});

      socket!.on('noti_for_post_comment_${widget.post.id}', (data) {
        final CommentModel dataComment = CommentModel.fromJson(data);
        String parentId = data?['commnet_parentId'] ?? '';
        setState(() {
        if (parentId.isEmpty) {
          listCommnets.insert(0, dataComment);
        } else {
          var parentComment = listCommnets.firstWhere((comment) => comment.id == parentId);
          parentComment.incrementChildCount();
        }
        commentController.clear();
      });
      });
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          !isLoading &&
          !isLoadingMore &&
          hasNextPage) {
        _fetchComments();
      }
    });

    return isInWidgetTree
        ? Dismissible(
            direction: DismissDirection.down,
            onDismissed: (direction) {
              setState(() {
                isInWidgetTree = false;
              });
              Navigator.pop(context);
            },
            key: const Key('comment-screen'),
            child: SafeArea(
              child: Material(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    children: [
                      BackdropFilter(
                        filter: ColorFilter.mode(
                            Colors.black.withOpacity(0.4), BlendMode.darken),
                        child: Container(
                          decoration:
                              const BoxDecoration(color: Colors.transparent),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 60,
                              padding: const EdgeInsets.only(
                                left: 15,
                                right: 15,
                                top: 15,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  icons.isNotEmpty
                                      ? Row(
                                          children: [
                                            SizedBox(
                                              width: icons.length < 3
                                                  ? icons.length * 25
                                                  : 100,
                                              height: 34,
                                              child: Stack(
                                                children: [
                                                  if (icons.isNotEmpty)
                                                    Positioned(
                                                      top: 0,
                                                      left: 0,
                                                      child: Container(
                                                        width: 26,
                                                        height: 26,
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
                                                          width: 26,
                                                          height: 26,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                  if (icons.length > 1)
                                                    Positioned(
                                                      top: 2,
                                                      left: 18,
                                                      child: Container(
                                                        width: 26,
                                                        height: 26,
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
                                                          width: 26,
                                                          height: 26,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                  if (icons.length > 2)
                                                    Positioned(
                                                      top: 4,
                                                      left: 36,
                                                      child: Container(
                                                        width: 26,
                                                        height: 26,
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
                                                          width: 26,
                                                          height: 26,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              widget.post.numLike.toString(),
                                              style: TextStyle(
                                                color: AppColors.blackColor,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                          ],
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                            const Divider(
                              thickness: 1,
                              color: AppColors.darkGreyColor,
                            ),
                            Expanded(
                              child: isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: GlobalVariables.secondaryColor,
                                      ),
                                    )
                                  : SingleChildScrollView(
                                      controller: scrollController,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 25),
                                        child: Column(
                                          children: [
                                            for (int i = 0;
                                                i < listCommnets.length;
                                                i++)
                                              SingleComment(
                                                comment: listCommnets[i],
                                                level: 0,
                                                onReply: onReply,
                                              ),
                                            if (isLoadingMore)
                                              Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  color: GlobalVariables
                                                      .secondaryColor,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                            ),
                            // Sử dụng Padding để input nằm trên bàn phím khi mở
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: commentController,
                                        focusNode: commentFocusNode,
                                        cursorColor: AppColors.lightBlueColor,
                                        decoration: InputDecoration(
                                          hintText: 'Nhập bình luận của bạn...',
                                          hintStyle: TextStyle(
                                              color: AppColors.darkGreyColor),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.send),
                                      color: AppColors.lightBlueColor,
                                      onPressed: () {
                                        // onReply();
                                        if (commentController.text
                                            .trim()
                                            .isNotEmpty) {
                                          createCommment();
                                          FocusScope.of(context).unfocus();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : const SizedBox();
  }
}
