import 'package:cached_network_image/cached_network_image.dart';
import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/features/comment/screens/comment_screen.dart';
import 'package:facebook/features/news-feed/widgets/post_content.dart';
import 'package:facebook/models/post_model.dart';
import 'package:facebook/utils/convert_time.dart';
import 'package:flutter/material.dart';

class ImageFullScreen extends StatefulWidget {
  static const String routeName = '/image-fullscreen';
  final PostModel post;
  const ImageFullScreen({super.key, required this.post});

  @override
  State<ImageFullScreen> createState() => _ImageFullScreenState();
}

class _ImageFullScreenState extends State<ImageFullScreen> {
  List<String> icons = [];
  String reactions = '0';
  bool contentVisible = true;

  @override
  void initState() {
    super.initState();
    
    setState(() {
      reactions = '';
    });  
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          contentVisible = !contentVisible;
        });
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black,
          title: Align(
            alignment: Alignment.centerRight,
            child: contentVisible
                ? const Icon(
                    Icons.more_vert_rounded,
                    color: Colors.white,
                    size: 30,
                  )
                : null,
          ),
        ),
        backgroundColor: Colors.black,
        body: GestureDetector(
          onVerticalDragUpdate: (details) {
            Navigator.pop(context);
          },
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: CachedNetworkImageProvider('${ApiConfig.linkImage}${widget.post.image![0]}'),
                alignment: Alignment.center,
              ),
            ),
            child: contentVisible
                ? SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Colors.black.withOpacity(0.4),
                          ),
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 15,
                                  right: 15,
                                  top: 15,
                                ),
                                child: Text(
                                  widget.post.user.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              // Padding(
                              //   padding: const EdgeInsets.only(
                              //     left: 5,
                              //     right: 5,
                              //   ),
                              //   child: PostContent(
                              //     text: widget.post.content!,
                              //     textColor: Colors.white,
                              //   ),
                              // ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 15,
                                  right: 15,
                                ),
                                child: Text(
                                  convertToTimeAgo(widget.post.time),
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 3,
                                ),
                                width: double.infinity,
                                margin: const EdgeInsets.only(
                                  left: 15,
                                  right: 15,
                                  top: 5,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      'assets/images/message.png',
                                      color: Colors.white,
                                      width: 20,
                                      height: 20,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      'NHẮN TIN CHO ${widget.post.user.name.toUpperCase()}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              CommentScreen.routeName,
                              arguments: widget.post,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 42,
                                      child: Stack(
                                        children: [
                                          const SizedBox(
                                            width: 24,
                                            height: 24,
                                          ),
                                          if (icons.length > 1)
                                            Positioned(
                                              top: 2,
                                              left: 18,
                                              child: Image.asset(
                                                icons[1],
                                                width: 20,
                                              ),
                                            ),
                                          if (icons.isNotEmpty)
                                            Positioned(
                                              top: 0,
                                              left: 0,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Colors.black,
                                                      width: 2,
                                                    )),
                                                child: Image.asset(
                                                  icons[0],
                                                  width: 20,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    if (reactions.isNotEmpty)
                                      Text(
                                        reactions,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    widget.post.numComment != null
                                        ? Text(
                                            '${widget.post.numComment} bình luận',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const SizedBox(),
                                    (widget.post.numComment != null &&
                                            widget.post.numShare != null)
                                        ? const Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 5),
                                            child: Icon(
                                              Icons.circle,
                                              size: 3,
                                              color: Colors.black,
                                            ),
                                          )
                                        : const SizedBox(),
                                    widget.post.numShare != null
                                        ? Text(
                                            '${widget.post.numShare} lượt chia sẻ',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 15,
                          ),
                          color: Colors.grey[100],
                          height: 1,
                          width: double.infinity,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 11.5,
                                ),
                                alignment: Alignment.centerLeft,
                                width: (MediaQuery.of(context).size.width) / 3,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ImageIcon(
                                      AssetImage(
                                        'assets/images/like.png',
                                      ),
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Text(
                                        'Thích',
                                        style: TextStyle(
                                          color: Colors.white,
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
                                  vertical: 12,
                                ),
                                alignment: Alignment.center,
                                width: (MediaQuery.of(context).size.width) / 3,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ImageIcon(
                                      AssetImage('assets/images/comment.png'),
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Text(
                                        'Bình luận',
                                        style: TextStyle(
                                          color: Colors.white,
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
                                alignment: Alignment.centerRight,
                                width: (MediaQuery.of(context).size.width) / 3,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ImageIcon(
                                      AssetImage('assets/images/share.png'),
                                      color: Colors.white,
                                      size: 27,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Text(
                                        'Chia sẻ',
                                        style: TextStyle(
                                          color: Colors.white,
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
                    ),
                  )
                : Container(
                    height: MediaQuery.of(context).size.height,
                    color: Colors.transparent,
                  ),
          ),
        ),
      ),
    );
  }
}
