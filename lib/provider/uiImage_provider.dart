import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;
import 'package:kaist_summer_camp/provider/memories_provider.dart';

final uiImageProvider = FutureProvider<List<ui.Image>>((ref) {
  final memoryNotifier = ref.watch(memoryProvider.notifier);
  final memory = ref.watch(memoryProvider);

  if(memory.isEmpty) {
    return Future.value([]);
  }
  return memoryNotifier.loadImageToUiImage();
});