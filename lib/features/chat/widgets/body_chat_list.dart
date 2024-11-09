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

  @override
  void initState() {
    super.initState();
    _fetchChatsData();
  }

  Future<void> _fetchChatsData() async {
    try {
      final response = await apiController
          .get(ApiConfig.getRoomChat, {"page": 1, "limit": 10});
          
      List<ChatModel> fetchedChats =
          (response.data['metadata'] as List)
              .map((room) => ChatModel.fromJson(room))
              .toList();

      setState(() {
        chatsData = fetchedChats;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      // Handle error if necessary
      print("Error fetching chat data: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: isLoading
              ? Center(
                  child:
                      CircularProgressIndicator(color: AppColors.lightBlueColor,))
              : ListView.builder(
                  itemCount: chatsData.length,
                  itemBuilder: ((context, index) => ChatCard(
                        chat: chatsData[index],
                        press: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MessagesScreen(),
                          ),
                        ),
                      )),
                ),
        )
      ],
    );
  }
}
