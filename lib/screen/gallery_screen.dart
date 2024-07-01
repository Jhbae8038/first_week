//gallery_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';


import '../provider/gallery_image_provider.dart';


class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  int _currentIndex = 0;//현재 이미지의 인덱스
  PageController _pageController= PageController();//페이지 컨트롤러(이미지 슬라이드)
  final PageStorageKey _pageStorageKey = PageStorageKey('gallery_key');//페이지 저장 키

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);//페이지 컨트롤러 초기화
    //_loadImages();//이미지 로드
  }
  @override
  void dispose() {
    _pageController.dispose();//페이지 컨트롤러 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {//화면 구성
    final List<File> images = ref.watch(imageProvider);//이미지 리스트

    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              await ref.read(imageProvider.notifier).addMultiImage();//이미지 추가
              setState(() {});
            },
          ),
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: () {
              ref.read(imageProvider.notifier).addFile();//카메라로 이미지 추가
            },
          ),
        ],
      ),
      body: images.isEmpty//이미지가 없을 경우
          ? Center(child: Text('No images selected.'))
          : GridView.builder(//이미지가 있을 경우
        key: _pageStorageKey,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(//그리드뷰 설정
          crossAxisCount: 3,//한 줄에 표시할 이미지 개수
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,//이미지 간 간격
        ),
        itemCount: images.length,//이미지 개수
        itemBuilder: (context, index) {//이미지 빌더
          return GestureDetector(//이미지 클릭 시 확대
            onTap: () {
              Navigator.push(//이미지 확대 페이지로 이동
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(),
                    body: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                      ),
                      child: PhotoViewGallery.builder(
                        itemCount: images.length,
                        builder: (context, i) {
                          return PhotoViewGalleryPageOptions(
                            imageProvider: FileImage(images[i]),
                            minScale: PhotoViewComputedScale.contained,
                            maxScale: PhotoViewComputedScale.covered * 2.0,
                            initialScale: PhotoViewComputedScale.contained,
                            heroAttributes: PhotoViewHeroAttributes(tag: i),//이미지 확대 시 효과
                          );
                        },
                        scrollPhysics: BouncingScrollPhysics(),
                        pageController: PageController(initialPage: index),
                        onPageChanged: (i) {
                          setState(() {
                            _currentIndex = i;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
            onLongPress: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(//이미지 삭제 확인 다이얼로그
                  title: Text('이미지 삭제'),
                  content: Text('이미지를 삭제하시겠습니까?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);//다이얼로그 닫기
                      },
                      child: Text('취소'),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(imageProvider.notifier).removeFileIndex(index);
                        setState(() {Navigator.pop(context);});
                      },
                      child: Text('삭제'),
                    ),
                  ],
                ),
              );
            },
            child: Image.file(images[index], fit: BoxFit.cover),
          );
        },
      ),
    );
  }

}
