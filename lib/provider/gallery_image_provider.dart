

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:device_info_plus/device_info_plus.dart';

final imageProvider = StateNotifierProvider<FileListNotifier, List<File>>((ref) => FileListNotifier());

class FileListNotifier extends StateNotifier<List<File>> {
  FileListNotifier() : super([]);

  final ImagePicker _picker = ImagePicker();

  // 파일 추가 메서드
  Future<void> addFile() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      state = [...state, File(pickedFile.path)].toList();
    }
  }

  Future<void> addMultiImage() async {//갤러리에서 이미지를 여러개 선택하는 함수
    final pickedFileList = await _picker.pickMultiImage();
    if (pickedFileList.isNotEmpty) {
        state.addAll(pickedFileList.map((e) => File(e.path)).toList());//선택한 이미지들을 리스트에 추가
    }
  }

  // 파일 삭제 메서드
  void removeFileIndex(int index) {
    state.removeAt(index);
  }

  // 모든 파일 삭제 메서드
  void clearFiles() {
    state = [];
  }
}

