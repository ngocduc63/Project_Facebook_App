import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/constants/global_variables.dart';
import 'package:facebook/controllers/api_controller.dart';
import 'package:facebook/features/personal-page/screens/personal_page_screen.dart';
import 'package:facebook/models/comment_model.dart';
import 'package:facebook/utils/convert_time.dart';
import 'package:flutter/material.dart';

class SingleComment extends StatefulWidget {
  final CommentModel comment;
  final int level;
  final Future<void> Function(String?, BuildContext) onReply;
  const SingleComment({
    super.key,
    required this.comment,
    required this.level,
    required this.onReply,
  });

  @override
  State<SingleComment> createState() => _SingleCommentState();
}

Size _textSize(String text, TextStyle style) {
  final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr)
    ..layout(minWidth: 0, maxWidth: double.infinity);
  return textPainter.size;
}

class _SingleCommentState extends State<SingleComment> {
  bool viewReplies = false;
  List<CommentModel> listChildComments = [];
  ApiController _apiController = ApiController();
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasNextPage = true;
  int page = 0;
  int limit = 5;
  int totalComments = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      listChildComments = [];
    });
  }

  Future<void> _fetchChildComments() async {
    setState(() {
      page++;
      if (page == 1) {
        isLoading = true;
      } else {
        isLoadingMore = true;
      }
    });

    final response = await _apiController.get(ApiConfig.getComments, {
      "postId": widget.comment.postId,
      "parentCommentId": widget.comment.id,
      "page": page,
      "limit": limit,
    });

    List<CommentModel> data = (response.data['metadata']['comments'] as List)
        .map((comment) => CommentModel.fromJson(comment))
        .toList();

    setState(() {
      listChildComments.addAll(data);
      isLoading = false;
      hasNextPage = response.data['metadata']['totalPage'] > page;
      totalComments = response.data['metadata']['totalComments'];
    });
  }

  @override
  Widget build(BuildContext context) {
    double minContent = min(
      MediaQuery.of(context).size.width -
          15 * 2 -
          20 * 2 -
          5 -
          70 * widget.level,
      _textSize(
            widget.comment.content,
            const TextStyle(
              fontSize: 16,
              overflow: TextOverflow.visible,
            ),
          ).width +
          30,
    );

    double minName = _textSize(
          widget.comment.user.name,
          const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ).width +
        46;

    return Padding(
      padding: widget.level == 0
          ? const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 5,
            )
          : EdgeInsets.only(
              left: widget.level == 1 ? 45 : 45 + (widget.level - 1) * 35,
              top: 5,
              bottom: 5,
            ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black12,
                    width: 0.5,
                  ),
                  shape: BoxShape.circle,
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      PersonalPageScreen.routeName,
                      arguments: widget.comment.user,
                    );
                  },
                  child: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                        '${ApiConfig.linkImage}${widget.comment.user.avatar}'),
                    radius: widget.level > 0 ? 15 : 20,
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              (widget.comment.content.isNotEmpty)
                  ? Container(
                      width: minContent < minName ? minName : minContent,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    PersonalPageScreen.routeName,
                                    arguments: widget.comment.user,
                                  );
                                },
                                child: Text(
                                  widget.comment.user.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              (widget.comment.user.verified == true
                                  ? const Padding(
                                      padding: EdgeInsets.only(left: 5),
                                      child: Icon(
                                        Icons.verified,
                                        color: Colors.blue,
                                        size: 15,
                                      ),
                                    )
                                  : const SizedBox()),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.comment.content,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                        top: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            widget.comment.user.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          (widget.comment.user.verified == true
                              ? const Padding(
                                  padding: EdgeInsets.only(left: 2),
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
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          if (widget.comment.image != null)
            Padding(
              padding: EdgeInsets.only(
                bottom: 5,
                left: widget.level == 0 ? 45 : 45 + widget.level * 35,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  widget.comment.image!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: widget.level == 0 ? 50 : 40,
              ),
              Text(
                convertToTimeAgo(widget.comment.time),
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(
                width: 10,
              ),
              InkWell(
                onTap: () {
                  widget.onReply(widget.comment.id, context);
                },
                child: Text(
                  'Phản hồi',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
          if (widget.comment.countChild > 0 && !viewReplies)
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 40),
              child: InkWell(
                onTap: () async {
                  setState(() {
                    viewReplies = true;
                  });
                  await _fetchChildComments();
                },
                child: Text(
                  'Xem ${widget.comment.countChild!} phản hồi',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          if (viewReplies)
            isLoading
                ? Padding(
                    padding: const EdgeInsets.only(top: 10, left: 40),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: GlobalVariables.secondaryColor,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (int i = 0; i < listChildComments.length; i++)
                        SingleComment(
                          comment: listChildComments[i],
                          level: widget.level + 1,
                          onReply: widget.onReply,
                        ),
                      Padding(
                          padding: const EdgeInsets.only(top: 5, right: 300),
                          child: Column(children: [
                            if (widget.comment.countChild! - page * limit > 0)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 5,
                                  bottom: 15,
                                ),
                                child: InkWell(
                                    onTap: () async {
                                      setState(() {
                                        _fetchChildComments();
                                      });
                                    },
                                    child: Text(
                                      'Xem tiếp ${widget.comment.countChild! - page * limit} phản hồi',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 5,
                                bottom: 15,
                              ),
                              child: InkWell(
                                  onTap: () async {
                                    setState(() {
                                      viewReplies = false;
                                      listChildComments = [];
                                      page = 0;
                                      isLoading = false;
                                    });
                                  },
                                  child: Text(
                                    'Ẩn phản hồi',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )),
                            )
                          ])),
                    ],
                  )
        ],
      ),
    );
  }
}
