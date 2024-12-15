import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/constants/enum_common.dart';
import 'package:facebook/controllers/api_controller.dart';
import 'package:facebook/models/post_model.dart';
import 'package:facebook/utils/convert_time.dart';
import 'package:flutter/material.dart';

class ListLikeScreen extends StatefulWidget {
  static const String routeName = '/like-screen';
  final PostModel post;
  const ListLikeScreen({super.key, required this.post});
  @override
  State<ListLikeScreen> createState() => _ListLikeScreenState();
}

class _ListLikeScreenState extends State<ListLikeScreen> {
  final listLikes = [];
  ApiController _apiController = ApiController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLikes();
  }

  Future<void> _fetchLikes() async {
    try {
      final response = await _apiController.get(ApiConfig.getLikes, {
        "postId": widget.post.id,
      });

      setState(() {
        listLikes.addAll(response.data['metadata']);
        listLikes;
        isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách lượt thích'),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.lightBlueColor,
              ),
            )
          : ListView.builder(
              itemCount: listLikes.length,
              itemBuilder: (context, index) {
                final like = listLikes[index];

                String reaction = like['category'];
                String linkIcon = 'assets/images/reactions/like.png';
                if (reaction == Emotion.like.value) {
                  linkIcon = 'assets/images/reactions/like.png';
                } else if (reaction == Emotion.haha.value) {
                  linkIcon = 'assets/images/reactions/haha.png';
                } else if (reaction == Emotion.love.value) {
                  linkIcon = 'assets/images/reactions/love.png';
                } else if (reaction == Emotion.lovelove.value) {
                  linkIcon = 'assets/images/reactions/care.png';
                } else if (reaction == Emotion.wow.value) {
                  linkIcon = 'assets/images/reactions/wow.png';
                } else if (reaction == Emotion.sad.value) {
                  linkIcon = 'assets/images/reactions/sad.png';
                } else if (reaction == Emotion.angry.value) {
                  linkIcon = 'assets/images/reactions/angry.png';
                } else {
                  linkIcon = 'assets/images/like.png';
                }

                return ListTile(
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                            '${ApiConfig.linkImage}${like['userInfo']['avatar']}'),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.all(2),
                          child: Image.asset(
                            linkIcon,
                            width: 14,
                            height: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: Text(
                    like['userInfo']['name'],
                    style: TextStyle(fontSize: 18),
                  ),
                  subtitle: Text(
                    convertToTimeAgo(like['createdAt']),
                    style: TextStyle(color: AppColors.darkGreyColor),
                  ),
                );
              },
            ),
    );
  }
}
