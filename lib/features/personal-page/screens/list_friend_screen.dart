import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/constants/router_constants.dart';
import 'package:facebook/controllers/api_controller.dart';
import 'package:facebook/features/personal-page/screens/personal_page_screen.dart';
import 'package:facebook/models/user_model.dart';
import 'package:facebook/utils/prefs_user.dart';
import 'package:flutter/material.dart';

class FriendScreen extends StatefulWidget {
  const FriendScreen({super.key});

  static const String routeName = RouterConstants.listFriend;

  @override
  State<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  List<UserModel> friends = [];
  ApiController apiController = ApiController();
  int page = 0;
  int limit = 20;
  bool isLoading = false;
  bool isFetchingMore = false;
  bool hasNextPage = true;
  int total = 0;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchFriends();
    _scrollController.addListener(_onScroll);
  }

  Future<void> fetchFriends() async {
    if (isLoading) return;

    setState(() {
      if (page == 0) {
        isLoading = true;
      } else {
        isFetchingMore = true;
      }
    });

    try {
      page++;
      final userId = UserServicePref.instance.getUserInfo.id;
      final response = await apiController.get(ApiConfig.listFriend,
          {'friendId': userId, 'page': page, 'limit': limit});

      List<UserModel> data = (response.data['metadata']['friends'] as List)
          .map((user) => UserModel.fromJson(user))
          .toList();

      bool checkNextPage = response.data['metadata']['totalPage'] > page;

      setState(() {
        friends.addAll(data);
        hasNextPage = checkNextPage;
        total = response.data['metadata']['totalFriend'];
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
        isFetchingMore = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !isLoading &&
        !isFetchingMore &&
        hasNextPage) {
      fetchFriends();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách bạn bè ($total)'),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.lightBlueColor,
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    controller: _scrollController,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 1,
                    ),
                    itemCount: friends.length + (isFetchingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == friends.length && isFetchingMore) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.lightBlueColor,
                          ),
                        );
                      }

                      var friend = friends[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            PersonalPageScreen.routeName,
                            arguments: friend,
                          );
                        },
                        child: Card(
                          elevation: 4.0,
                          child: Column(
                            children: [
                              Expanded(
                                flex: 2,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: friend.avatar != ''
                                      ? Image.network(
                                          '${ApiConfig.linkImage}${friend.avatar}',
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          color: Colors.grey[300],
                                          child: Icon(Icons.person, size: 40),
                                        ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        friend.name,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4.0),
                                      Text(
                                        '${friend.countMutual} bạn chung',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
