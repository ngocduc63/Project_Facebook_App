import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/controllers/api_controller.dart';
import 'package:facebook/features/chat/screen/message_screen.dart';
import 'package:facebook/models/chat_model.dart';
import 'package:facebook/models/user_model.dart';
import 'package:facebook/utils/convert_time.dart';
import 'package:facebook/utils/prefs_user.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FriendsSearchScreen extends StatefulWidget {
  static const String routeName = '/friends-search-screen';
  const FriendsSearchScreen({super.key});

  @override
  State<FriendsSearchScreen> createState() => _FriendsSearchScreenState();
}

class _FriendsSearchScreenState extends State<FriendsSearchScreen> {
  final TextEditingController searchController = TextEditingController();

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

  Future<void> handleNavigateChat(BuildContext context, String friendId) async {
    try {
      final response = await apiController.get(
        ApiConfig.getRoomInfo,
        {'friendId': friendId},
      );
      if (response.statusCode == 200) {
        final ChatModel dataRoom =
            ChatModel.fromJson(response.data['metadata']);

        if (context.mounted) {
          Navigator.pushNamed(
            context,
            MessagesScreen.routeName,
            arguments: dataRoom,
          );
        }
      }
    } catch (e) {
      print(e);
    } 
  }

  Future<void> handleUnfriend(String friendId) async {
    try {
      final response =
          await apiController.put(ApiConfig.unfriend, {'friendId': friendId});
      if (response.statusCode == 200) {

        friends.removeWhere((value) => value.id == friendId);
        total--;
        setState(() {});

        Fluttertoast.showToast(
            msg: "Từ chối kết bạn thành công",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP_LEFT,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
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
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Column(
              children: [
                Container(
                  color: Colors.black12,
                  height: 0.5,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm bạn bè',
                            hintStyle: const TextStyle(
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: Colors.grey,
                            ),
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.grey[200],
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignLabelWithHint: true,
                            contentPadding: const EdgeInsets.all(0),
                          ),
                          cursorColor: Colors.black,
                          textAlignVertical: TextAlignVertical.center,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            splashRadius: 20,
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
              size: 25,
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bạn bè',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
              IconButton(
                onPressed: () {},
                splashRadius: 20,
                icon: const Icon(
                  Icons.search_rounded,
                  color: Colors.black,
                  size: 30,
                ),
              )
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 15,
                top: 15,
                bottom: 15,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$total bạn bè',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 15,
                    ),
                    child: InkWell(
                      onTap: () {
                        showModalBottomSheet<void>(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          builder: (BuildContext context) {
                            return DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    minLeadingWidth: 10,
                                    leading: ImageIcon(
                                      AssetImage('assets/images/stars.png'),
                                      size: 30,
                                      color: Colors.black,
                                    ),
                                    title: Text(
                                      'Mặc định',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    minLeadingWidth: 10,
                                    leading: ImageIcon(
                                      AssetImage('assets/images/sortup.png'),
                                      size: 30,
                                      color: Colors.black,
                                    ),
                                    title: Text(
                                      'Bạn bè mới nhất trước tiên',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    minLeadingWidth: 10,
                                    leading: ImageIcon(
                                      AssetImage('assets/images/sortdown.png'),
                                      size: 30,
                                      color: Colors.black,
                                    ),
                                    title: Text(
                                      'Bạn bè lâu năm nhất trước tiên',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Text(
                        'Sắp xếp',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 18,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            if (isLoading)
              Center(
                child: CircularProgressIndicator(
                  color: AppColors.lightBlueColor,
                ),
              ),
            for (int i = 0; i < friends.length; i++)
              Padding(
                padding: const EdgeInsets.only(
                  left: 15,
                  top: 10,
                  bottom: 10,
                  right: 0,
                ),
                child: Row(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black12,
                          width: 0.5,
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                            '${ApiConfig.linkImage}${friends[i].avatar}'),
                        radius: 30,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                friends[i].name,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (friends[i].countMutual != null &&
                                  friends[i].countMutual! > 0)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 2,
                                  ),
                                  child: Text(
                                    '${friends[i].countMutual} bạn chung',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          IconButton(
                            onPressed: () {
                              showModalBottomSheet<void>(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                builder: (BuildContext context) {
                                  return DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 15,
                                            vertical: 10,
                                          ),
                                          child: Row(
                                            children: [
                                              DecoratedBox(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.black12,
                                                    width: 0.5,
                                                  ),
                                                ),
                                                child: CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                    '${ApiConfig.linkImage}${friends[i].avatar}',
                                                  ),
                                                  radius: 25,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    friends[i].name,
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    'Là bạn bè từ ${convertTimeToDate(friends[i].time!)}',
                                                    style: const TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          color: Colors.black12,
                                          height: 0.5,
                                          width: double.infinity,
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        ListTile(
                                          onTap: () async {
                                            await handleNavigateChat(context, friends[i].id);
                                          },
                                          minLeadingWidth: 10,
                                          leading: const ImageIcon(
                                            AssetImage(
                                                'assets/images/message-outlined.png'),
                                            size: 25,
                                            color: Colors.black,
                                          ),
                                          title: Text(
                                            'Nhắn tin cho ${friends[i].name}',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          onTap: () async{
                                            await handleUnfriend(friends[i].id);
                                            if (context.mounted) Navigator.pop(context); 
                                          },
                                          minLeadingWidth: 10,
                                          leading: const ImageIcon(
                                            AssetImage(
                                                'assets/images/unfriend.png'),
                                            size: 25,
                                            color: Colors.red,
                                          ),
                                          title: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Hủy kết bạn với ${friends[i].name}',
                                                style: const TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                'Hủy kết bạn với ${friends[i].name}',
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            padding: const EdgeInsets.all(0),
                            splashRadius: 23,
                            icon: const Icon(
                              Icons.more_horiz_rounded,
                              color: Colors.black87,
                              size: 25,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
