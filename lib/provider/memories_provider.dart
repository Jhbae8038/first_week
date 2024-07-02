

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kaist_summer_camp/model/memory_model.dart';
import 'package:kaist_summer_camp/provider/hive_db_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:device_info_plus/device_info_plus.dart';


final memoryProvider = StateNotifierProvider<MemoryNotifier, List<MemoryModel>>((ref) {
  final dbAsync = ref.watch(hiveProvider);

  return dbAsync.when(
    data: (db) {
      return MemoryNotifier(memoryBox : db.memoryBox);
    },
    loading: () => MemoryNotifier(),
    error: (error, stack) => MemoryNotifier(),
  );
});

class MemoryNotifier extends StateNotifier<List<MemoryModel>> {
  final CollectionBox<MemoryModel>? memoryBox;
  final ImagePicker _picker = ImagePicker();

  MemoryNotifier({this.memoryBox}) : super([]){
    _loadMemory();
  }

  Future<void> _loadMemory() async {
    if (memoryBox != null) {
      memoryBox!.getAllValues().then((value) => state = value.values.toList());
    }
  }

  Future<void> saveMemory() async {
    if (memoryBox != null) {
      await memoryBox!.clear(); // Clear the box before saving new data
      for (int i = 0; i < state.length; i++) {
        await memoryBox!.put(i.toString(), state[i]);
      }
    }
  }

  Future<void> deleteMemory(MemoryModel memory) async {
    state.remove(memory);
    state = state.toList();
    await saveMemory();
  }

  // 파일 추가 메서드
  Future<void> addMemory(MemoryModel memoryModel) async {

    if (memoryModel.imagePath.trim().isNotEmpty) {
      state = [...state, memoryModel].toList();
      await saveMemory();
    }
  }


  Future<List<ui.Image>> loadImageToUiImage() async {
    List<ui.Image> images = [];

    for (int i = 0; i < state.length; i++) {
      final memory = state[i];
      final file = File(memory.imagePath);
      final Uint8List data = await file.readAsBytes();
      final ui.Codec codec = await ui.instantiateImageCodec(data);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      images.add(frameInfo.image);
    }

    return images;
  }
}

