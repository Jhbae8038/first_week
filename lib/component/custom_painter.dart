import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:kaist_summer_camp/model/memory_model.dart';

class TreePainter extends CustomPainter {
  final List<MemoryModel> memories;
  final List<ui.Image> images;
  final List<Rect> imageRects = [];
  final Function(int) onImageTap;

  TreePainter(this.memories, this.images, {required this.onImageTap});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke;

    final trunkHeight = size.height / 10;
    final trunkWidth = size.width / 20;

    // Draw the trunk
    canvas.drawLine(
      Offset(size.width / 2, size.height),
      Offset(size.width / 2, trunkHeight),
      paint,
    );

    double currentHeight = size.height - trunkHeight;
    final branchLength = size.width *0.4 - trunkWidth; //

    for (int i = 0; i < memories.length; i++) {
      final angle = (i % 2 == 0) ? math.pi / 4 : math.pi* 9 / 4;
      final dx = branchLength * math.cos(angle);
      final dy = branchLength * math.sin(angle);

      final startX = size.width / 2;
      final startY = currentHeight;
      final endX = startX + dx * (i % 2 == 0 ? 1 : -1);
      final endY = startY - dy;

      // Draw the branch
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );

      if (i < images.length) {
        final image = images[i];
        final imageRect = Rect.fromCenter(
          center: Offset(endX, endY),
          width: 60,
          height: 60,
        );

        imageRects.add(imageRect);

        canvas.drawImageRect(
          image,
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
          imageRect,
          Paint(),
        );
      }

      currentHeight -= branchLength / 2; // Adjust current height for better spacing
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
