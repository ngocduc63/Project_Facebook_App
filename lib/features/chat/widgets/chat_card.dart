import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/models/chat_model.dart';
import 'package:facebook/utils/convert_time.dart';
import 'package:flutter/material.dart';

class ChatCard extends StatelessWidget {
  const ChatCard({
    Key? key,
    required this.chat,
    required this.press,
  }) : super(key: key);

  final ChatModel chat;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 20 * 0.75),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                    radius: 24,
                    child: ClipOval(
                      child: FadeInImage(
                        placeholder: AssetImage('assets/loading.gif'),
                        image: NetworkImage(
                            '${ApiConfig.linkImage}${chat.friend.avatar}'),
                        fit: BoxFit.cover,
                        width: 48,
                        height: 48,
                      ),
                    )),
                if (true)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      height: 16,
                      width: 16,
                      decoration: BoxDecoration(
                        color: Color(0xFF00BF6D),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 3),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat.friend.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    if (chat.lastMessage != null)
                      Opacity(
                          opacity: 0.64,
                          child: Text(
                            '${chat.lastMessage!.isSender() ? 'Bạn: ' : chat.lastMessage?.sender!.name}${chat.lastMessage?.data?.content ?? ""}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
                  ],
                ),
              ),
            ),
            Opacity(
              opacity: 0.64,
              child: Text(convertToTimeAgo(chat.timeUpdate)),
            ),
          ],
        ),
      ),
    );
  }
}
