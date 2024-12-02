import 'dart:io';

import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/constants/enum_common.dart';
import 'package:facebook/constants/router_constants.dart';
import 'package:facebook/controllers/api_controller.dart';
import 'package:facebook/features/auth/widgets/submit_button.dart';
import 'package:facebook/features/home/screens/home_screen.dart';
import 'package:facebook/utils/utils.dart';
import 'package:facebook/features/news-feed/widgets/image_video_view.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  static const routeName = RouterConstants.createPost;

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  late final TextEditingController _postController;
  PostStatus _postStatus = PostStatus.public;
  ApiController apiController = ApiController();
  bool isLoaing = false;
  List<File> images = [];
  List<File> videos = [];
  bool isLoading = false;

  // Keep track of rotation angles
  Map<File, double> rotationAngles = {};

  @override
  void initState() {
    _postController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  void rotateFile(File file) {
    setState(() {
      // Rotate the file by 90 degrees
      rotationAngles[file] = (rotationAngles[file] ?? 0) + 90;
      // Ensure angle is within 0-360 degrees
      if (rotationAngles[file]! >= 360) {
        rotationAngles[file] = 0;
      }
    });
  }

  String _getStatusText(PostStatus status) {
    switch (status) {
      case PostStatus.public:
        return "Công khai";
      case PostStatus.private:
        return "Riêng tư";
      case PostStatus.friend:
        return "Bạn bè";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: uploadPostHandle,
            child: const Text('Post'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post text field
              TextField(
                controller: _postController,
                cursorColor: AppColors.lightBlueColor,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Bạn đang nghĩ gì?',
                  hintStyle: TextStyle(
                    fontSize: 18,
                    color: AppColors.darkGreyColor,
                  ),
                ),
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 10,
              ),

              const SizedBox(height: 20),
              const Text(
                "Chọn trạng thái bài viết:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: PostStatus.values.map((status) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _postStatus = status;
                        });
                      },
                      child: Row(
                        children: [
                          Radio<PostStatus>(
                            value: status,
                            groupValue: _postStatus,
                            onChanged: (PostStatus? value) {
                              setState(() {
                                _postStatus = value!;
                              });
                            },
                            activeColor: Colors.blue,
                          ),
                          Text(
                            _getStatusText(status),
                            style: TextStyle(
                              fontSize: 16,
                              color: _postStatus == status
                                  ? Colors.blue
                                  : Colors.black,
                              fontWeight: _postStatus == status
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
              if (images.length + videos.length < 10)
                PickFileWidget(
                  pickImage: () async {
                    final pickedFile = await pickImage();
                    if (pickedFile != null && images.length < 10) {
                      setState(() {
                        images.add(pickedFile);
                      });
                    }
                  },
                  pickVideo: () async {
                    final pickedFile = await pickVideo();
                    if (pickedFile != null && videos.length < 10) {
                      setState(() {
                        videos.add(pickedFile);
                      });
                    }
                  },
                ),

              // Display selected images
              if (images.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Ảnh đã chọn:",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: images.map((file) {
                        return Stack(
                          children: [
                            // Keep aspect ratio while rotating
                            AspectRatio(
                              aspectRatio:
                                  1, // Replace with your desired aspect ratio
                              child: Transform.rotate(
                                angle: (rotationAngles[file] ?? 0) *
                                    (3.14159265 /
                                        180), // Convert degrees to radians
                                child: ImageVideoView(
                                  file: file,
                                  fileType: 'image',
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    images.remove(file);
                                  });
                                },
                                child: CircleAvatar(
                                  backgroundColor: Colors.black54,
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () => rotateFile(file),
                                child: CircleAvatar(
                                  backgroundColor: Colors.black54,
                                  child: Icon(
                                    Icons.rotate_right,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),

              // Display selected videos
              if (videos.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Video đã chọn:",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: videos.map((file) {
                        return Stack(
                          children: [
                            // Keep aspect ratio while rotating
                            AspectRatio(
                              aspectRatio:
                                  1, // Replace with your desired aspect ratio
                              child: Transform.rotate(
                                angle: (rotationAngles[file] ?? 0) *
                                    (3.14159265 /
                                        180), // Convert degrees to radians
                                child: ImageVideoView(
                                  file: file,
                                  fileType: 'video',
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    videos.remove(file);
                                  });
                                },
                                child: CircleAvatar(
                                  backgroundColor: Colors.black54,
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () => rotateFile(file),
                                child: CircleAvatar(
                                  backgroundColor: Colors.black54,
                                  child: Icon(
                                    Icons.rotate_right,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              Center(
                child: SubmitButton(
                  onPressed: uploadPostHandle,
                  title: "Đăng bài",
                  isLoading: isLoading,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> uploadPostHandle() async {
    final content = _postController.text;
    if (content.isNotEmpty || images.isNotEmpty || videos.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      try {
        final response = await apiController.postForm(
            ApiConfig.createPost, images, videos, content, _postStatus);

        if (response.statusCode == 200) {
          Fluttertoast.showToast(
              msg: "Đăng bài viết thành công",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.TOP_LEFT,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0);
          Get.off(HomeScreen());
        } else {
          throw Exception();
        }
      } catch (e) {
        print(e);
      }
      setState(() {
        isLoading = false;
      });
    }
  }
}

class PickFileWidget extends StatelessWidget {
  const PickFileWidget({
    super.key,
    required this.pickImage,
    required this.pickVideo,
  });

  final VoidCallback pickImage;
  final VoidCallback pickVideo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: pickImage,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            backgroundColor: AppColors.lightBlueColor,
          ),
          child: const Text(
            'Chọn ảnh',
            style: TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: pickVideo,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            backgroundColor: AppColors.lightBlueColor,
          ),
          child: const Text(
            'Chọn video',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
