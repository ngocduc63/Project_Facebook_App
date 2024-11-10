import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/controllers/api_controller.dart';
import 'package:facebook/features/chat/screen/message_screen.dart';
import 'package:facebook/features/chat/widgets/chat_card.dart';
import 'package:facebook/models/chat_model.dart';
import 'package:flutter/material.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  List<ChatModel> chatsData = [];
  ApiController apiController = ApiController();
  bool isLoading = true;
  bool isLoadingMore = false;
  int page = 0;
  int limit = 10;
  bool hasNextPage = true;

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchChatsData();

    // Thêm sự kiện để kiểm tra khi cuộn đến gần cuối danh sách
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          hasNextPage &&
          !isLoadingMore) {
        _fetchChatsData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchChatsData() async {
    setState(() {
      isLoadingMore = true;
    });
    page++;
    try {
      final response = await apiController.get(ApiConfig.getRoomChat, {
        "page": page,
        "limit": limit,
      });

      List<ChatModel> fetchedChats =
          (response.data['metadata']['rooms'] as List)
              .map((room) => ChatModel.fromJson(room))
              .toList();

      setState(() {
        chatsData.addAll(fetchedChats);
        isLoading = false;
        isLoadingMore = false;
        hasNextPage = response.data['metadata']['totalPage'] > page;
      });
    } catch (error) {
      setState(() {
        isLoadingMore = false;
      });
      print("Error loading more chat data: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.lightBlueColor,
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: chatsData.length,
                    itemBuilder: (context, index) {
                      if (index == chatsData.length) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.lightBlueColor,
                          ),
                        );
                      }
                      return ChatCard(
                        chat: chatsData[index],
                        press: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MessagesScreen(chat: chatsData[index]),
                          ),
                        ),
                      );
                    },
                  )),
      ],
    );
  }
}
