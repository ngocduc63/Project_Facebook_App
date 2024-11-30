import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/constants/router_constants.dart';
import 'package:facebook/controllers/api_controller.dart';
import 'package:facebook/controllers/user_controller/user_controller.dart';
import 'package:facebook/features/personal-page/screens/personal_page_screen.dart';
import 'package:facebook/models/user_model.dart';
import 'package:facebook/utils/prefs_user.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FollowScreen extends StatefulWidget {
  const FollowScreen({super.key});

  static const String routeName = RouterConstants.listFollow;

  @override
  State<FollowScreen> createState() => _FollowScreenState();
}

class _FollowScreenState extends State<FollowScreen> {
  List<UserModel> friends = [];
  ApiController apiController = ApiController();
  UserController userController = UserController();
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
      final response = await apiController.get(ApiConfig.listFollow,
          {'userId': userId, 'page': page, 'limit': limit});

      List<UserModel> data =
          (response.data['metadata']['friends'] as List).map((friend) {
        UserModel user = UserModel.fromJson(friend['created_by_user']);
        user.countMutual = friend['countMutual'];
        return user;
      }).toList();

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

  Future<void> handleAcpFriend(String friendId) async {
    final check = await userController.acpFriendController(friendId, '');

    if (check) {
      friends.removeWhere((value) => value.id == friendId);
      Fluttertoast.showToast(
          msg: "Đồng ý kết bạn thành công",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP_LEFT,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
      setState(() {});
    } else {
      Fluttertoast.showToast(
          msg: "Có lỗi xảy ra",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP_LEFT,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách lời mời kết bạn ($total)'),
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
                                Center(
                                  child: Text(
                                    friend.name,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(height: 4.0),
                                Center(
                                  child: Text(
                                    '${friend.countMutual} bạn chung',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4.0, vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  await handleAcpFriend(friend.id);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.lightBlueColor,
                                ),
                                child: Text('Xác nhận'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  print('Từ chối');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.darkGreyColor,
                                ),
                                child: Text('Từ chối'),
                              ),
                            ],
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
