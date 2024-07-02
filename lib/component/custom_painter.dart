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

  void _drawBackground(Canvas canvas, Size size) {
    final paint = Paint();
    final double totalHeight = size.height;

    // 밤하늘
    final nightSkyRect = Rect.fromLTWH(0, 0, size.width, totalHeight * 0.25);
    paint.color = Color(0xFF001d3d);
    canvas.drawRect(nightSkyRect, paint);

    // 푸른 하늘
    final blueSkyRect =
        Rect.fromLTWH(0, totalHeight * 0.25, size.width, totalHeight * 0.25);
    paint.color = Color(0xFF87CEEB);
    canvas.drawRect(blueSkyRect, paint);

    // 노을
    final sunsetRect =
        Rect.fromLTWH(0, totalHeight * 0.5, size.width, totalHeight * 0.25);
    paint.color = Color(0xFFFF4500);
    canvas.drawRect(sunsetRect, paint);

    // 황금빛 들판
    final goldenFieldRect =
        Rect.fromLTWH(0, totalHeight * 0.75, size.width, totalHeight * 0.25);
    paint.color = Color(0xFFFFD700);
    canvas.drawRect(goldenFieldRect, paint);

    // 경계 혼재 영역 (블렌딩)
    final blendPaint = Paint();
    for (double y = 0; y < totalHeight; y += 1) {
      final blendRatio = (y % (totalHeight / 4)) / (totalHeight / 4);
      if (y < totalHeight * 0.25) {
        blendPaint.color =
            Color.lerp(Color(0xFF001d3d), Color(0xFF87CEEB), blendRatio)!;
      } else if (y < totalHeight * 0.5) {
        blendPaint.color =
            Color.lerp(Color(0xFF87CEEB), Color(0xFFFF4500), blendRatio)!;
      } else if (y < totalHeight * 0.75) {
        blendPaint.color =
            Color.lerp(Color(0xFFFF4500), Color(0xFFFFD700), blendRatio)!;
      }
      canvas.drawLine(Offset(0, y), Offset(size.width, y), blendPaint);
    }
  }

  void paintSmallTree(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 12.0
      ..style = PaintingStyle.stroke;

    final trunkHeight = size.height / 10;
    final branchLength = size.width / 10;

    double currentBackgroundHeight = size.height - trunkHeight;

    for (int i = 0; i < memories.length; i++) {
      final startX = size.width / 2;

      final backgroundX = startX;
      final backgroundY = currentBackgroundHeight;

      currentBackgroundHeight -= (i == 0 ? 75 : 60);

      final photoX = startX +
          (i % 2 == 0 ? -1 : 1) * size.width * 0.3 +
          (i % 2 == 0 ? 1 : -1) * 5;
      final photoY = currentBackgroundHeight;

      final image = images[i];

      var backgroundImage = treeImages[i % 8];
      if (i%8 ==0 && i !=0) backgroundImage = treeImages[8];

        final backgroundRect = Rect.fromCenter(
        center: Offset(backgroundX, backgroundY),
        width: 85.8 * 4,
        height: 60.8 * 4,
      );

      final imageRect = Rect.fromCenter(
        center: Offset(photoX, photoY),
        width: 80,
        height: 80,
      );

      imageRects.add(imageRect);

      canvas.drawImageRect(
        backgroundImage,
        Rect.fromLTWH(0, 0, backgroundImage.width.toDouble(),
            backgroundImage.height.toDouble()),
        backgroundRect,
        Paint(),
      );

      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        imageRect,
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
