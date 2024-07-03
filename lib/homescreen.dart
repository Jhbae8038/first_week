
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kaist_summer_camp/const/text_theme.dart';
import 'package:kaist_summer_camp/screen/free_screen.dart';
import 'package:kaist_summer_camp/screen/gallery_screen.dart';
import 'package:kaist_summer_camp/screen/phonebook_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;


  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);
    _controller.animation!.addListener(_handleTabAnimation);
  }

  void _handleTabAnimation() {
    // Check if the transition between tabs is completed

    final newIndex = _controller.animation!.value.round();

    if (newIndex != currentIndex) {
      setState(() {
        currentIndex = newIndex;
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.animation!.removeListener(_handleTabAnimation);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: tabView(),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onTap,
        currentIndex: currentIndex,
        selectedIconTheme: IconThemeData(
            color: Colors.black, size: MediaQuery.of(context).size.width / 10),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'CONTACTS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_album_outlined),
            label: 'GALLERY',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'MEMORIES',
          ),
        ],
        selectedLabelStyle: diaryTextStyle(textSize: 10.0),
        unselectedLabelStyle: diaryTextStyle(textSize: 8.0),
      ),
    );
  }

  void _onTap(index) {
    setState(() {
      currentIndex = index;
      _controller.index = index;
    });
  }

  Widget tabView() {
    return TabBarView(
      controller: _controller,
      children: [
        PhoneBookScreen(),
        GalleryScreen(),
        FreeScreen(),
      ],
    );
  }
}



