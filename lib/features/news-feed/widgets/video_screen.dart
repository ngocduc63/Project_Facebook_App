import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  static Duration videoDuration = Duration.zero;
  final String video; // Đổi tên biến cho rõ ràng

  const VideoPlayerScreen({super.key, required this.video});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();
    // Sử dụng VideoPlayerController.network để phát video từ URL
    controller = VideoPlayerController.networkUrl(Uri.parse('${ApiConfig.linkVideo}${widget.video}'))
      ..initialize().then((_) {
        setState(() {
          controller.setVolume(1.0); // Đặt âm lượng tối đa
          controller.play(); // Phát video tự động
          VideoPlayerScreen.videoDuration =
              controller.value.duration + const Duration(milliseconds: 500);
        });
      }).catchError((error) {
        debugPrint('Error initializing video: $error');
      });
  }

  @override
  void dispose() {
    // Giải phóng tài nguyên
    controller.dispose();
    VideoPlayerScreen.videoDuration = Duration.zero;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: controller.value.aspectRatio, // Đặt tỷ lệ video
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
