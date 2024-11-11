import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/constants/global_variables.dart';
import 'package:facebook/constants/router_constants.dart';
import 'package:facebook/controllers/api_controller.dart';
import 'package:facebook/features/news-feed/widgets/add_story_card.dart';
import 'package:facebook/features/news-feed/widgets/post_card.dart';
import 'package:facebook/features/news-feed/widgets/story_card.dart';
import 'package:facebook/models/post_model.dart';
import 'package:facebook/models/story.dart';
import 'package:facebook/models/user.dart';
import 'package:facebook/utils/prefs_user.dart';
import 'package:flutter/material.dart';

class NewsFeedScreen extends StatefulWidget {
  static double offset = 0;
  final ScrollController parentScrollController;
  const NewsFeedScreen({super.key, required this.parentScrollController});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  Color colorNewPost = Colors.transparent;
  final ApiController _apiController = ApiController();

  final stories = [
    Story(
      user: User(
        name: 'Doraemon',
        avatar: 'assets/images/user/doraemon.jpg',
        type: 'page',
      ),
      image: ['assets/images/story/1.jpg'],
      time: ['12 phút'],
      shareWith: 'public',
    ),
    Story(
      user: User(
          name: 'Sách Cũ Ngọc', avatar: 'assets/images/user/sachcungoc.jpg'),
      image: ['assets/images/story/2.jpg'],
      time: ['3 giờ'],
      shareWith: 'friends',
    ),
    Story(
      user: User(
        name: 'Vietnamese Argentina Football Fan Club (VAFFC)',
        avatar: 'assets/images/user/vaffc.jpg',
        type: 'page',
      ),
      image: ['assets/images/story/3.jpg'],
      time: ['5 giờ'],
      shareWith: 'friends-of-friends',
    ),
    Story(
      user:
          User(name: 'Minh Hương', avatar: 'assets/images/user/minhhuong.jpg'),
      image: [
        'assets/images/story/4.jpg',
        'assets/images/story/5.jpg',
        'assets/images/story/6.jpg',
        'assets/images/story/7.jpg',
      ],
      video: ['assets/videos/2.mp4', 'assets/videos/1.mp4'],
      time: ['1 phút'],
      shareWith: 'friends',
    ),
    Story(
      user: User(name: 'Khánh Vy', avatar: 'assets/images/user/khanhvy.jpg'),
      video: ['assets/videos/3.mp4'],
      time: ['1 phút'],
      shareWith: 'friends',
    ),
  ];

  List<PostModel> postsNew = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  int page = 0;
  int limit = 5;
  bool hasNextPage = true;

  ScrollController scrollController =
      ScrollController(initialScrollOffset: NewsFeedScreen.offset);

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    try {
      setState(() {
        if (page == 0) {
          isLoading = true;
        } else {
          isLoadingMore = true;
        }
      });

      page++;
      final response = await _apiController.get(ApiConfig.getPostsForUser, {
        'page': page,
        'limit': limit,
      });

      List<PostModel> postsNewdata =
          (response.data['metadata']['posts'] as List)
              .map((post) => PostModel.fromJson(post))
              .toList();

      bool checkNextPage = response.data['metadata']['totalPage'] > page;

      setState(() {
        postsNew.addAll(postsNewdata);
        isLoading = false;
        isLoadingMore = false;
        hasNextPage = checkNextPage;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
      // Xử lý lỗi
      print('Error fetching posts: $e');
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final User user = Provider.of<UserProvider>(context).user;
    scrollController.addListener(() {
      if (widget.parentScrollController.hasClients) {
        widget.parentScrollController.jumpTo(
            widget.parentScrollController.offset +
                scrollController.offset -
                NewsFeedScreen.offset);
        NewsFeedScreen.offset = scrollController.offset;
      }

      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          !isLoading &&
          !isLoadingMore &&
          hasNextPage) {
        _fetchPosts();
      }
    });

    final userInfo = UserServicePref.instance.getUserInfo;

    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    right: 10,
                  ),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                        '${ApiConfig.linkImage}${userInfo?.avatar}'),
                    radius: 20,
                  ),
                ),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      setState(() {
                        colorNewPost = Colors.transparent;
                      });
                    },
                    onTapUp: (tapUpDetails) {
                      setState(() {
                        colorNewPost = Colors.black12;
                      });
                    },
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        border: Border.all(
                          color: Colors.black12,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        color: colorNewPost,
                      ),
                      child: InkWell(
                          onTap: () => {
                                Navigator.of(context)
                                    .pushNamed(RouterConstants.createPost)
                              },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            child: Text('Bạn đang nghĩ gì?'),
                          )),
                    ),
                  ),
                ),
                IconButton(
                  splashRadius: 20,
                  onPressed: () {},
                  icon: const Icon(
                    Icons.image,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 5,
            color: Colors.black26,
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 5,
                  ),
                  child: AddStoryCard(),
                ),
                ...stories
                    .map((e) => Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                          ),
                          child: StoryCard(story: e),
                        ))
                    .toList()
              ]),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            width: double.infinity,
            height: 5,
            color: Colors.black26,
          ),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(
                  color: GlobalVariables.secondaryColor,
                ), // Biểu tượng tải
              ),
            )
          else
            ...postsNew
                .map(
                  (e) => Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      PostCard(post: e),
                      Container(
                        width: double.infinity,
                        height: 5,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                )
                .toList(),
          Container(
            width: double.infinity,
            height: 50.0, // Chiều cao của Container cho loading more
            alignment: Alignment.center, // Canh giữa
            child: isLoadingMore
                ? const CircularProgressIndicator(
                    color: GlobalVariables.secondaryColor,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
