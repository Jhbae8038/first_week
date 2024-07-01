

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kaist_summer_camp/provider/hive_db_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:device_info_plus/device_info_plus.dart';

final imageProvider = StateNotifierProvider<FileListNotifier, List<File>>((ref) {
  final dbAsync = ref.watch(hiveProvider);

  return dbAsync.when(
    data: (db) {
      return FileListNotifier(galleryBox : db.galleryBox);
    },
    loading: () => FileListNotifier(),
    error: (error, stack) => FileListNotifier(),
  );
});

class FileListNotifier extends StateNotifier<List<File>> {
  final CollectionBox<String>? galleryBox;

  FileListNotifier({this.galleryBox}) : super([]){
    _loadFiles();
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> _loadFiles() async {
    if (galleryBox != null) {
      galleryBox!.getAllValues().then((value) => state = value.values.map((e) => File(e)).toList());
    }
  }

  Future<void> _saveFiles() async {
    if (galleryBox != null) {
      final filePaths = state.map((file) => file.path).toList();
      await galleryBox!.clear(); // Clear the box before saving new data
      for (int i = 0; i < filePaths.length; i++) {
        await galleryBox!.put(i.toString(), filePaths[i]);
      }
    }
  }


  // 파일 추가 메서드
  Future<void> addFile() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      state = [...state, File(pickedFile.path)].toList();
      await _saveFiles();
    }
  }

  Future<void> addMultiImage() async {//갤러리에서 이미지를 여러개 선택하는 함수
    final pickedFileList = await _picker.pickMultiImage();
    if (pickedFileList.isNotEmpty) {
        state.addAll(pickedFileList.map((e) => File(e.path)).toList());//선택한 이미지들을 리스트에 추가
        await _saveFiles();
    }
  }

  // 파일 삭제 메서드
  void removeFileIndex(int index) async{
    state.removeAt(index);
    await _saveFiles();
  }

  // 모든 파일 삭제 메서드
  void clearFiles() async{
    state = [];
    await _saveFiles();
  }
}

