import 'dart:async';
import 'dart:ui';

import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/constants/enum_common.dart';
import 'package:facebook/features/news-feed/widgets/video_screen.dart';
import 'package:facebook/models/story_model.dart';
import 'package:facebook/utils/convert_time.dart';
import 'package:flutter/material.dart';

class StoryDetails extends StatefulWidget {
  static const String routeName = '/story-details';
  final StoryModel story;
  const StoryDetails({super.key, required this.story});

  @override
  State<StoryDetails> createState() => _StoryDetailsState();
}

class _StoryDetailsState extends State<StoryDetails>
    with TickerProviderStateMixin {
  List<double> progress = [];
  int index = 0;
  Timer? _timer;
  bool buttonClick = false;
  ScrollController scrollController = ScrollController();
  late AnimationController videoProgressController;
  bool showFilter = true;
  bool isInWidgetTree = true;
  @override
  void initState() {
    for (int i = 0; i < widget.story.listStory.length; i++) {
      progress.add(0);
    }
    const oneSec = Duration(milliseconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (mounted) {
        if (widget.story.listStory[index].isVideo()) {
          return;
        }
        setState(() {
          if (progress[index] < 1) {
            progress[index] += 0.0002;
          } else {
            if (index < progress.length - 1) {
              progress[index + 1] += 0.0002;
              index++;
            }
          }
        });
      }
    });
    scrollController.addListener(() {
      if (scrollController.offset > 0) {
        if (widget.story.listStory[index].isImage()) _timer?.cancel();
      } else {
        if (widget.story.listStory[index].isImage()) {
          if (_timer == null || (_timer != null && !_timer!.isActive)) {
            setState(() {
              _timer = Timer.periodic(oneSec, (Timer timer) {
                if (mounted) {
                  setState(() {
                    if (progress[index] < 1) {
                      progress[index] += 0.0002;
                    } else {
                      if (index < progress.length - 1) {
                        progress[index + 1] += 0.0002;
                        index++;
                      }
                    }
                  });
                }
              });
            });
          }
        }
      }
    });

    videoProgressController = AnimationController(
      vsync: this,
      duration: const Duration(microseconds: 1),
    )..addListener(() {
        setState(() {
          if (widget.story.listStory[index].isVideo()) {
            if (VideoPlayerScreen.videoDuration.compareTo(Duration.zero) > 0) {
              videoProgressController.duration =
                  VideoPlayerScreen.videoDuration;
            }
          }
          if (videoProgressController.value > 0.99) {
            videoProgressController.value = 0;
            if (index < progress.length - 1) {
              progress[index] = 1;
              VideoPlayerScreen.videoDuration = Duration.zero;
              index++;
            } else {
              index = 0;
              for (int i = 0; i < progress.length; i++) {
                progress[i] = 0;
              }
            }
          }
        });
      });

    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    videoProgressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.story.listStory[index].isVideo()) {
      videoProgressController.repeat();
    }
    return isInWidgetTree
        ? Dismissible(
            key: const Key('story-details'),
            direction: DismissDirection.down,
            onUpdate: (details) {
              if (details.progress == 0) {
                setState(() {
                  showFilter = true;
                });
              } else {
                setState(() {
                  showFilter = false;
                });
              }
            },
            onDismissed: (direction) {
              setState(() {
                isInWidgetTree = false;
              });
              Navigator.pop(context);
            },
            child: GestureDetector(
              onTapDown: (details) {
                if (buttonClick) return;
                if (details.localPosition.dx >=
                    MediaQuery.of(context).size.width / 2) {
                  setState(() {
                    if (widget.story.listStory[index].isVideo()) {
                      videoProgressController.value = 0;
                      VideoPlayerScreen.videoDuration = Duration.zero;
                    }

                    progress[index] = 1;
                    if (index < progress.length - 1) {
                      progress[index + 1] = 0;

                      index++;
                    } else {
                      progress[0] = 0;
                      index = 0;
                      for (int i = 0; i < progress.length; i++) {
                        progress[i] = 0;
                      }
                    }
                  });
                } else {
                  setState(() {
                    videoProgressController.value = 0;
                    VideoPlayerScreen.videoDuration = Duration.zero;

                    progress[index] = 0;
                    if (index > 0) {
                      progress[index - 1] = 0;
                      index--;
                    } else {
                      progress[progress.length - 1] = 0;
                      index = progress.length - 1;
                      for (int i = 0; i < progress.length - 1; i++) {
                        progress[i] = 1;
                      }
                    }
                  });
                }
              },
              child: Scaffold(
                backgroundColor: Colors.black,
                body: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Container(
                    decoration:
                        (widget.story.listStory[index].isImage() && showFilter)
                            ? BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                      '${ApiConfig.linkImage}${widget.story.listStory[index].image!}'),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : null,
                    child: Stack(
                      children: [
                        if (widget.story.listStory[index].isImage())
                          if (showFilter)
                            BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.1)),
                              ),
                            ),
                        (widget.story.listStory[index].isVideo())
                            ? Center(
                                key: Key(index.toString()),
                                child: VideoPlayerScreen(
                                  video: widget.story.listStory[index].video!,
                                ),
                              )
                            : Center(
                                key: Key(index.toString()),
                                child: Image.network(
                                    '${ApiConfig.linkImage}${widget.story.listStory[index].image!}'),
                              ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  
                                  Row(
                                    children: [
                                      for (int i = 0;
                                          i < widget.story.listStory.length;
                                          i++)
                                        Expanded(
                                            child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 2),
                                          child: LinearProgressIndicator(
                                            backgroundColor:
                                                Colors.grey.withOpacity(0.4),
                                            color: Colors.white,
                                            value: widget.story.listStory[index]
                                                    .isVideo()
                                                ? (i == index
                                                    ? videoProgressController
                                                        .value
                                                    : progress[i])
                                                : progress[i],
                                            minHeight: 2,
                                          ),
                                        )),
                                    ],
                                  ),
                                  
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 10,
                                      top: 10,
                                      bottom: 10,
                                      right: 0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            InkWell(
                                              onTapUp: (details) {
                                                setState(() {
                                                  buttonClick = false;
                                                });
                                              },
                                              onTapDown: (details) {
                                                setState(() {
                                                  buttonClick = true;
                                                });
                                              },
                                              onTapCancel: () {
                                                setState(() {
                                                  buttonClick = false;
                                                });
                                              },
                                              child: CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    '${ApiConfig.linkImage}${widget.story.user.avatar}'),
                                                radius: 20,
                                              ),
                                            ),
                                            Container(
                                              constraints: const BoxConstraints(
                                                maxWidth: 150,
                                              ),
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: Text(
                                                widget.story.user.name,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              convertToTimeAgo(widget
                                                  .story.listStory[index].time),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: Icon(
                                                widget.story.listStory[index]
                                                            .shareWith ==
                                                        PostStatus.public
                                                    ? Icons.public
                                                    : widget
                                                                .story
                                                                .listStory[
                                                                    index]
                                                                .shareWith ==
                                                            PostStatus.friend
                                                        ? Icons.people
                                                        : Icons.lock,
                                                color: Colors.white,
                                                size: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTapUp: (details) {
                                                  setState(() {
                                                    buttonClick = false;
                                                  });
                                                },
                                                onTapDown: (details) {
                                                  setState(() {
                                                    buttonClick = true;
                                                  });
                                                },
                                                onTapCancel: () {
                                                  setState(() {
                                                    buttonClick = false;
                                                  });
                                                },
                                                child: IconButton(
                                                    padding:
                                                        const EdgeInsets.all(0),
                                                    splashColor: Colors.white,
                                                    splashRadius: 20,
                                                    onPressed: () {},
                                                    icon: const Icon(
                                                      Icons.more_horiz_rounded,
                                                      size: 25,
                                                      color: Colors.white,
                                                    )),
                                              ),
                                            ),
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTapUp: (details) {
                                                  setState(() {
                                                    buttonClick = false;
                                                  });
                                                },
                                                onTapDown: (details) {
                                                  setState(() {
                                                    buttonClick = true;
                                                  });
                                                },
                                                onTapCancel: () {
                                                  setState(() {
                                                    buttonClick = false;
                                                  });
                                                },
                                                child: IconButton(
                                                    padding:
                                                        const EdgeInsets.all(0),
                                                    splashColor: Colors.white,
                                                    splashRadius: 20,
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    icon: const Icon(
                                                      Icons.close_rounded,
                                                      size: 25,
                                                      color: Colors.white,
                                                    )),
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTapUp: (details) {
                                  setState(() {
                                    buttonClick = false;
                                  });
                                },
                                onTapDown: (details) {
                                  setState(() {
                                    buttonClick = true;
                                  });
                                },
                                onTapCancel: () {
                                  setState(() {
                                    buttonClick = false;
                                  });
                                },
                                child: SingleChildScrollView(
                                  controller: scrollController,
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                    widget.story.listStory[index].title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          onTap: () {},
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.only(
                                                left: 10,
                                                top: 10,
                                                bottom: 10,
                                                right: 50,
                                              ),
                                              child: Row(
                                                children: [
                                                  ImageIcon(
                                                    AssetImage(
                                                        'assets/images/message.png'),
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    'Gửi tin nhắn...',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: Image.asset(
                                          'assets/images/reactions/like.png',
                                          width: 40,
                                          height: 40,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: Image.asset(
                                          'assets/images/reactions/love.png',
                                          width: 40,
                                          height: 40,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: Image.asset(
                                          'assets/images/reactions/care.png',
                                          width: 40,
                                          height: 40,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: Image.asset(
                                          'assets/images/reactions/haha.png',
                                          width: 40,
                                          height: 40,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: Image.asset(
                                          'assets/images/reactions/wow.png',
                                          width: 40,
                                          height: 40,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: Image.asset(
                                          'assets/images/reactions/sad.png',
                                          width: 40,
                                          height: 40,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: Image.asset(
                                          'assets/images/reactions/angry.png',
                                          width: 40,
                                          height: 40,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        : const SizedBox();
  }
}
