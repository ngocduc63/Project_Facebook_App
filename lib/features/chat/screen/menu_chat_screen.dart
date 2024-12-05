import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/constants/router_constants.dart';
import 'package:facebook/controllers/api_controller.dart';
import 'package:facebook/models/chat_model.dart';
import 'package:facebook/utils/prefs_user.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MenuChatScreen extends StatefulWidget {
  static const String routeName = RouterConstants.menuChatScreen;
  final ChatModel chat;

  const MenuChatScreen({super.key, required this.chat});

  @override
  State<MenuChatScreen> createState() => _MenuChatScreenState();
}

class _MenuChatScreenState extends State<MenuChatScreen> {
  String groupName = '';
  XFile? selectedAvatar;
  final ImagePicker _picker = ImagePicker();
  ApiController apiController = ApiController();

  @override
  void initState() {
    super.initState();
    groupName = widget.chat.name!;
  }

  Future<void> _pickMedia(
      ImageSource source, BuildContext context) async {
    try {
        selectedAvatar = await _picker.pickImage(
          source: source,
          maxWidth: 1080,
          imageQuality: 85,
        );

        // final response = await apiController.imageForm(
        //     ApiConfig.updateAvatar, selectedAvatar!, isCover);

        // if (response.statusCode == 200) {
        //   final user = jsonEncode(response.data['metadata']['user']);
        //   await UserServicePref.instance.saveUser(user);

        //   Fluttertoast.showToast(
        //       msg: "Cập nhật ảnh đại diện thành công",
        //       toastLength: Toast.LENGTH_SHORT,
        //       gravity: ToastGravity.TOP_LEFT,
        //       timeInSecForIosWeb: 1,
        //       backgroundColor: Colors.green,
        //       textColor: Colors.white,
        //       fontSize: 16.0);
        // }
    } catch (e) {
      print("Error picking media: $e");
    }
  }

  void _renameGroup() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController nameController =
            TextEditingController(text: groupName);
        return AlertDialog(
          title: const Text("Đổi tên nhóm"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "Tên mới"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Hủy",
                style: TextStyle(color: AppColors.lightBlueColor),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  groupName = nameController.text;
                });
                Navigator.pop(context);
              },
              child: const Text(
                "Xác nhận",
                style: TextStyle(color: AppColors.lightBlueColor),
              ),
            ),
          ],
        );
      },
    );
  }

  void _viewProfile() {
    print("Xem trang cá nhân");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông tin nhóm chat'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      '${ApiConfig.linkImage}${widget.chat.image}',
                    ),
                  ),
                  if(widget.chat.membersInfo[0].id == UserServicePref.instance.getUserInfo.id)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          _pickMedia(
                              ImageSource.gallery, context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.black,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                groupName,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Số thành viên : ${widget.chat.membersInfo.length}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _renameGroup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.drive_file_rename_outline),
                label: const Text("Đổi tên nhóm"),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _viewProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.person),
                label: const Text("Xem thành viên"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
