import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/constants/router_constants.dart';
import 'package:facebook/controllers/api_controller.dart';
import 'package:facebook/models/chat_model.dart';
import 'package:facebook/models/user_model.dart';
import 'package:facebook/utils/prefs_user.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MemberGroupScreen extends StatefulWidget {
  static const String routeName = RouterConstants.membersGroupScreen;
  final ChatModel chat;

  const MemberGroupScreen({super.key, required this.chat});

  @override
  State<MemberGroupScreen> createState() => _MemberGroupScreenState();
}

class _MemberGroupScreenState extends State<MemberGroupScreen> {
  final TextEditingController groupNameController = TextEditingController();
  List<UserModel> friends = [];
  final List<UserModel> selectedFriends = [];

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

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !isLoading &&
        !isFetchingMore &&
        hasNextPage) {
      fetchFriends();
    }
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
      final response = await apiController.get(ApiConfig.getMembersInRoom,
          {'roomId': widget.chat.id, 'page': page, 'limit': limit});

      List<UserModel> data = (response.data['metadata'] as List)
          .map((user) => UserModel.fromJson(user))
          .toList();

      // bool checkNextPage = response.data['metadata']['totalPage'] > page;

      setState(() {
        friends.addAll(data);
        hasNextPage = false;
        // total = response.data['metadata']['totalFriend'];
        total = data.length;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thành viên trong nhóm ($total)'),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Xoá${selectedFriends.isNotEmpty ? ' (${selectedFriends.length})' : ''}',
              style: TextStyle(
                  color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.lightBlueColor,
                ),
              )
            : Column(
                children: [
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: friends.length,
                      itemBuilder: (context, index) {
                        final friend = friends[index];
                        final isSelected = selectedFriends
                            .any((value) => value.id == friend.id);

                        if (index == friends.length && isFetchingMore) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: AppColors.lightBlueColor,
                            ),
                          );
                        }
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                selectedFriends.remove(friend);
                              } else {
                                if (friend.id ==
                                    UserServicePref.instance.getUserInfo.id) {
                                  Fluttertoast.showToast(
                                      msg: "Không chọn bản thân",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.TOP_LEFT,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                  return;
                                }
                                selectedFriends.add(friend);
                              }
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.lightBlueColor.withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.lightBlueColor
                                    : Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      '${ApiConfig.linkImage}${friend.avatar}'),
                                  radius: 20,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      friend.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: isSelected
                                            ? AppColors.lightBlueColor
                                            : Colors.black,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    Text(
                                      friend.bio!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isSelected
                                            ? AppColors.lightBlueColor
                                            : AppColors.darkGreyColor,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
