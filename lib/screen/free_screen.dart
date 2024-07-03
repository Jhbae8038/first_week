import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:kaist_summer_camp/component/custom_painter.dart';
import 'package:kaist_summer_camp/component/show_date_pikcer.dart';
import 'package:kaist_summer_camp/const/text_theme.dart';
import 'package:kaist_summer_camp/provider/memories_provider.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:kaist_summer_camp/provider/uiImage_provider.dart';
import 'package:kaist_summer_camp/util/util.dart';

import '../model/memory_model.dart';

class FreeScreen extends ConsumerStatefulWidget {
  const FreeScreen({super.key});

  @override
  _FreeScreenState createState() => _FreeScreenState();
}

class _FreeScreenState extends ConsumerState<FreeScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _descriptionFocusNode = FocusNode();

  String? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  double scrollPosition = double.infinity;
  DateTime? _selectedDate;

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
    _selectedDate = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: StatefulBuilder(

            builder: (BuildContext context, void Function(void Function()) setState) {
              return DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.75,
                builder: (context, scrollController) {
                  if (MediaQuery.of(context).viewInsets.bottom > 0) {
                    scrollController
                        .jumpTo(scrollController.position.maxScrollExtent);
                  }

                  return SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: Container(
                        padding: EdgeInsets.all(16.0),
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
                                Spacer(flex: 1),
                                GestureDetector(
                                  onTap: () {
                                    showCupertinoDatePicker(
                                        context: context,
                                        initialDateTime: DateTime.now(),
                                        onDateChanged: (DateTime date) {
                                          setState(() {
                                            _selectedDate = date;
                                          });
                                        });
                                  },
                                  child: Text(
                                    _selectedDate == null
                                        ? Util.getFileDate(File(memory.imagePath))
                                        : DateFormat('yyyy년 M월 d일 (E)', 'ko_KR')
                                        .format(_selectedDate!),
                                    style: diaryTextStyle(
                                      textSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Spacer(flex: 1),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    ref
                                        .read(memoryProvider.notifier)
                                        .deleteMemory(memory);
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
                                style: diaryTextStyle(
                                  textSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                controller: _titleController,
                                decoration: InputDecoration(
                                  hintText: '제목',
                                  hintStyle: diaryTextStyle(
                                    textSize: 16,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
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
                                  memory.title = value;
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                style: diaryTextStyle(
                                  textSize: 14,
                                ),
                                controller: _descriptionController,
                                decoration: InputDecoration(
                                  hintText: '어떤 추억이 담겨 있나요?',
                                  hintStyle: diaryTextStyle(
                                    textSize: 14,
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
                            SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  void _showDiaryEditor() {
    _titleController.clear();
    _descriptionController.clear();
    _selectedImage = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: StatefulBuilder(
            builder: (BuildContext context,
                void Function(void Function()) setState) {
              return DraggableScrollableSheet(
                initialChildSize: 0.8,
                minChildSize: 0.5,
                maxChildSize: 1.0,
                expand: false,
                builder: (context, scrollController) {
                  if (MediaQuery.of(context).viewInsets.bottom > 0) {
                    scrollController
                        .jumpTo(scrollController.position.maxScrollExtent);
                  }

                  return SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: Container(
                        padding: EdgeInsets.all(16.0),
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
                                Spacer(flex: 1),
                                Text(
                                  _selectedImage != null
                                      ? Util.getFileDate(File(_selectedImage!))
                                      : '',
                                  style: diaryTextStyle(
                                    textSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Spacer(flex: 1),
                                IconButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    if (_selectedImage == null) {
                                      return;
                                    }
                                    ref
                                        .read(memoryProvider.notifier)
                                        .addMemory(MemoryModel(
                                          imagePath: _selectedImage!,
                                          title: _titleController.text,
                                          description:
                                              _descriptionController.text,
                                          date: DateTime.now(),
                                        ));

                                    // Save the memory here if necessary
                                  },
                                  icon: Icon(Icons.check),
                                ),
                              ],
                            ),
                            if (_selectedImage != null)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: GestureDetector(
                                  onTap: () async {
                                    final pickedFile = await _picker.pickImage(
                                        source: ImageSource.gallery);
                                    _selectedImage = pickedFile!.path;
                                    setState(() {});
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: Image.file(
                                        File(_selectedImage!),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (_selectedImage == null)
                              GestureDetector(
                                onTap: () async {
                                  final pickedFile = await _picker.pickImage(
                                      source: ImageSource.gallery);
                                  _selectedImage = pickedFile!.path;
                                  setState(() {});
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 300,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.2),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.add_a_photo_outlined,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                style: diaryTextStyle(
                                  textSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                controller: _titleController,
                                decoration: InputDecoration(
                                  hintText: '제목',
                                  hintStyle: diaryTextStyle(
                                    fontWeight: FontWeight.bold,
                                    textSize: 16,
                                    color: Colors.grey,
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
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                style: diaryTextStyle(
                                  textSize: 14,
                                ),
                                controller: _descriptionController,
                                focusNode: _descriptionFocusNode,
                                decoration: InputDecoration(
                                  hintText: '어떤 추억이 담겨 있나요?',
                                  hintStyle: diaryTextStyle(
                                    textSize: 14,
                                    color: Colors.grey.withOpacity(0.6),
                                  ),
                                  border: InputBorder.none,
                                ),
                                maxLines: null,
                              ),
                            ),
                            SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final memories = ref.watch(memoryProvider);
    final uiImages = ref.watch(uiImageProvider);
    final uiBackground = ref.read(uiTreeImageProvider);

    return Scaffold(
        appBar: AppBar(
          title: Text('Memories',
              style: diaryTextStyle(
                textSize: 20.0,
                fontWeight: FontWeight.bold,
              )),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                _showDiaryEditor();
              },
            ),
          ],
        ),
        body: uiBackground.when(data: (uiBackground) {
          return uiImages.when(
            data: (data) {
              if (_scrollController.hasClients &&
                  scrollPosition == double.infinity) {
                _scrollController
                    .jumpTo(_scrollController.position.maxScrollExtent);
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: memories.length * 60.0 + 60.8 * 4,
                          child: CustomPaint(
                            painter: TreePainter(memories, data,
                                onImageTap: (index) {
                              _showLargeImage(memories[index]);
                              ref.read(memoryProvider.notifier).saveMemory();
                            }, treeImages: uiBackground),
                            child: Container(), // 제스처 인식을 위한 빈 Container 추가
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.15,
                          child: memories.isEmpty
                              ? Center(
                                  child: Text(
                                  '아직 저장된 추억이 없어요',
                                  style: diaryTextStyle(textSize: 16.0),
                                ))
                              : Center(
                                  child: Text(
                                    'Since\n ${DateFormat('yyyy.MM.dd').format(memories.first.date)}',
                                    textAlign: TextAlign.center,
                                    style: gbsTextStyle(textSize: 16.0),
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
          );
        }, error: (Object error, StackTrace stackTrace) {
          // 에러 발생 시
          return Center(
            child: Text('Error: $error'),
          );
        }, loading: () {
          // 로딩 중일 때
          return Center(
            child: CircularProgressIndicator(),
          );
        }));
  }
}
