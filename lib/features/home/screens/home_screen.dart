import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/constants/router_constants.dart';
// import 'package:facebook/features/dating/screens/dating_screen.dart';
import 'package:facebook/features/home/widgets/home_app_bar.dart';
// import 'package:facebook/features/market_place/screens/market_place_screen.dart';
import 'package:facebook/features/menu/screens/menu_screen.dart';
import 'package:facebook/features/news-feed/screen/news_feed_screen.dart';
import 'package:facebook/features/notifications/screens/notifications_screen.dart';
import 'package:facebook/features/personal-page/screens/personal_page_screen.dart';
import 'package:facebook/features/watch/screens/watch_screen.dart';
import 'package:facebook/models/user_model.dart';
import 'package:facebook/utils/notification_observable.dart';
import 'package:facebook/utils/prefs_user.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = RouterConstants.routerHome;
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NotificationObservable observable = NotificationObservable();
  int index = 0;
  double toolBarHeight = 60;
  ScrollController scrollController = ScrollController();
  bool isLoading = false; 
  late UserModel currentUser;
  late final listIcon = <Map<String, String>>[
    {
      'name': 'home',
      'icon_nomal': 'assets/images/nav/home.png',
      'icon_active': 'assets/images/nav/home-active.png',
      'index': '0',
    },
    {
      'name': 'live',
      'icon_nomal': 'assets/images/nav/watch.png',
      'icon_active': 'assets/images/nav/watch-active.png',
      'index': '1',
    },
    {
      'name': 'pesonal',
      'icon_nomal': 'assets/images/nav/personal.png',
      'icon_active': 'assets/images/nav/personal-active.png',
      'index': '2'
    },
    {
      'name': 'noti',
      'icon_nomal': 'assets/images/nav/noti.jpg',
      'icon_active': 'assets/images/nav/noti-active.jpg',
      'index': '3',
    },
    {
      'name': 'menu',
      'icon_nomal': 'assets/images/nav/menu.png',
      'icon_active': 'assets/images/nav/menu-active.png',
      'index': '4',
    },
  ];
  late final list = <Widget>[
    NewsFeedScreen(
      parentScrollController: scrollController,
    ),
    const WatchScreen(
      key: Key('watch-screen'),
    ),
    PersonalPageScreen(
      user: currentUser,
    ),
    // const DatingScreen(
    //   key: Key('dating-screen'),
    // ),
    const NotificationsScreen(
      key: Key('notifications-screen'),
    ),
    const MenuScreen(),
  ];

  @override
  void initState() {
    super.initState();
    currentUser = UserServicePref.instance.getUserInfo;
    observable.initialize();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _onTabTapped(int tabIndex) async {
    setState(() {
      isLoading = true;
    });

    if (tabIndex == index) {
      await Future.delayed(const Duration(milliseconds: 200));
    }

    if (tabIndex == 3) {
      await observable.clearUnreadCount();
    }

    setState(() {
      index = tabIndex;
      if (index == 0) {
        toolBarHeight = 60;
      }
      isLoading = false;
    });

    scrollController.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final widthIcon = MediaQuery.of(context).size.width / listIcon.length - 10;
    return Scaffold(
      body: NestedScrollView(
        controller: scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              toolbarHeight: toolBarHeight,
              titleSpacing: 0,
              title: AnimatedContainer(
                onEnd: () {
                  setState(() {
                    if (index > 0) {
                      toolBarHeight = 0;
                    }
                  });
                },
                curve: Curves.linearToEaseOut,
                height: (index > 0) ? 0 : 60,
                duration: Duration(milliseconds: index == 0 ? 500 : 300),
                child: const HomeAppBar(),
              ),
              floating: true,
              snap: index == 0,
              pinned: true,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(46),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        children: [
                          ...listIcon
                              .map((e) => Expanded(
                                    child: Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          int indexActive =
                                              int.parse(e['index'] ?? '0');
                                          _onTabTapped(indexActive);
                                          index = indexActive;
                                        },
                                        child: Stack(
                                          children: [
                                            Center(
                                              child: Tab(
                                                child: index !=
                                                        int.parse(
                                                            e['index'] ?? '0')
                                                    ? Image.asset(
                                                        e['icon_nomal'] ?? '',
                                                        width: 30,
                                                        height: 30,
                                                      )
                                                    : Image.asset(
                                                        e['icon_active'] ?? '',
                                                        width: 30,
                                                        height: 30,
                                                      ),
                                              ),
                                            ),
                                            if (index ==
                                                int.parse(e['index'] ?? '0'))
                                              Positioned(
                                                bottom: 0,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 5),
                                                  child: Container(
                                                    width: widthIcon,
                                                    height: 3,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100),
                                                      color: AppColors
                                                          .lightBlueColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            if (int.parse(e['index'] ?? '0') ==
                                                3)
                                              StreamBuilder(
                                                  stream: observable.stream,
                                                  builder: (context, snapshot) {
                                                    final unreadCount =
                                                        snapshot.data ?? 0;
                                                    return unreadCount > 0
                                                        ? Positioned(
                                                            top: 0,
                                                            right: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.1 -
                                                                20,
                                                            child: Container(
                                                              width: 20,
                                                              height: 20,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color:
                                                                    Colors.red,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              child: Center(
                                                                child: Text(
                                                                  '$unreadCount',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : SizedBox();
                                                  })
                                          ],
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ],
                      ),
                    ),
                    const Divider(
                      color: Colors.black12,
                      height: 0,
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                color: AppColors.lightBlueColor,
              ))
            : list[index],
      ),
    );
  }
}
