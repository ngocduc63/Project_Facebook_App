import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/constants/global_variables.dart';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  final String videoUrl;
  final double width;
  final double height;
  const VideoWidget({
    Key? key,
    required this.videoUrl,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;
  Future<void>? thumbnailFuture;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

    thumbnailFuture = _loadThumbnail();

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

    setState(() {});
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
    return FutureBuilder<void>(
        future: thumbnailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SizedBox(
              width: widget.width,
              height: widget.height,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Chewie(
                  controller: chewieController!,
                ),
              ),
            );
          } else {
            return Center(
                child: CircularProgressIndicator(
              color: GlobalVariables.secondaryColor,
            ));
          }
        });
  }
}
