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
    final trunkHeight = size.height / 10;
    final trunkWidth = size.width / 20;

    if(memories.length > 10){
      final branchLength = size.width *0.5 - trunkWidth;
      paintMiddleTree(canvas, size, trunkHeight: trunkHeight, trunkWidth: trunkWidth, branchLength: branchLength);
    }else {
      final branchLength = size.width *0.4 - trunkWidth;
      paintSmallTree(canvas, size, trunkHeight: trunkHeight, trunkWidth: trunkWidth, branchLength: branchLength);
    }


  }

  void paintMiddleTree(Canvas canvas, Size size, {required double trunkHeight,required double trunkWidth,required double branchLength}){
    final paint = Paint()
      ..color = Colors.brown
      ..strokeWidth = 16.0
      ..style = PaintingStyle.fill;

    final leafPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    // Draw the trunk with some texture
    final trunkPath = Path()
      ..moveTo(size.width / 2 - trunkWidth / 2, size.height)
      ..lineTo(size.width / 2 - trunkWidth / 2, trunkHeight)
      ..lineTo(size.width / 2 + trunkWidth / 2, trunkHeight)
      ..lineTo(size.width / 2 + trunkWidth / 2, size.height)
      ..close();
    canvas.drawPath(trunkPath, paint);

    double currentHeight = size.height - trunkHeight;

    for (int i = 0; i < memories.length; i++) {
      final angle = math.pi / 6;
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

      // Draw leaves at the end of branches
      final leafRect = Rect.fromCenter(
        center: Offset(endX, endY),
        width: 30,
        height: 30,
      );
      canvas.drawOval(leafRect, leafPaint);

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


  void paintSmallTree(Canvas canvas, Size size, {required double trunkHeight,required double trunkWidth,required double branchLength}){
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 12.0
      ..style = PaintingStyle.stroke;


    final paintStroke = Paint()
      ..color = Colors.green
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke;

    // Draw the trunk
    canvas.drawLine(
      Offset(size.width / 2, size.height),
      Offset(size.width / 2, size.height - trunkHeight - branchLength*(memories.length-1)/2 - trunkHeight),
      paint,
    );

    double currentHeight = size.height - trunkHeight;


    for (int i = 0; i < memories.length; i++) {
      final angle = math.pi / 4;
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
        paintStroke,
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