import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'dart:async';

class FreeScreen extends StatefulWidget {
  const FreeScreen({super.key});

  @override
  _FreeScreenState createState() => _FreeScreenState();
}

class _FreeScreenState extends State<FreeScreen> {
  final List<Memory> _memories = [];
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final image = await _loadImage(File(pickedFile.path));
      final date = _getFileDate(File(pickedFile.path));
      setState(() {
        _memories.add(Memory(File(pickedFile.path), '', image, date));
      });
    }
  }

  String _getFileDate(File file) {
    final lastModified = file.lastModifiedSync();
    return '${lastModified.year}-${lastModified.month}-${lastModified.day}';
  }

  Future<ui.Image> _loadImage(File file) async {
    final data = await file.readAsBytes();
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(Uint8List.view(data.buffer), (image) {
      completer.complete(image);
    });
    return completer.future;
  }

  void _showLargeImage(Memory memory) {
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
                        memory.file,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(memory.date ?? 'Date not available'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Memories'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _pickImage,
          ),
        ],
      ),
      body: GestureDetector(
        onTapUp: (details) {
          RenderBox box = context.findRenderObject() as RenderBox;
          Offset localOffset = box.globalToLocal(details.globalPosition);
          for (int i = 0; i < _memories.length; i++) {
            if (_memories[i].rect.contains(localOffset)) {
              _showLargeImage(_memories[i]);
              break;
            }
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: 200,
                height: 400,
                child: CustomPaint(
                  painter: TreePainter(_memories),
                  child: Container(), // 제스처 인식을 위한 빈 Container 추가
                ),
              ),

              SizedBox(height: 20),
              _memories.isEmpty
                  ? Center(child: Text('No memories yet.'))
                  : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _memories.length,
                itemBuilder: (context, index) {
                  final memory = _memories[index];
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TreePainter extends CustomPainter {
  final List<Memory> memories;

  TreePainter(this.memories);

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

      final image = memories[i].image;
      if (image != null) {
        final imageRect = Rect.fromCenter(
          center: Offset(size.width / 2 + dx, currentHeight - dy),
          width: 30,
          height: 30,
        );

        canvas.drawImageRect(
          image,
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
          imageRect,
          Paint(),
        );

        memories[i].rect = imageRect; // 이미지의 위치 저장
      }

      currentHeight -= dy / memories.length;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Memory {
  final File file;
  final ui.Image? image;
  String title = '';
  String description;
  String? date;
  Rect rect; // 이미지의 위치를 저장하는 Rect

  Memory(this.file, this.description, this.image, this.date) : rect = Rect.zero;
}
