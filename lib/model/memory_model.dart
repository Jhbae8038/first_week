
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'memory_model.g.dart';

@HiveType(typeId: 1)
class MemoryModel {
  @HiveField(0)
  final String imagePath;
  @HiveField(1)
  String description;
  @HiveField(2)
  DateTime date;
  @HiveField(3)
  String title;


  MemoryModel({required this.imagePath,required this.title, this.description = '', required this.date});
}
