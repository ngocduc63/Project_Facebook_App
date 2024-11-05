import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/constants/global_variables.dart';
import 'package:facebook/features/news-feed/screen/image_fullscreen.dart';
import 'package:facebook/models/post_model.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PostWidget1Child extends StatefulWidget {
  final PostModel post;
  final bool isImage;
  final int index;
  const PostWidget1Child({Key? key, required this.post, required this.isImage, required this.index}) : super(key: key);

  @override
  State<PostWidget1Child> createState() => _PostWidget1ChildState();
}

class _PostWidget1ChildState extends State<PostWidget1Child> {
  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;
  Future<void>? thumbnailFuture; // Biến để lấy thumbnail

  @override
  void initState() {
    super.initState();
    if (!widget.isImage) {
      // Chỉ khởi tạo VideoPlayerController khi không có ảnh
      if (widget.post.video != null && widget.post.video!.isNotEmpty) {
        final linkvideo = '${ApiConfig.linkVideo}${widget.post.video![widget.index]}';
        videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(linkvideo),
        );

        // Lấy thumbnail từ video
        thumbnailFuture = _loadThumbnail();

        // Khởi tạo ChewieController với VideoPlayerController
        chewieController = ChewieController(
          videoPlayerController: videoPlayerController!,
          autoPlay: false,
          looping: false,
          materialProgressColors: ChewieProgressColors(
            playedColor: GlobalVariables.secondaryColor,
            handleColor: Colors.white,
            backgroundColor: AppColors.darkGreyColor,
            bufferedColor: AppColors.greyColor,
          ),
        );
      }
    }
  }

  Future<void> _loadThumbnail() async {
    await videoPlayerController!.initialize();
    await videoPlayerController!.pause();
    await videoPlayerController!.seekTo(Duration.zero);
    await videoPlayerController!.setVolume(0);
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.isImage) {
          Navigator.pushNamed(
            context,
            ImageFullScreen.routeName,
            arguments: widget.post,
          );
        }
      },
      child: (widget.isImage)
          ? FadeInImage(
              placeholder: AssetImage('assets/loading.gif'),
              image: NetworkImage(
                  '${ApiConfig.linkImage}${widget.post.image![widget.index]}'),
              fit: BoxFit.cover,
            )
          : (widget.post.video != null && widget.post.video!.isNotEmpty)
              ? FutureBuilder<void>(
                  future: thumbnailFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      double maxHeight = MediaQuery.of(context).size.height * 0.6;
                      return Container(
                        padding: EdgeInsets.all(6.0),
                        // decoration: BoxDecoration(
                        //   color: Colors.black,
                        //   borderRadius: BorderRadius.circular(10),
                        // ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: AspectRatio(
                            aspectRatio: videoPlayerController != null &&
                                    videoPlayerController!.value.isInitialized
                                ? videoPlayerController!.value.aspectRatio
                                : 16 / 9,
                            child: Container(
                              constraints: BoxConstraints(
                                maxHeight:
                                    maxHeight,
                              ),
                              child: Chewie(
                                controller: chewieController!,
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Center(
                          child: CircularProgressIndicator(
                        color: GlobalVariables.secondaryColor,
                      ));
                    }
                  },
                )
              : SizedBox.shrink(),
    );
  }
}
