import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  static Duration videoDuration = Duration.zero;
  final String video;

  const VideoPlayerScreen({super.key, required this.video});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.networkUrl(Uri.parse('${ApiConfig.linkVideo}${widget.video}'))
      ..initialize().then((_) {
        setState(() {
          controller.setVolume(1.0);
          controller.play();
          VideoPlayerScreen.videoDuration = controller.value.duration + const Duration(milliseconds: 500);
        });
      }).catchError((error) {
        debugPrint('Error initializing video: $error');
      });
  }

  @override
  void dispose() {
    VideoPlayerScreen.videoDuration = Duration.zero;
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          )
        : const Center(
            child: CircularProgressIndicator(
              color: AppColors.lightBlueColor,
              strokeWidth: 5,
            ),
          );
  }
}
