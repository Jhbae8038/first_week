import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:kaist_summer_camp/model/memory_model.dart';

class TreePainter extends CustomPainter {
  final List<MemoryModel> memories;
  final List<ui.Image> images;
  final List<Rect> imageRects = [];
  final Function(int) onImageTap;
  final List<ui.Image> treeImages;

  TreePainter(this.memories, this.images,
      {required this.onImageTap, required this.treeImages});

  @override
  void paint(Canvas canvas, Size size) {
    final trunkWidth = size.width / 20;
    paintSmallTree(canvas, size);
  }

  void paintSmallTree(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 12.0
      ..style = PaintingStyle.stroke;

    final trunkHeight = 121.6;

    double currentBackgroundHeight = size.height - trunkHeight;

    for (int i = 0; i < memories.length; i++) {
      final startX = size.width / 2;

      final backgroundX = startX;
      final backgroundY = currentBackgroundHeight;

      currentBackgroundHeight -= (i == 0 ? 75 : 60);

      final photoX = startX +
          (i % 2 == 0 ? -1 : 1) * size.width * 0.3 +
          (i % 2 == 0 ? 1 : -1) * 5;
      final photoY = currentBackgroundHeight + (i==0 ? 5 : 0);

      final image = images[i];

      var backgroundImage;
      if (i==0) backgroundImage = treeImages[0];
      else if ((i ~/ 5)%4 ==0) backgroundImage = treeImages[7 + (i%2)];
      else backgroundImage = treeImages[((i ~/ 5)%4)*2 -1 +(i%2)];

        final backgroundRect = Rect.fromCenter(
        center: Offset(backgroundX, backgroundY),
        width: 85.8 * 4,
        height: 60.8 * 4,
      );


      final targetRect = Rect.fromCenter(
        center: Offset(photoX, photoY),
        width: 16.2 *5,
        height: 15.8 * 5,
      );

      // 원본 이미지의 비율을 계산합니다.
      final double imageAspectRatio = image.width / image.height;

      // 타겟 사각형의 비율을 계산합니다.
      final double targetAspectRatio = targetRect.width / targetRect.height;

      // 잘라낼 원본 이미지의 사각형을 계산합니다.
      Rect sourceRect;
      if (imageAspectRatio > targetAspectRatio) {
        // 이미지가 더 넓은 경우, 좌우를 잘라냅니다.
        final double cropWidth = image.height * targetAspectRatio;
        final double left = (image.width - cropWidth) / 2;
        sourceRect = Rect.fromLTWH(left, 0, cropWidth, image.height.toDouble());
      } else {
        // 이미지가 더 높은 경우, 위아래를 잘라냅니다.
        final double cropHeight = image.width / targetAspectRatio;
        final double top = (image.height - cropHeight) / 2;
        sourceRect = Rect.fromLTWH(0, top, image.width.toDouble(), cropHeight);
      }

      imageRects.add(targetRect);

      canvas.drawImageRect(
        backgroundImage,
        Rect.fromLTWH(0, 0, backgroundImage.width.toDouble(),
            backgroundImage.height.toDouble()),
        backgroundRect,
        Paint(),
      );

      canvas.drawImageRect(
        image,
        sourceRect,
        targetRect,
        Paint(),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  @override
  bool hitTest(Offset position) {
    for (int i = 0; i < imageRects.length; i++) {
      if (imageRects[i].contains(position)) {
        onImageTap(i);
        return true;
      }
    }
    return false;
  }
}
