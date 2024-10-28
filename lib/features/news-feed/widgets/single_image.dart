import 'package:cached_network_image/cached_network_image.dart';
import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/models/post_model.dart';
import 'package:flutter/material.dart';

import '../../comment/screens/comment_screen.dart';
import '../screen/image_fullscreen.dart';

class SingleImage extends StatelessWidget {
  final PostModel post;
  const SingleImage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    List<String> icons = [];
    String reactions = '0';
    reactions = '';
    
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, ImageFullScreen.routeName,
                arguments: post);
          },
          child: Image.network(
            '${ApiConfig.linkImage}${post.image![0]}',
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              CommentScreen.routeName,
              arguments: post,
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
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
                                      color: Colors.white,
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
                    if (reactions != '0')
                      Text(
                        reactions,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                  ],
                ),
                Row(
                  children: [
                    post.numComment != null
                        ? Text(
                            '${post.numComment} bình luận',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          )
                        : const SizedBox(),
                    (post.numComment != null && post.numShare != null)
                        ? const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Icon(
                              Icons.circle,
                              size: 3,
                              color: Colors.black,
                            ),
                          )
                        : const SizedBox(),
                    post.numShare != null
                        ? Text(
                            '${post.numShare} lượt chia sẻ',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
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
          margin: const EdgeInsets.only(
            top: 5,
          ),
          color: Colors.grey[400],
          height: 0.25,
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
                      color: Colors.black,
                      size: 24,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        'Thích',
                        style: TextStyle(
                          color: Colors.black,
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
                      color: Colors.black,
                      size: 22,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        'Bình luận',
                        style: TextStyle(
                          color: Colors.black,
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
                      color: Colors.black,
                      size: 27,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        'Chia sẻ',
                        style: TextStyle(
                          color: Colors.black,
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
    );
  }
}
