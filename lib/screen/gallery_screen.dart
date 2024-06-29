//gallery_screen.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:device_info_plus/device_info_plus.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({Key? key}) : super(key: key);

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<File> _images = []; //이미지 파일을 저장할 리스트
  final ImagePicker _picker = ImagePicker();//이미지 피커
  int _currentIndex = 0;//현재 이미지의 인덱스
  PageController _pageController= PageController();//페이지 컨트롤러(이미지 슬라이드)
  final PageStorageKey _pageStorageKey = PageStorageKey('gallery_key');//페이지 저장 키

  @override
  void initState() {
    super.initState();
    _requestPermission();//권한 요청
    _pageController = PageController(initialPage: _currentIndex);//페이지 컨트롤러 초기화
    //_loadImages();//이미지 로드
  }

  Future<void> _requestPermission() async {//권한 요청 함수
    PermissionStatus status = await Permission.photos.status;

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
          if (!status.isGranted) {
            throw Exception('Permission denied');
          }
          return;
        }
      }
    }

    if (!status.isGranted) {//사진 접근 권한이 없을 경우
      status = await Permission.photos.request();
      if (!status.isGranted) {//사진 접근 권한 요청
        throw Exception('Permission denied');
      }
    }
  }

  Future<void> _pickMultiImage() async {//갤러리에서 이미지를 여러개 선택하는 함수
    final pickedFileList = await _picker.pickMultiImage();
    if (pickedFileList != null) {
      setState(() {
        _images.addAll(pickedFileList.map((e) => File(e.path)).toList());//선택한 이미지들을 리스트에 추가
      });
    }
  }

  void _deleteImage(int index) {//이미지 삭제 함수
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _pickcameraimage(ImageSource source) async{ //카메라에서 이미지를 선택하는 함수
    final image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _images.add(File(image.path));
      });
    }
  }


  @override
  void dispose() {
    _pageController.dispose();//페이지 컨트롤러 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {//화면 구성
    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _pickMultiImage,
          ),
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: () {
              _pickcameraimage(ImageSource.camera);
            },
          ),
        ],
      ),
      body: _images.isEmpty//이미지가 없을 경우
          ? Center(child: Text('No images selected.'))
          : GridView.builder(//이미지가 있을 경우
        key: _pageStorageKey,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(//그리드뷰 설정
          crossAxisCount: 3,//한 줄에 표시할 이미지 개수
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,//이미지 간 간격
        ),
        itemCount: _images.length,//이미지 개수
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
                        itemCount: _images.length,
                        builder: (context, i) {
                          return PhotoViewGalleryPageOptions(
                            imageProvider: FileImage(_images[i]),
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
                        _deleteImage(index);//이미지 삭제
                        Navigator.pop(context);
                      },
                      child: Text('삭제'),
                    ),
                  ],
                ),
              );
            },
            child: Image.file(_images[index], fit: BoxFit.cover),
          );
        },
      ),
    );
  }

}
