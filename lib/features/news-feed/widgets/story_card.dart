import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/constants/global_variables.dart';
import 'package:facebook/features/news-feed/widgets/story_details.dart';
import 'package:facebook/models/story_model.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class StoryCard extends StatefulWidget {
  final StoryModel story;
  final bool? hidden;
  const StoryCard({super.key, required this.story, this.hidden});

  @override
  State<StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard> {
  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();
    if (widget.story.lastStory.video != '') {
      controller = VideoPlayerController.networkUrl(
        Uri.parse('${ApiConfig.linkVideo}${widget.story.lastStory.video}'),
      )..initialize().then((_) {
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    if (widget.story.lastStory.video != '') controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 180,
      padding: const EdgeInsets.all(0),
      decoration: (widget.story.lastStory.video == '')
          ? BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.black12,
                width: 1,
              ),
              image: DecorationImage(
                image: NetworkImage(
                  '${ApiConfig.linkImage}${widget.story.lastStory.image}',
                ),
                fit: BoxFit.cover,
              ),
            )
          : BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.black12,
                width: 1,
              ),
            ),
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            if (widget.story.lastStory.video != '')
              ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    color: AppColors.blackColor,
                    child: Center(
                      child: controller.value.isInitialized
                          ? AspectRatio(
                              aspectRatio: controller.value.aspectRatio,
                              child: VideoPlayer(controller),
                            )
                          : Center(
                              child: CircularProgressIndicator(
                              color: AppColors.lightBlueColor,
                            )),
                    ),
                  )),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                Navigator.pushNamed(context, StoryDetails.routeName,
                    arguments: widget.story);
              },
              child: SizedBox(
                width: 120,
                height: 180,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if (widget.hidden != true)
                      Container(
                        margin: const EdgeInsets.only(
                          left: 5,
                          top: 5,
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: GlobalVariables.secondaryColor,
                            width: 3,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 15,
                            backgroundImage: NetworkImage(
                              '${ApiConfig.linkImage}${widget.story.user.avatar}',
                            ),
                          ),
                        ),
                      ),
                    if (widget.hidden != true)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 5,
                          bottom: 5,
                        ),
                        child: Text(
                          widget.story.user.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
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
