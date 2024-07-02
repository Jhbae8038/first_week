import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:kaist_summer_camp/provider/memories_provider.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:kaist_summer_camp/provider/uiImage_provider.dart';

import '../model/memory_model.dart';

String _getFileDate(File file) {
  final lastModified = file.lastModifiedSync();
  final formattedDate = DateFormat('yyyy년 M월 d일 (E)', 'ko_KR').format(lastModified);
  return formattedDate;
}

class FreeScreen extends ConsumerStatefulWidget {
  const FreeScreen({super.key});

  @override
  _FreeScreenState createState() => _FreeScreenState();
}

class _FreeScreenState extends ConsumerState<FreeScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  double scrollPosition = double.infinity;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(_updateScrollPosition);
    initializeDateFormatting();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.removeListener(_updateScrollPosition);
    _scrollController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateScrollPosition() {
    scrollPosition = _scrollController.position.pixels;
  }

  void _showLargeImage(MemoryModel memory) {
    _titleController.text = memory.title;
    _descriptionController.text = memory.description;
    _titleController.clear();
    _descriptionController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
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
                    Spacer(flex:1),
                    Text(_getFileDate(File(memory.imagePath)) ?? 'Date not available'),
                    Spacer(flex:1),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        //ref.read(memoryProvider.notifier).deleteMemory(memory);
                        Navigator.of(context).pop();
                      },
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
                  child: TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: '제목',
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                      ),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    onChanged: (value) {
                      setState(() {
                        memory.title = value;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      hintText: '어떤 추억이 담겨 있나요?',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.withOpacity(0.6),

                      ),
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    onChanged: (value) {
                      memory.description = value;
                    },
                  ),
                ),
              ],
            ),
          ),
          ),

        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final memories = ref.watch(memoryProvider);
    final uiImages = ref.watch(uiImageProvider);

    return Scaffold(
        appBar: AppBar(
          title: Text('Memories'),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                await ref.read(memoryProvider.notifier).addMemory();
              },
            ),
          ],
        ),
        body: uiImages.when(
          data: (data) {

            if (_scrollController.hasClients && scrollPosition == double.infinity) {
              _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      Container(
                        width: 200,
                        height: memories.length * 100.0 + 100.0,
                        color: Colors.accents[0],
                        child: CustomPaint(
                          painter: TreePainter(memories, data,
                              onImageTap: (index) {
                            _showLargeImage(memories[index]);
                            ref.read(memoryProvider.notifier).saveMemory();
                          }),
                          child: Container(), // 제스처 인식을 위한 빈 Container 추가
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.15,
                        child: memories.isEmpty
                            ? Center(child: Text('No memories yet.'))
                            : Center(
                                child: Text(
                                  'Since\n xxxx.xx.xx',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          error: (error, stack) => Center(child: Text('Error: $error')),
          loading: () => Center(
            child: CircularProgressIndicator(),
          ),
        ));
  }
}


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

