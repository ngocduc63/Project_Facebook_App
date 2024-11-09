import 'package:facebook/features/chat/widgets/message/message.dart';
import 'package:facebook/models/message_model.dart';
import 'package:flutter/material.dart';
import 'chat_input_fields.dart';

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    const List<MessageModel> demeChatMessages = [];
    return Column(
      children: [
        Expanded(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView.builder(
            itemCount: demeChatMessages.length,
            itemBuilder: (context, index) => Message(message: demeChatMessages[index]),
          ),
        )),
        ChatInputField()
      ],
    );
  }
}
