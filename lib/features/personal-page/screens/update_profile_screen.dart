import 'dart:convert';

import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/constants/router_constants.dart';
import 'package:facebook/controllers/api_controller.dart';
import 'package:facebook/features/auth/widgets/input_fields.dart';
import 'package:facebook/features/personal-page/screens/personal_page_screen.dart';
import 'package:facebook/models/user_model.dart';
import 'package:facebook/utils/prefs_user.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class UpdateProfileScreen extends StatefulWidget {
  static const routeName = RouterConstants.updateProfile;
  final String name;
  final String hometown;
  final String address;
  final String bio;
  const UpdateProfileScreen({
    Key? key,
    required this.name,
    required this.hometown,
    required this.address,
    required this.bio,
  }) : super(key: key);

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController hometownController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  bool isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ApiController apiController = ApiController();

  Future<void> handleUpdateProfile() async {
    setState(() {
      isLoading = true;
    });
    final response = await apiController.put(ApiConfig.updateProfile, {
      'name': nameController.text.trim(),
      'hometown': hometownController.text.trim(),
      'address': addressController.text.trim(),
      'bio': bioController.text.trim(),
    });

    if (response.statusCode == 200) {
      final user = jsonEncode(response.data['metadata']);
      final UserModel userRs = UserModel.fromJson(response.data['metadata']);
      await UserServicePref.instance.saveUser(user);

      Fluttertoast.showToast(
          msg: "Cập nhật thông tin thành công",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP_LEFT,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
      
      Get.off(PersonalPageScreen(user: userRs));
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa trang cá nhân'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              InputTextFieldWidget(
                nameController,
                "Tên người dùng",
                initialValue: widget.name,
              ),
              const SizedBox(height: 16),
              InputTextFieldWidget(
                bioController,
                "Mô tả",
                initialValue: widget.bio,
              ),
              const SizedBox(height: 16),
              InputTextFieldWidget(
                hometownController,
                "Quê quán",
                initialValue: widget.hometown,
              ),
              const SizedBox(height: 16),
              InputTextFieldWidget(
                addressController,
                "Địa chỉ hiện tại",
                initialValue: widget.address,
              ),
              const SizedBox(height: 32),
              isLoading
                  ? CircularProgressIndicator(
                      color: AppColors.lightBlueColor,
                    )
                  : SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: ElevatedButton.icon(
                        onPressed: handleUpdateProfile,
                        icon: Icon(Icons.update),
                        label: Text('Xác nhận'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightBlueColor,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Hủy bộ điều khiển khi không còn sử dụng
    nameController.dispose();
    hometownController.dispose();
    bioController.dispose();
    addressController.dispose();
    super.dispose();
  }
}
