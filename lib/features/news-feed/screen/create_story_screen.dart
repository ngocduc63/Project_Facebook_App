import 'dart:io';

import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/constants/enum_common.dart';
import 'package:facebook/constants/router_constants.dart';
import 'package:facebook/controllers/api_controller.dart';
// import 'package:facebook/features/auth/widgets/input_fields.dart';
import 'package:facebook/features/home/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  static const routeName = RouterConstants.createStory;

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _mediaFile;
  bool _isVideo = false;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  TextEditingController _titleController = TextEditingController();
  PostStatus _postStatus = PostStatus.public;

  ApiController apiController = ApiController();
  bool isLoading = false;

  @override
  void dispose() {
    try {
      _videoController?.dispose();
      _titleController.dispose();
      _chewieController?.dispose();
    } catch (e) {
      print(e);
    }
    super.dispose();
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

  Future<void> _pickMedia(ImageSource source, bool isVideo) async {
    try {
      final pickedFile = isVideo
          ? await _picker.pickVideo(
              source: source,
              maxDuration: source == ImageSource.camera
                  ? const Duration(minutes: 1)
                  : null,
            )
          : await _picker.pickImage(
              source: source,
              maxWidth: 1080,
              imageQuality: 85,
            );

      if (pickedFile != null) {
        _videoController?.dispose();
        _chewieController?.dispose();

        if (isVideo) {
          final videoPlayerController =
              VideoPlayerController.file(File(pickedFile.path));
          await videoPlayerController.initialize();

          final videoDuration = videoPlayerController.value.duration;

          if (videoDuration > const Duration(minutes: 1)) {
            Fluttertoast.showToast(
                msg: "Vui lòng chọn video nhỏ hơn 1 phút",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.TOP_LEFT,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
            return;
          }

          _videoController = videoPlayerController;
          _chewieController = ChewieController(
            videoPlayerController: _videoController!,
            autoPlay: true,
            looping: false,
          );
        }

        setState(() {
          _mediaFile = pickedFile;
          _isVideo = isVideo;
        });
      }
    } catch (e) {
      print("Error picking media: $e");
    }
  }

  void _clearMedia() {
    setState(() {
      _mediaFile = null;
      _isVideo = false;
      _videoController?.dispose();
      _chewieController?.dispose();
    });
  }

  Future<void> _uploadStory() async {
    if (_mediaFile == null) {
      Fluttertoast.showToast(
          msg: "Vui lòng chọn 1 ảnh hoặc video",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP_LEFT,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await apiController.storyForm(
          ApiConfig.createStory, _mediaFile!, _titleController.text, _isVideo, _postStatus);
      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "Đăng story thành công",
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
    Get.off(HomeScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tạo story'),
        actions: [
          if (_mediaFile != null)
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: _clearMedia,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _mediaFile == null
                  ? Text('Chọn 1 ảnh hoặc video')
                  : _isVideo
                      ? _chewieController != null
                          ? Chewie(controller: _chewieController!)
                          : CircularProgressIndicator()
                      : Image.file(File(_mediaFile!.path)),
            ),
          ),
          // InputTextFieldWidget(_titleController, 'Nhập tiêu đề'),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickMedia(ImageSource.gallery, false),
                        icon: Icon(Icons.photo),
                        label: Text('Ảnh'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightBlueColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickMedia(ImageSource.camera, false),
                        icon: Icon(Icons.camera_alt),
                        label: Text('Camera'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightBlueColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickMedia(ImageSource.gallery, true),
                        icon: Icon(Icons.video_library),
                        label: Text('Video'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightBlueColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                isLoading
                    ? CircularProgressIndicator(
                        color: AppColors.lightBlueColor,
                      )
                    : SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: ElevatedButton.icon(
                          onPressed: _uploadStory,
                          icon: Icon(Icons.upload),
                          label: Text('Đăng story'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.lightBlueColor,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
