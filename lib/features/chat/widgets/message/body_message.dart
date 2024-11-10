import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/controllers/api_controller.dart';
import 'package:facebook/features/chat/widgets/message/message.dart';
import 'package:facebook/models/chat_model.dart';
import 'package:facebook/models/message_model.dart';
import 'package:flutter/material.dart';
import 'chat_input_fields.dart';

class Body extends StatefulWidget {
  final ChatModel chat;

  const Body({super.key, required this.chat});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  List<MessageModel> dataMess = [];
  ApiController apiController = ApiController();
  bool isLoading = true;
  bool isLoadingMore = false;
  int page = 0;
  int limit = 20;
  bool hasNextPage = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchMessData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          !isLoadingMore && hasNextPage) {
        _fetchMessData();
      }
    });
  }

  Future<void> _fetchMessData() async {
    setState(() {
      isLoadingMore = true;
    });
    page++;
    try {
      final response = await apiController.get(ApiConfig.getMessages,
          {"roomId": widget.chat.id, "page": page, "limit": limit});

      List<MessageModel> fetchedChats =
          (response.data['metadata']['messages'] as List)
              .map((room) => MessageModel.fromJson(room))
              .toList();


      setState(() {
        hasNextPage = response.data['metadata']['totalPage'] > page;
        dataMess.addAll(fetchedChats);
        isLoading = false;
        isLoadingMore = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
      print("Error fetching chat data: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.lightBlueColor,
                ),
              )
            : Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                      bottom: 20, left: 20, right: 20),
                  child: ListView.builder(
                    reverse: true,
                    controller: _scrollController,
                    itemCount: dataMess.length,
                    itemBuilder: (context, index) {
                      if (isLoadingMore && index == dataMess.length - 1) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.lightBlueColor,
                          ),
                        );
                      }

                      bool isLastMessage = index == 0;
                      bool isDifferentSender = isLastMessage ||
                          (dataMess[index].sender?.id !=
                              dataMess[index - 1].sender?.id);

                      return Message(
                        message: dataMess[index],
                        isLastMessage: isDifferentSender,
                      );
                    },
                  ),
                ),
              ),
        !isLoading ? ChatInputField() : Container(),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
