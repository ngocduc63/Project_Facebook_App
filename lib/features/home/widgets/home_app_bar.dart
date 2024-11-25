import 'package:facebook/constants/global_variables.dart';
import 'package:facebook/constants/router_constants.dart';
import 'package:facebook/utils/notification_observable.dart';
import 'package:flutter/material.dart';

class HomeAppBar extends StatefulWidget {
  const HomeAppBar({super.key});

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  final NotificationObservable observable = NotificationObservable();

  @override
  void initState() {
    super.initState();
    observable.initialize();
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 20,
              ),
              const Text(
                'Facebook',
                style: TextStyle(
                  color: GlobalVariables.secondaryColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                  icon: const ImageIcon(
                    AssetImage('assets/images/search.png'),
                    size: 22,
                    color: Colors.black,
                  ),
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: 35,
                    height: 35,
                    padding: const EdgeInsets.all(0),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black12,
                    ),
                    child: IconButton(
                      splashRadius: 18,
                      padding: const EdgeInsets.all(0),
                      onPressed: () {
                        Navigator.of(context).pushNamed(RouterConstants.chat);
                      },
                      icon: const ImageIcon(
                        AssetImage('assets/images/message.png'),
                        size: 23,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  StreamBuilder(
                    stream: observable.messStream,
                    builder: (context, snapshot) {
                      final unreadCount = snapshot.data ?? 0;
                      return unreadCount > 0
                          ? Positioned(
                              top: -6,
                              right: -6,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '$unreadCount',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : SizedBox();
                    },
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
