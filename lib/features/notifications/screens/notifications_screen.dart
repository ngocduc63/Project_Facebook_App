import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/constants/global_variables.dart';
import 'package:facebook/controllers/api_controller.dart';
import 'package:facebook/features/notifications/widgets/single_notification.dart';
import 'package:facebook/models/notification_model.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  static double offset = 0;
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotiModel> notifications = [];
  int page = 0;
  int limit = 10;
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasNextPage = true;
  ApiController _apiController = ApiController();

  ScrollController scrollController =
      ScrollController(initialScrollOffset: NotificationsScreen.offset);
  ScrollController headerScrollController = ScrollController();

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
      final response = await _apiController.get(ApiConfig.getNotifications, {
        'page': page,
        'limit': limit,
      });

      List<NotiModel> notiNewdata = (response.data['metadata']['noti'] as List)
          .map((noti) => NotiModel.fromJson(noti))
          .toList();

      bool checkNextPage = response.data['metadata']['totalPage'] > page;

      if (mounted) {
        setState(() {
          notifications.addAll(notiNewdata);
          isLoading = false;
          isLoadingMore = false;
          hasNextPage = checkNextPage;
        });
      }
    } catch (e) {
        setState(() {
          isLoading = false;
          isLoadingMore = false;
        });
      print('Error fetching noti: $e');
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    headerScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    scrollController.addListener(() {
      headerScrollController.jumpTo(headerScrollController.offset +
          scrollController.offset -
          NotificationsScreen.offset);
      NotificationsScreen.offset = scrollController.offset;

      // Tải thêm dữ liệu khi cuộn đến cuối danh sách
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        if (!isLoadingMore && hasNextPage) {
          _fetchPosts();
        }
      }
    });

    return Scaffold(
      body: NestedScrollView(
        controller: headerScrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            toolbarHeight: 50,
            titleSpacing: 0,
            pinned: true,
            floating: true,
            primary: false,
            centerTitle: true,
            automaticallyImplyLeading: false,
            snap: true,
            forceElevated: innerBoxIsScrolled,
            bottom: const PreferredSize(
                preferredSize: Size.fromHeight(0), child: SizedBox()),
            title: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Thông báo',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    alignment: Alignment.center,
                    width: 35,
                    height: 35,
                    padding: const EdgeInsets.all(0),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black12,
                    ),
                    child: IconButton(
                      splashRadius: 18,
                      padding: const EdgeInsets.all(0),
                      onPressed: () {},
                      icon: const Icon(
                        Icons.search,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị loading khi tải dữ liệu lần đầu
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(color: GlobalVariables.secondaryColor,),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ...notifications
                          .map((e) => SingleNotification(notification: e))
                          .toList(),
                      // Hiển thị loading khi tải thêm dữ liệu
                      if (isLoadingMore)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(color: GlobalVariables.secondaryColor,),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
