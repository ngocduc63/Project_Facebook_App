import 'dart:async';
import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/constants/router_constants.dart';
import 'package:facebook/controllers/api_controller.dart';
import 'package:facebook/features/personal-page/screens/personal_page_screen.dart';
import 'package:facebook/models/user_model.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  static const String routeName = RouterConstants.search;

  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  ApiController apiController = ApiController();
  Timer? _debounce;
  List<UserModel> _searchResults = [];
  bool isLoading = false;
  int page = 0;
  int limit = 15;
  bool hasNextPage = true;

  ScrollController _scrollController = ScrollController();

  Future<void> _onSearchChanged(String query) async {
    if (query.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      page = 1;
      try {
        final response = await apiController.get(ApiConfig.searchUser,
            {'name': query, 'page': page, 'limit': limit});
        List<UserModel> data = (response.data['metadata']['users'] as List)
            .map((user) => UserModel.fromJson(user))
            .toList();

        bool checkNextPage = response.data['metadata']['totalPage'] > page;

        setState(() {
          _searchResults = data;
          hasNextPage = checkNextPage;
          isLoading = false;
        });
      } catch (e) {
        print(e);
      }
    } else {
      setState(() {
        _searchResults.clear();
      });
    }
  }

  Future<void> _loadMoreData() async {
    if (isLoading || !hasNextPage) return;

    setState(() {
      isLoading = true;
    });

    page++;
    try {
      final response = await apiController.get(ApiConfig.searchUser,
          {'name': _controller.text, 'page': page, 'limit': limit});
      List<UserModel> data = (response.data['metadata']['users'] as List)
          .map((user) => UserModel.fromJson(user))
          .toList();

      bool checkNextPage = response.data['metadata']['totalPage'] > page;

      setState(() {
        _searchResults.addAll(data);
        hasNextPage = checkNextPage;
        isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            autofocus: true,
            cursorColor: AppColors.lightBlueColor,
            onChanged: (query) {
              if (_debounce?.isActive ?? false) _debounce?.cancel();

              _debounce = Timer(const Duration(milliseconds: 300), () {
                _onSearchChanged(query);
              });
            },
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 6),
              hintText: 'Tìm kiếm...',
              hintStyle: TextStyle(color: AppColors.darkGreyColor),
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear, color: AppColors.darkGreyColor),
                onPressed: () {
                  _controller.clear();
                  setState(() {
                    _searchResults.clear();
                  });
                },
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _searchResults.length + (isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _searchResults.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                          child: CircularProgressIndicator(
                        color: AppColors.lightBlueColor,
                      )),
                    );
                  }

                  final user = _searchResults[index];
                  return InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, PersonalPageScreen.routeName,
                          arguments: user);
                    },
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(
                                  '${ApiConfig.linkImage}${user.avatar}'),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Số bạn chung
                                  Text(
                                    '${user.countMutual} bạn chung',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
