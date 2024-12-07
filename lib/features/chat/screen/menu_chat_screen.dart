import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/constants/router_constants.dart';
import 'package:facebook/controllers/api_controller.dart';
import 'package:facebook/controllers/user_controller/user_controller.dart';
import 'package:facebook/models/chat_model.dart';
import 'package:facebook/utils/prefs_user.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  XFile? selectedImage;
  final ImagePicker _picker = ImagePicker();
  ApiController apiController = ApiController();
  UserController userController = UserController();

  @override
  void initState() {
    super.initState();
    groupName = widget.chat.name!;
  }

  Future<void> _pickMedia(ImageSource source, BuildContext context) async {
    try {
      selectedImage = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        imageQuality: 85,
      );

      Fluttertoast.showToast(
          msg: "Vui lòng chờ giây lát",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP_LEFT,
          timeInSecForIosWeb: 1,
          backgroundColor: AppColors.lightBlueColor,
          textColor: Colors.white,
          fontSize: 16.0);

      final response = await apiController.updateImageRoom(
        ApiConfig.updateImageRoom,
        selectedImage!,
        widget.chat.id!,
      );

      if (response.statusCode == 200) {
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouterConstants.chat,
            (Route<dynamic> route) => false, // Xóa tất cả các route trước đó
          );
        }

        Fluttertoast.showToast(
            msg: "Cập nhật ảnh đại diện thành công",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP_LEFT,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (e) {
      print("Error picking media: $e");
    }
  }

  void _renameGroup(BuildContext contextMenu) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController nameController =
            TextEditingController(text: groupName);
        return AlertDialog(
          title: const Text("Đổi tên nhóm"),
          content: TextField(
            controller: nameController,
            cursorColor: AppColors.lightBlueColor,
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
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  return;
                }
                
                final check = await userController.renameGroupController(
                    widget.chat.id!, name);
                if (check) {
                  if (contextMenu.mounted) {
                    Navigator.pushNamedAndRemoveUntil(contextMenu,
                        RouterConstants.chat, (Route<dynamic> route) => false);
                  }
                } 
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

  void _viewProfile(BuildContext context) {
    Navigator.pushNamed(context, RouterConstants.membersGroupScreen,
        arguments: widget.chat);
  }

  void _inviteMembers() {}

  Future<void> _outGroup(BuildContext context) async {
    try {
      Fluttertoast.showToast(
          msg: "Vui lòng chờ giây lát",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP_LEFT,
          timeInSecForIosWeb: 1,
          backgroundColor: AppColors.lightBlueColor,
          textColor: Colors.white,
          fontSize: 16.0);

      final check = await userController.outGroupController(
          widget.chat.id!, UserServicePref.instance.getUserInfo.id);

      if (check) {
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
              context, RouterConstants.chat, (Route<dynamic> route) => false);
        }

        Fluttertoast.showToast(
            msg: "Rời nhóm thành công",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP_LEFT,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (e) {
      print("Error picking media: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLeadRoom = widget.chat.membersInfo[0].id ==
        UserServicePref.instance.getUserInfo.id;
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                  if (isLeadRoom)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () async {
                          await _pickMedia(ImageSource.gallery, context);
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
              if (isLeadRoom)
                Column(
                  children: [
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        _renameGroup(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.drive_file_rename_outline),
                      label: const Text("Đổi tên nhóm"),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _inviteMembers,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.person_add_alt_1),
                      label: const Text("Mời thêm thành viên"),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  _viewProfile(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.person),
                label: const Text("Xem thành viên"),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  await _outGroup(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.output),
                label: const Text("Rời nhóm"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
