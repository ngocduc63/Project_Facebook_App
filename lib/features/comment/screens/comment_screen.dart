import 'package:facebook/constants/enum_common.dart';
import 'package:facebook/features/comment/widgets/single_comment.dart';
import 'package:facebook/models/comment.dart';
import 'package:facebook/models/post_model.dart';
import 'package:facebook/models/user.dart';
import 'package:flutter/material.dart';

class CommentScreen extends StatefulWidget {
  static const String routeName = '/comment-screen';
  final PostModel post;
  const CommentScreen({super.key, required this.post});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

enum SortingOption { fit, newest, all }

class _CommentScreenState extends State<CommentScreen> {
  List<String> icons = [];
  String reactions = '0';
  bool isInWidgetTree = true;
  SortingOption _sortingOption = SortingOption.fit;

  final List<Comment> comments = [
    Comment(
      user: User(
          name: 'Khánh Vy',
          avatar: 'assets/images/user/khanhvy.jpg',
          verified: true),
      content: 'Kỉ niệm được makeup ở Hàn của tuiii',
      time: '1 tuần',
      like: 37,
      love: 37,
      lovelove: 3,
      haha: 2,
      wow: 1,
      replies: [
        Comment(
          user: User(
              name: 'Vương Hồng Thúy',
              avatar: 'assets/images/user/vuonghongthuy.jpg'),
          content: 'ủa mà chị cao mét bn vậy ạ',
          time: '1 tuần',
          replies: [],
        ),
        Comment(
          user: User(
              name: 'Đài Phát Thanh',
              avatar: 'assets/images/user/daiphatthanh.jpg'),
          content: 'xinh đẹp tuyệt vời 🙆‍♀️',
          time: '1 tuần',
          replies: [],
        ),
      ],
    ),
    Comment(
      user: User(
          name: 'Minh Hương',
          avatar: 'assets/images/user/minhhuong.jpg',
          verified: true),
      content: 'Sai từ phone kìa chị ơiiii😭😭😭',
      time: '1 tuần',
      replies: [
        Comment(
          user: User(
              name: 'Khánh Vy',
              avatar: 'assets/images/user/khanhvy.jpg',
              verified: true),
          content: 'ui chùi gõ lộn tui gõ lại rùii hihi',
          time: '1 tuần',
          love: 2,
          lovelove: 2,
          replies: [],
        ),
      ],
    ),
    Comment(
      user: User(name: 'Hà Linhh', avatar: 'assets/images/user/halinh.jpg'),
      content: '',
      time: '1 tuần',
      image: 'assets/images/two-bears-love.png',
      replies: [],
    ),
    Comment(
      user: User(
          name: 'Nguyễn Thị Minh Tuyền',
          avatar: 'assets/images/user/minhtuyen.jpg'),
      content:
          'Chị Vy nhìn đáng yêu quá chừng luôn đó😘😘😘Chúc chị Vy có một ngày mới thật tốt lành và nhiều năng lượng nha❤️❤️❤️Thích chịiii😘😘😘',
      time: '1 tuần',
      image: 'assets/images/post/13.jpg',
      replies: [],
    ),
  ];

  @override
  void initState() {
    setState(() {
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                    borderRadius: BorderRadius.circular(
                      10,
                    ),
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
                                bottom: 15,
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
                                              widget.post.numLike.toString(),
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
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height -
                                  60 -
                                  MediaQuery.of(context).padding.vertical,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    for (int i = 0; i < comments.length; i++)
                                      SingleComment(
                                        comment: comments[i],
                                        level: 0,
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
