import 'package:flutter/material.dart';
import 'package:kaist_summer_camp/component/contact_recentcall_component.dart';
import 'package:kaist_summer_camp/component/contact_scroll_component.dart';
import 'package:permission_handler/permission_handler.dart';

import '../model/contact_model.dart';
import '../util/util.dart';

class PhoneBookScreen extends StatefulWidget {
  const PhoneBookScreen({super.key});

  @override
  State<PhoneBookScreen> createState() => _PhoneBookScreenState();
}

class _PhoneBookScreenState extends State<PhoneBookScreen> {
  late Future<List<ContactModel>> contactList;
  String _searchText = '';
  FocusNode _focusNode = FocusNode();
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    contactList = Util.getContactInfoFromPhoneContact();
    _focusNode.addListener(() {
      setState(() {});
    });
    _scrollController.addListener(() {
      if (_focusNode.hasFocus) {
        _focusNode.unfocus();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Contact',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          leading: Padding(
            padding: EdgeInsets.only(left: 8.0, top: 4.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0), // 둥근 모서리의 정도를 조정
              child: Image.asset(
                'asset/default_profile.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 8.0, top: 4.0),
              child: IconButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue), // 박스 색상
                  padding: MaterialStateProperty.all<EdgeInsets>(
                      EdgeInsets.zero), // 패딩 설정
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0), // 둥근 모서리 설정
                    ),
                  ),
                ),
                icon: Icon(Icons.mode_edit,
                    size: 24.0, color: Colors.white), // 연필 아이콘
                onPressed: () {
                  // 연락처 추가 액션
                },
              ),
            ),
          ],
        ),
        body: FutureBuilder<List<ContactModel>>(
            future: contactList,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // 로딩 중일 때 표시할 위젯
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                // 오류 발생 시 표시할 위젯

                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                // 데이터가 없을 때 표시할 위젯
                return Center(child: Text('No contacts found'));
              } else {
                // 데이터가 로드되었을 때 표시할 위젯
                List<ContactModel> contacts = snapshot.data!;

                return NestedScrollView(
                  physics: BouncingScrollPhysics(),
                  controller: _scrollController,
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 16.0),
                          child: TextField(
                            focusNode: _focusNode,
                            onChanged: (text) {
                              setState(() {
                                _searchText = text;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: _focusNode.hasFocus ? null : 'Search',
                              hintStyle: TextStyle(color: Colors.grey.shade700),
                              filled: true,
                              fillColor: Colors.grey.withOpacity(0.15),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 16.0),
                              prefixIcon: _focusNode.hasFocus
                                  ? null
                                  : Icon(Icons.search,
                                      color: Colors.grey.shade500),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                          child: HorizontalContactsView(contacts: contacts),
                      )];
                  },
                  body: ContactScrollComponent(contactsToShow: contacts),
                );
              }
            }),
      ),
    );
  }
}
