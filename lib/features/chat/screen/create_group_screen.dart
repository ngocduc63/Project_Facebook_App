import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/constants/router_constants.dart';
import 'package:facebook/controllers/api_controller.dart';
import 'package:facebook/features/auth/widgets/input_fields.dart';
import 'package:facebook/features/chat/screen/chat_screen.dart';
import 'package:facebook/models/user_model.dart';
import 'package:facebook/utils/prefs_user.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class CreateGroupScreen extends StatefulWidget {
  static const String routeName = RouterConstants.createGroupChat;

  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController groupNameController = TextEditingController();
  List<UserModel> friends = [];
  final List<UserModel> selectedFriends = [UserServicePref.instance.getUserInfo];

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

  Future<void> _handleCreateGroup() async {
    if (groupNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên nhóm!'),
        ),
      );
      return;
    }
    if (selectedFriends.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất hai thành viên!'),
        ),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });
      final members = selectedFriends.map((friend) => friend.id).toList();
      final roomName = groupNameController.text.trim();
      final response = await apiController.post(ApiConfig.createGroupChat, {'members': members, 'roomName' : roomName});

      if(response.statusCode == 200) {
        Fluttertoast.showToast(
              msg: "Tạo nhóm thành công",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.TOP_LEFT,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0);
          Get.off(ChatsScreen());
      }

    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo nhóm mới'),
        actions: [
          TextButton(
            onPressed: _handleCreateGroup,
            child: Text(
              'Tạo',
              style: TextStyle(
                  color: AppColors.lightBlueColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
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
                  InputTextFieldWidget(groupNameController, 'Tên nhóm'),
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
                                Expanded(
                                  child: Text(
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
      ),
    );
  }
}
