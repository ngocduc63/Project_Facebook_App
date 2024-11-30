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
  bool hasNextPage = true;
  int total = 0;

  @override
  void initState() {
    super.initState();
    fetchFriends();
  }

  Future<void> fetchFriends() async {
    setState(() {
      isLoading = true;
    });
    page++;
    try {
      final userId = UserServicePref.instance.getUserInfo.id;
      final response = await apiController.get(ApiConfig.listFriend,
          {'friendId': userId, 'page': page, 'limit': limit});

      List<UserModel> data = (response.data['metadata']['friends'] as List)
          .map((user) => UserModel.fromJson(user))
          .toList();

      bool checkNextPage = response.data['metadata']['totalPage'] > page;

      setState(() {
        friends.addAll(data);
        isLoading = false;
        hasNextPage = checkNextPage;
        total = response.data['metadata']['totalFriend'];
      });
    } catch (e) {
      print(e);
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
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 1,
              ),
              itemCount: friends.length,
              itemBuilder: (context, index) {
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  friend.name,
                                  style: TextStyle(fontWeight: FontWeight.bold),
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
    );
  }
}
