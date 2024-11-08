import 'dart:math';

import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/constants/global_variables.dart';
import 'package:facebook/controllers/api_controller.dart';
import 'package:facebook/models/post_model.dart';
import 'package:facebook/models/user_model.dart';
import 'package:facebook/utils/prefs_user.dart';
import 'package:flutter/material.dart';
import '../../news-feed/widgets/post_card.dart';

class PersonalPageScreen extends StatefulWidget {
  static const String routeName = '/personal-page';
  final UserModel user;
  const PersonalPageScreen({super.key, required this.user});
  static double offset = 0;

  @override
  State<PersonalPageScreen> createState() => _PersonalPageScreenState();
}

class _PersonalPageScreenState extends State<PersonalPageScreen> {
  final TextEditingController searchController = TextEditingController();
  final Random random = Random();
  bool isMine = false;
  bool isLoadingInfo = true;
  bool isLoadingPost = false;
  bool isLoadingPostMore = false;
  bool hasNextPage = false;
  int mutualFriends = 0;
  int page = 0;
  int limit = 5;
  List<PostModel> listPosts = [];

  List<UserModel> usersMutual = [];
  ApiController apiController = ApiController();
  UserServicePref userServicePref = UserServicePref();
  UserModel? user;
  ScrollController scrollController =
      ScrollController(initialScrollOffset: PersonalPageScreen.offset);

  Future<void> loadUserInfo() async {
    try {
      final response = await apiController
          .get(ApiConfig.getuserInfo, {'userId': widget.user.id});
      final UserModel userData = UserModel.fromJson(response.data['metadata']);
      final UserModel? currentUserData = userServicePref.getUserInfo;
      final bool isCurrentUer = widget.user.id == currentUserData?.id;
      int countMutualFriends = 0;
      List<UserModel> listMutualFriends = [];
      if (!isCurrentUer) {
        countMutualFriends = response.data['metadata']['mutualFriends'];
        listMutualFriends =
            (response.data['metadata']?['latestMutualFriends'] as List)
                .map((user) => UserModel.fromJson(user))
                .toList();
      }

      setState(() {
        if (!isCurrentUer) {
          mutualFriends = countMutualFriends;
          usersMutual = listMutualFriends;
        }
        isMine = isCurrentUer;
        user = userData;
        isLoadingInfo = false;
      });
    } catch (e) {
      setState(() {
        print(e);
        isLoadingInfo = true;
      });
    }
  }

  Future<void> fetchPosts() async {
    try {
      setState(() {
        if (page == 0) {
          isLoadingPost = true;
        } else {
          isLoadingPostMore = true;
        }
      });

      page++;
      final response = await apiController.get(ApiConfig.getPostsOfUser, {
        'userId': widget.user.id,
        'page': page,
        'limit': limit,
      });

      List<PostModel> postsNewdata =
          (response.data['metadata']['posts'] as List)
              .map((post) => PostModel.fromJson(post))
              .toList();

      bool checkNextPage = response.data['metadata']['totalPage'] > page;

      setState(() {
        listPosts.addAll(postsNewdata);
        isLoadingPost = false;
        isLoadingPostMore = false;
        hasNextPage = checkNextPage;
      });
    } catch (e) {
      setState(() {
        isLoadingPost = false;
        isLoadingPostMore = false;
      });
      // Xử lý lỗi
      print('Error fetching posts: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserInfo();
    fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          !isLoadingPost &&
          !isLoadingPostMore &&
          hasNextPage) {
        fetchPosts();
      }
    });

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0.5),
            child: Container(
              color: Colors.black12,
              width: double.infinity,
              height: 0.5,
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
              size: 30,
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 10,
                    top: 5,
                    bottom: 5,
                  ),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Tìm kiếm',
                      hintStyle: const TextStyle(
                        fontSize: 18,
                      ),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 10,
                        ),
                        child: Icon(
                          Icons.search_rounded,
                          color: Colors.grey,
                          size: 25,
                        ),
                      ),
                      prefixIconConstraints:
                          const BoxConstraints(minWidth: 45, maxHeight: 41),
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
                      contentPadding: EdgeInsets.zero,
                    ),
                    cursorColor: Colors.black,
                    textAlignVertical: TextAlignVertical.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: isLoadingInfo
          ? Center(
              child: CircularProgressIndicator(
                color: GlobalVariables.secondaryColor,
              ),
            )
          : SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      const SizedBox(
                        width: double.infinity,
                        height: 270,
                      ),
                      user!.cover != null
                          ? Image.network(
                              '${ApiConfig.linkImage}${user!.cover}',
                              fit: BoxFit.cover,
                              height: 220,
                              width: double.infinity,
                            )
                          : Container(
                              width: double.infinity,
                              height: 220,
                              color: Colors.grey,
                            ),
                      Positioned(
                        left: 15,
                        bottom: 0,
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 5,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    '${ApiConfig.linkImage}${user!.avatar}'),
                                radius: 75,
                              ),
                            ),
                            if (user!.guard == true)
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: Image.asset(
                                  'assets/images/guard.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            if (isMine)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      color: Colors.black,
                                      size: 22,
                                    )),
                              ),
                          ],
                        ),
                      ),
                      if (isMine)
                        Positioned(
                          bottom: 65,
                          right: 15,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  color: Colors.blue[700],
                                  shape: BoxShape.circle,
                                ),
                                child: const ImageIcon(
                                  AssetImage('assets/images/avatar.png'),
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.black,
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                        )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              user!.name,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            (user!.verified == true
                                ? const Padding(
                                    padding: EdgeInsets.only(left: 5),
                                    child: Icon(
                                      Icons.verified,
                                      color: Colors.blue,
                                      size: 15,
                                    ),
                                  )
                                : const SizedBox()),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              '${user!.friends ?? 0}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            const Text(
                              'bạn bè',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            if (!isMine)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.circle,
                                    color: Colors.black,
                                    size: 3,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    '$mutualFriends',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  const Text(
                                    'bạn chung',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        if (user!.bio != null)
                          Text(
                            user!.bio!,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        const SizedBox(
                          height: 10,
                        ),
                        (isMine)
                            ? Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                            onPressed: () {},
                                            style: ElevatedButton.styleFrom(
                                              shadowColor: Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              backgroundColor: Colors.blue[700],
                                            ),
                                            child: const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.add,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  'Thêm vào tin',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            )),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                            onPressed: () {},
                                            style: ElevatedButton.styleFrom(
                                              shadowColor: Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              backgroundColor: Colors.grey[200],
                                            ),
                                            child: const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.edit_rounded,
                                                  color: Colors.black,
                                                  size: 16,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  'Chỉnh sửa trang cá nhân',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            )),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          backgroundColor: Colors.grey[200],
                                          padding: EdgeInsets.zero,
                                        ),
                                        child: const Icon(
                                          Icons.more_horiz_rounded,
                                          size: 20,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              )
                            : user!.type != 'page'
                                ? Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            backgroundColor: Colors.grey[200],
                                            padding: EdgeInsets.zero,
                                          ),
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              ImageIcon(
                                                AssetImage(
                                                    'assets/images/friend.png'),
                                                size: 16,
                                                color: Colors.black,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                'Bạn bè',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            backgroundColor: Colors.blue[700],
                                          ),
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              ImageIcon(
                                                AssetImage(
                                                    'assets/images/message.png'),
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                'Nhắn tin',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            backgroundColor: Colors.grey[200],
                                            padding: EdgeInsets.zero,
                                          ),
                                          child: const Icon(
                                            Icons.more_horiz_rounded,
                                            size: 20,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            backgroundColor: Colors.blue[700],
                                            padding: EdgeInsets.zero,
                                          ),
                                          child: const Text(
                                            'Nhắn tin',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            backgroundColor: Colors.grey[200],
                                          ),
                                          child: const Text(
                                            'Đã thích',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            backgroundColor: Colors.grey[200],
                                            padding: EdgeInsets.zero,
                                          ),
                                          child: const Icon(
                                            Icons.more_horiz_rounded,
                                            size: 20,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                      ],
                    ),
                  ),
                  if (isMine || user!.type == 'page')
                    Container(
                      width: double.infinity,
                      height: 10,
                      color: Colors.grey,
                    ),
                  if (isMine)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 15,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Bài viết',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 15,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Reels',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  if (user!.type == 'page')
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 15,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Bài viết',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 15,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Giới thiệu',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 15,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Video',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 15,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                children: [
                                  Text(
                                    'Xem thêm',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down_sharp,
                                    size: 25,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  isMine
                      ? Container(
                          width: double.infinity,
                          color: Colors.black12,
                          height: 0.5,
                        )
                      : Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 15,
                          ),
                          width: double.infinity,
                          color: Colors.black12,
                          height: 0.5,
                        ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                      top: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isMine || user!.type == 'page')
                          const Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(
                              'Chi tiết',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        if (user!.address != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 10,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.house_rounded,
                                  size: 25,
                                  color: Colors.black54,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: RichText(
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                      children: [
                                        const TextSpan(
                                          text: 'Sống tại ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        TextSpan(
                                          text: user!.address,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (user!.hometown != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 10,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 25,
                                  color: Colors.black54,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: RichText(
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                      children: [
                                        const TextSpan(
                                          text: 'Đến từ ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        TextSpan(
                                          text: user!.hometown,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (user!.type != 'page' && user!.followers != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 10,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(
                                    left: 5,
                                  ),
                                  child: ImageIcon(
                                    AssetImage('assets/images/wifi.png'),
                                    size: 20,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text(
                                    'Có ${user!.followers} người theo dõi',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 10,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              if (isMine)
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 144,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        color: Colors.black54,
                                        size: 25,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    const Text(
                                      'Mới',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    )
                                  ],
                                ),
                              if (isMine)
                                const SizedBox(
                                  width: 15,
                                ),
                              // if (user!.stories != null)
                              //   for (int i = 0; i < user!.stories!.length; i++)
                              //     Padding(
                              //       padding: EdgeInsets.only(
                              //           right: i < user!.stories!.length ? 15 : 0),
                              //       child: Column(
                              //         mainAxisAlignment: MainAxisAlignment.center,
                              //         crossAxisAlignment: CrossAxisAlignment.center,
                              //         children: [
                              //           SizedBox(
                              //             width: 80,
                              //             height: 144,
                              //             child: FittedBox(
                              //               child: StoryCard(
                              //                 story: user!.stories![i],
                              //                 hidden: true,
                              //               ),
                              //             ),
                              //           ),
                              //           const SizedBox(
                              //             height: 5,
                              //           ),
                              //           Text(
                              //             user!.stories![i].name != null
                              //                 ? user!.stories![i].name!
                              //                 : 'Tin nổi bật',
                              //             style: const TextStyle(
                              //               color: Colors.black,
                              //               fontSize: 16,
                              //             ),
                              //           )
                              //         ],
                              //       ),
                              //     ),
                            ],
                          ),
                        ),
                        // if (user!.stories != null)
                        //   const SizedBox(
                        //     height: 10,
                        //   ),
                        if (isMine)
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[50],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    shadowColor: Colors.transparent,
                                  ),
                                  child: Text(
                                    'Chỉnh sửa chi tiết công khai',
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  if (!isMine)
                    Container(
                      width: double.infinity,
                      height: 0.5,
                      color: Colors.black12,
                    ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              user!.type != 'page'
                                  ? 'Bạn bè'
                                  : 'Bài viết của ${user!.name}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            if (isMine)
                              Text(
                                'Xem tất cả bạn bè',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue[700],
                                ),
                              ),
                          ],
                        ),
                        if (user!.type != 'page')
                          const SizedBox(
                            height: 5,
                          ),
                        if (user!.type != 'page')
                          RichText(
                            textAlign: TextAlign.left,
                            text: TextSpan(
                                text: '${user!.friends ?? 0}',
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 16,
                                ),
                                children: [
                                  isMine
                                      ? const TextSpan(text: ' người bạn ')
                                      : mutualFriends > 0
                                          ? TextSpan(
                                              text:
                                                  ' ($mutualFriends) bạn chung')
                                          : const TextSpan()
                                ]),
                          ),
                        if (user!.type != 'page')
                          const SizedBox(
                            height: 20,
                          ),
                        if (usersMutual.isNotEmpty)
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  for (int i = 0;
                                      i < min(3, usersMutual.length);
                                      i++)
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          PersonalPageScreen.routeName,
                                          arguments: usersMutual[i],
                                        );
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              '${ApiConfig.linkImage}${usersMutual[i].avatar}',
                                              width: (MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      50) /
                                                  3,
                                              height: (MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      50) /
                                                  3,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          SizedBox(
                                            width: (MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    50) /
                                                3,
                                            child: Padding(
                                              padding: EdgeInsets.only(left: 5),
                                              child: Text(
                                                usersMutual[i].name,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  for (int i = min(3, usersMutual.length);
                                      i < 3;
                                      i++)
                                    SizedBox(
                                      width:
                                          (MediaQuery.of(context).size.width -
                                                  50) /
                                              3,
                                    ),
                                ],
                              ),
                              if (usersMutual.length > 3)
                                const SizedBox(
                                  height: 20,
                                ),
                              if (usersMutual.length > 3)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    for (int i = 3;
                                        i < min(6, usersMutual.length);
                                        i++)
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            PersonalPageScreen.routeName,
                                            arguments: usersMutual[i],
                                          );
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.network(
                                                '${ApiConfig.linkImage}${usersMutual[i].avatar}',
                                                width: (MediaQuery.of(context)
                                                            .size
                                                            .width -
                                                        50) /
                                                    3,
                                                height: (MediaQuery.of(context)
                                                            .size
                                                            .width -
                                                        50) /
                                                    3,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            SizedBox(
                                                width: (MediaQuery.of(context)
                                                            .size
                                                            .width -
                                                        50) /
                                                    3,
                                                child: Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 5),
                                                  child: Text(
                                                    usersMutual[i].name,
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                )),
                                          ],
                                        ),
                                      ),
                                    for (int i = min(6, usersMutual.length);
                                        i < 6;
                                        i++)
                                      SizedBox(
                                        width:
                                            (MediaQuery.of(context).size.width -
                                                    50) /
                                                3,
                                      ),
                                  ],
                                ),
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey[200],
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        shadowColor: Colors.transparent,
                                      ),
                                      child: const Text(
                                        'Xem tất cả bạn bè',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  if (user!.type != 'page')
                    const SizedBox(
                      height: 10,
                    ),
                  if (user!.type != 'page')
                    Container(
                      height: 10,
                      width: double.infinity,
                      color: Colors.grey,
                    ),
                  if (user!.type != 'page')
                    const SizedBox(
                      height: 15,
                    ),
                  if (user!.type != 'page')
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Bài viết',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.black,
                            ),
                          ),
                          if (isMine)
                            Text(
                              'Bộ lọc',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.blue[700],
                              ),
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(
                    height: 10,
                  ),
                  if (user!.type != 'page')
                    InkWell(
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                        child: isMine
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      right: 10,
                                    ),
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          '${ApiConfig.linkImage}${user!.avatar}'),
                                      radius: 20,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      isMine
                                          ? 'Bạn đang nghĩ gì?'
                                          : 'Viết gì đó cho ${user!.name}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
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
                              )
                            : null,
                      ),
                    ),
                  const SizedBox(
                    height: 10,
                  ),
                  if (isMine)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 0.5,
                          color: Colors.black12,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          color: Colors.grey[100],
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                            ),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {},
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.black12,
                                        width: 0.75,
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ImageIcon(
                                          AssetImage(
                                              'assets/images/menu/reels.png'),
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          'Thước phim',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                InkWell(
                                  onTap: () {},
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.black12,
                                        width: 0.75,
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.video_camera_front_rounded,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          'Phát trực tiếp',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: 0.5,
                          color: Colors.black12,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                ),
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[200],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    shadowColor: Colors.transparent,
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.chat_rounded,
                                          color: Colors.black, size: 18),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        'Quản lý bài viết',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  Container(
                    width: double.infinity,
                    height: 10,
                    color: Colors.grey,
                  ),
                  if (user!.type != 'page')
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_rounded,
                                color: Colors.black,
                                size: 20,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Ảnh',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (user!.type != 'page')
                    Container(
                      width: double.infinity,
                      height: 10,
                      color: Colors.grey,
                    ),
                  if (isLoadingPost)
                    Center(
                      child: CircularProgressIndicator(
                        color: GlobalVariables.secondaryColor,
                      ),
                    ),
                  if (listPosts.isNotEmpty && !isLoadingPost)
                    for (int i = 0; i < listPosts.length; i++)
                      Column(
                        children: [
                          const SizedBox(height: 10),
                          PostCard(
                            post: listPosts[i],
                          ),
                          Container(
                            width: double.infinity,
                            height: 5,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                  if (isLoadingPostMore)
                    Center(
                      child: CircularProgressIndicator(
                        color: GlobalVariables.secondaryColor,
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
