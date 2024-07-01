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
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final image = await _loadImage(File(pickedFile.path));
      setState(() {
        _memories.add(Memory(File(pickedFile.path), '', image));
      });
    }
  }

  Future<ui.Image> _loadImage(File file) async {
    final data = await file.readAsBytes();
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(Uint8List.view(data.buffer), (image) {
      completer.complete(image);
    });
    return completer.future;
  }

  void _editDescription(int index) {
    showDialog(
      context: context,
      builder: (context) {
        _descriptionController.text = _memories[index].description;
        return AlertDialog(
          title: Text('Edit Memory Description'),
          content: TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Memory Description',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _memories[index].description = _descriptionController.text;
                });
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showLargeImage(Memory memory) {
    _descriptionController.text = memory.description;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(//이미지를 눌렀을 때 이미지를 크게 보여주는 다이얼로그
          padding: EdgeInsets.only(//키보드가 올라오면 다이얼로그가 가려지는 것을 방지
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.file(memory.file),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(memory.description),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _editDescription(_memories.indexOf(memory));
                  },
                  child: Text('Edit Description'),
                ),
              ],
            ),
          ),
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
                  return ListTile(
                    leading: Image.file(memory.file),
                    title: Text(memory.description),
                    onTap: () => _editDescription(index),
                  );
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
  String description;
  Rect rect; // 이미지의 위치를 저장하는 Rect

  Memory(this.file, this.description, this.image) : rect = Rect.zero;
}
