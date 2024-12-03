import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/constants/enum_common.dart';
import 'package:facebook/constants/router_constants.dart';
import 'package:facebook/controllers/api_controller.dart';
import 'package:facebook/features/auth/widgets/input_fields.dart';
import 'package:facebook/features/home/screens/home_screen.dart';
import 'package:facebook/models/post_model.dart';
import 'package:facebook/utils/convert_time.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class EditPostScreen extends StatefulWidget {
  static const routeName = RouterConstants.editPost;
  final PostModel post;

  const EditPostScreen({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  TextEditingController _titleController = TextEditingController();
  bool isLoading = false;
  ApiController apiController = ApiController();
  late PostStatus _postStatus;

  @override
  void initState() {
    super.initState();
    _postStatus = widget.post.shareWith ?? PostStatus.public;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> saveChanges() async {
    final updatedTitle = _titleController.text.trim();

    try {
      setState(() {
        isLoading = true;
      });

      final response = await apiController.put(ApiConfig.editPost, {
        'postId': widget.post.id,
        'content': updatedTitle,
        'status': _postStatus.value
      });

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
            msg: "Chỉnh sửa thành công",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP_LEFT,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
        Get.off(HomeScreen());
      }
    } catch (e) {
      print(e);
    }
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
        title: const Text('Chỉnh sửa bài viết'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(
                      '${ApiConfig.linkImage}${widget.post.user!.avatar}'),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.user!.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      convertToTimeAgo(widget.post.time),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.0),
            const Text(
              'Chỉnh sửa trạng thái bài viết:',
              style: TextStyle(
                fontSize: 16,
              ),
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
            const Text(
              'Chỉnh sửa tiêu đề:',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            InputTextFieldWidget(
              _titleController,
              'Tiêu đề bài viết',
              initialValue: widget.post.content,
            ),
            SizedBox(height: 16.0),
            isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.lightBlueColor,
                    ),
                  )
                : Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: ElevatedButton.icon(
                        onPressed: saveChanges,
                        icon: Icon(Icons.edit),
                        label: Text('Xác nhận'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightBlueColor,
                        ),
                      ),
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
