import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kaist_summer_camp/model/memory_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../model/user_model.dart';

final hiveProvider = FutureProvider<HiveDB>((_) => HiveDB.create());

class HiveDB {
  var userBox;
  var galleryBox;
  var memoryBox;

  HiveDB._create() {}

  static Future<HiveDB> create() async {
    final component = HiveDB._create();
    await component._init();
    return component;
  }

  _init() async {
    Hive.registerAdapter<UserModel>(UserModelAdapter());

    var boxCollection = await BoxCollection.open(
      'userDB', // Name of your database
      {'user', 'gallery', 'memory'}, // Names of your boxes
      path: await getApplicationDocumentsDirectory().then((dir) => dir.path),
    );

    userBox =
        await boxCollection.openBox<UserModel>('user');
    galleryBox = await boxCollection.openBox<String>('gallery');
    memoryBox = await boxCollection.openBox<MemoryModel>('memory');

    await userBox.getAllKeys().then((value) {
      if (value.isEmpty) {
        userBox.put('owner' , UserModel(name: 'User', age: 0, imagePath: null));
      }
    });
  }
}


Future<void> _requestPermission() async {//권한 요청 함수
  PermissionStatus status = await Permission.photos.status;

  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt <= 32) {
      status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          throw Exception('Permission denied');
        }
        return;
      }
    }
  }

  if (!status.isGranted) {//사진 접근 권한이 없을 경우
    status = await Permission.photos.request();
    if (!status.isGranted) {//사진 접근 권한 요청
      throw Exception('Permission denied');
    }
  }
}