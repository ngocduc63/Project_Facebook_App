import 'package:facebook/constants/enum_common.dart';
import 'package:facebook/constants/global_variables.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

typedef OnButtonPressedCallback = void Function(Emotion newReaction);

class ReactionButton extends StatefulWidget {
  const ReactionButton({
    Key? key,
    this.initialReaction,
    this.onReactionChanged,
    this.userHasLike,
    this.handleLike,
  }) : super(key: key);

  final Emotion? initialReaction;
  final OnButtonPressedCallback? onReactionChanged;
  final Map<String, dynamic>? userHasLike;
  final OnButtonPressedCallback? handleLike;

  @override
  State<ReactionButton> createState() => _ReactionButtonState();
}

class _ReactionButtonState extends State<ReactionButton> {
  Emotion _reaction = Emotion.none;
  bool _reactionView = false;
  bool isLoadingLike = false;

  late OverlayEntry overlayEntry;

  final GlobalKey _key = GlobalKey(); // Thêm GlobalKey để lấy vị trí

  final List<ReactionElement> reactions = [
    ReactionElement(
      Emotion.like,
      Image.asset(
        'assets/images/reactions/like.png',
        width: 24,
      ),
    ),
    ReactionElement(
      Emotion.love,
      Image.asset(
        'assets/images/reactions/love.png',
        width: 24,
      ),
    ),
    ReactionElement(
      Emotion.lovelove,
      Image.asset(
        'assets/images/reactions/care.png',
        width: 24,
      ),
    ),
    ReactionElement(
      Emotion.haha,
      Image.asset(
        'assets/images/reactions/haha.png',
        width: 24,
      ),
    ),
    ReactionElement(
      Emotion.wow,
      Image.asset(
        'assets/images/reactions/wow.png',
        width: 24,
      ),
    ),
    ReactionElement(
      Emotion.sad,
      Image.asset(
        'assets/images/reactions/sad.png',
        width: 24,
      ),
    ),
    ReactionElement(
      Emotion.angry,
      Image.asset(
        'assets/images/reactions/angry.png',
        width: 24,
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _reaction = widget.initialReaction ?? Emotion.none;
  }

  void onCloseOverlay() {
    overlayEntry.remove();
  }

  void _showReactionPopUp(BuildContext context) {
    final renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
    final position = renderBox?.localToGlobal(Offset.zero);
    final tapPosition =
        position != null ? Offset(position.dx, position.dy) : Offset.zero;

    final screenWidth = MediaQuery.of(context).size.width;
    double left = tapPosition.dx;

    if ((screenWidth - left) < 100) {
      left = left - 100;
    } else {
      left = left - 20;
    }

    overlayEntry = OverlayEntry(
      builder: (BuildContext context) => Positioned(
        left: left + 35,
        top: tapPosition.dy - 58,
        child: Material(
          child: Container(
            height: 50,
            width: 335,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(50),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: reactions.length,
              itemBuilder: (BuildContext context, int index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 15 + index * 15,
                    child: FadeInAnimation(
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            isLoadingLike = true;
                            _reaction = reactions[index].reaction;
                            if (widget.onReactionChanged != null &&
                                widget.userHasLike!['isLiked']) {
                              widget.onReactionChanged!(_reaction);
                            } else {
                              widget.handleLike!(_reaction);
                            }
                            _reactionView = false;
                          });

                          onCloseOverlay();

                          setState(() {
                            isLoadingLike = false;
                          });
                        },
                        icon: reactions[index].icon,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) {
        _showReactionPopUp(context); // Thay đổi ở đây
        setState(() {
          _reactionView = true;
        });
      },
      child: InkWell(
        onTap: () {
          setState(() {
            isLoadingLike = true;
          });

          if (_reactionView) {
            onCloseOverlay();
            setState(() {
              _reactionView = false;
            });
          } else {
            // Gọi hàm xử lý khi nhấn
            if (_reaction == Emotion.none) {
              _reaction = Emotion.like;
            } else {
              _reaction = Emotion.none;
            }

            if (widget.userHasLike!['isLiked'] && _reaction != Emotion.none) {
              if (widget.onReactionChanged != null &&
                  _reaction != Emotion.none) {
                widget.onReactionChanged!(_reaction);
              }
            } else {
              widget.handleLike!(_reaction);
            }
          }

          setState(() {
            isLoadingLike = false;
          });
        },
        child: Container(
          key: _key, // Gán GlobalKey cho Container
          padding: const EdgeInsets.symmetric(vertical: 11.5),
          alignment: Alignment.center,
          width: (MediaQuery.of(context).size.width) / 3,
          child: isLoadingLike
              ? SizedBox(
                  height: 24,
                  width: 24,
                  child: const CircularProgressIndicator(
                    color: GlobalVariables.secondaryColor,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ReactionIcon(reaction: _reaction),
                    const SizedBox(width: 8),
                    Text(
                      widget.userHasLike?['text'] ?? '',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: widget.userHasLike?['isLiked'] == true
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: widget.userHasLike?['color'] ?? Colors.black,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class ReactionIcon extends StatelessWidget {
  const ReactionIcon({super.key, required this.reaction});
  final Emotion reaction;

  @override
  Widget build(BuildContext context) {
    switch (reaction) {
      case Emotion.like:
        return Image.asset(
          'assets/images/reactions/like.png',
          width: 24,
        );
      case Emotion.love:
        return Image.asset(
          'assets/images/reactions/love.png',
          width: 24,
        );
      case Emotion.haha:
        return Image.asset(
          'assets/images/reactions/haha.png',
          width: 24,
        );
      case Emotion.sad:
        return Image.asset(
          'assets/images/reactions/sad.png',
          width: 24,
        );
      case Emotion.lovelove:
        return Image.asset(
          'assets/images/reactions/care.png',
          width: 24,
        );
      case Emotion.angry:
        return Image.asset(
          'assets/images/reactions/angry.png',
          width: 24,
        );
      case Emotion.wow:
        return Image.asset(
          'assets/images/reactions/wow.png',
          width: 24,
        );
      case Emotion.none:
      default:
        return Image.asset(
          'assets/images/like.png', // Icon mặc định nếu không có reaction nào
          width: 24,
        );
    }
  }
}

class ReactionElement {
  final Emotion reaction;
  final Image icon;

  ReactionElement(this.reaction, this.icon);
}
