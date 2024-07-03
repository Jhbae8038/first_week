import 'dart:async';

import 'package:flutter/services.dart';
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

final uiTreeImageProvider = FutureProvider<List<ui.Image>>((ref) {
  final assets = [
    'asset/ground_left.png',
    'asset/brown_right.png',
    'asset/brown_left.png',
    'asset/dg_right.png',
    'asset/dg_left.png',
    'asset/g_right.png',
    'asset/g_left.png',
    'asset/lg_right.png',
    'asset/lg_left.png',
  ];

  final List<Future<ui.Image>> futures = assets.map((asset) => _loadImage(asset)).toList();

  return Future.wait(futures);
});

Future<ui.Image> _loadImage(String asset) async {
  final ByteData data = await rootBundle.load(asset);
  final Completer<ui.Image> completer = Completer();
  ui.decodeImageFromList(data.buffer.asUint8List(), (ui.Image img) {
    completer.complete(img);
  });
  return completer.future;
}