import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:kaist_summer_camp/provider/memories_provider.dart';
import 'dart:async';
import 'package:flutter/services.dart';

import '../model/memory_model.dart';

class FreeScreen extends ConsumerStatefulWidget {
  const FreeScreen({super.key});

  @override
  _FreeScreenState createState() => _FreeScreenState();
}

class _FreeScreenState extends ConsumerState<FreeScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _showLargeImage(MemoryModel memory) {
    _titleController.text = memory.title;
    _descriptionController.text = memory.description;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Diary Title',
                          ),
                          maxLines: 1,
                          onChanged: (value) {
                            setState(() {
                              memory.title = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    width: double.infinity,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.file(
                        File(memory.imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(memory.date.toString() ?? 'Date not available'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Memory Description',
                    ),
                    maxLines: null,
                    onChanged: (value) {
                      setState(() {
                        memory.description = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final memories = ref.watch(memoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Memories'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async{
              await ref.read(memoryProvider.notifier).addMemory();
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: ref.read(memoryProvider.notifier).loadImageToUiImage(),
        builder: (_, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator());
          }
          if(snapshot.hasError){
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if(snapshot.data == null){
            return Center(child: Text('No memories yet.'));
          }

          List<ui.Image> images = snapshot.data!;

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: 200,
                    height: 400,
                    color: Colors.accents[0],
                    child: CustomPaint(
                      painter: TreePainter(memories, images, onImageTap: (index) {
                        _showLargeImage(memories[index]);
                        ref.read(memoryProvider.notifier).saveMemory();
                      }),
                      child: Container(), // 제스처 인식을 위한 빈 Container 추가
                    ),
                  ),
                  SizedBox(height: 20),
                  if(memories.isEmpty) Center(child: Text('No memories yet.'))
                ],
              ),
        ),
            ],
          );}
      ),
    );
  }
}


class TreePainter extends CustomPainter {
  final List<MemoryModel> memories;
  final List<ui.Image> images;
  final List<Rect> imageRects =[];
  final Function(int) onImageTap;

  TreePainter(this.memories, this.images, {required this.onImageTap});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final trunkHeight = size.height / 3;
    final trunkWidth = size.width / 10;

    canvas.drawLine(
      Offset(size.width / 2, size.height),
      Offset(size.width / 2, size.height - trunkHeight),
      paint,
    );

    double currentHeight = size.height - trunkHeight;
    for (int i = 0; i < memories.length; i++) {
      final angle = (i % 2 == 0) ? -0.5 : 0.5;
      final branchLength = trunkHeight / (memories.length + 1) * (i + 1);
      final dx = branchLength * math.sin(angle);
      final dy = branchLength * math.cos(angle);

      canvas.drawLine(
        Offset(size.width / 2, currentHeight),
        Offset(size.width / 2 + dx, currentHeight - dy),
        paint,
      );

      if (i < images.length) {
        final image = images[i];
        final imageRect = Rect.fromCenter(
          center: Offset(size.width / 2 + dx, currentHeight - dy),
          width: 30,
          height: 30,
        );

        imageRects.add(imageRect);

        canvas.drawImageRect(
          image,
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
          imageRect,
          Paint(),
        );
      }

      currentHeight -= dy / memories.length;
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

