// Import package
import 'dart:io';

import 'package:call_log/call_log.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:typed_data';

import 'package:kaist_summer_camp/model/contact_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class Util {
  static Future<List<ContactModel>> getContactInfoFromPhoneContact() async {
    // 권한 요청 처리
    PermissionStatus status = await Permission.contacts.status;
    if (!status.isGranted) {
      status = await Permission.contacts.request();
      if (!status.isGranted) {
        throw Exception('Contacts permission not granted');
      }
    }

    // 연락처 가져오기
    List<Contact> contacts;
    try {
      contacts = await ContactsService.getContacts();
    } catch (e) {
      throw Exception('Failed to get contacts: $e');
    }

    List<ContactModel> contactList = [];

    for (Contact contact in contacts) {
      String name = contact.displayName ?? '';
      if (name.trim().isEmpty) continue;

      if (contact.phones == null || contact.phones!.isEmpty) continue;
      String phone = contact.phones?.elementAt(0).value ?? '';
      if (phone.trim().isEmpty) continue;

      String? homeNumber;
      if (contact.phones!.length > 1) {
        homeNumber = contact.phones?.elementAt(1).value;
      }

      Uint8List? image = contact.avatar;

      if (contact.emails == null || contact.emails!.isEmpty) {
        String email = '';
        contactList.add(ContactModel(name: name, phone: phone, email: email, image: image, homeNumber: homeNumber));
        continue;

      }
      else {
        String email = contact.emails?.elementAt(0).value ?? '';
        contactList.add(ContactModel(name: name, phone: phone, email: email, image: image, homeNumber: homeNumber));
      }
    }
    return contactList;
  }

  static Future<void> addContactToPhoneContact(ContactModel contact) async {
    // 권한 요청 처리
    PermissionStatus status = await Permission.contacts.status;
    if (!status.isGranted) {
      status = await Permission.contacts.request();
      if (!status.isGranted) {
        throw Exception('Contacts permission not granted');
      }
    }

    // 연락처 추가
    Contact newContact = Contact(
      displayName: contact.name,
      phones: [Item(value: contact.phone)],
      emails: [Item(value: contact.email)],
      avatar: contact.image,
    );

    try {
      await ContactsService.addContact(newContact);
    } catch (e) {
      throw Exception('Failed to add contact: $e');
    }
  }

  static Future<List<ContactModel>> getRecentCallContacts(List<ContactModel> allContacts) async {
    List<CallLogEntry> _callLogs = [];

    if (await Permission.phone.request().isGranted &&
        await Permission.contacts.request().isGranted) {
      Iterable<CallLogEntry> entries = await CallLog.get();

      _callLogs = entries.toList();
    } else {
      // 권한이 거부된 경우 처리
      throw Exception('CallLog permission not granted');
    }

    List<ContactModel> recentCallContacts = [];
    int i = 0;

    for (CallLogEntry callLog in _callLogs) {
      if (i>4) {
        break;
      }

      print(callLog.name);
      if (callLog.name != null && callLog.name!.isNotEmpty) {
        if (recentCallContacts.any((contact) => contact.name == callLog.name)) continue;
        recentCallContacts.add(allContacts.firstWhere((contact) => contact.name == callLog.name));
        recentCallContacts.last.timeSinceLastCall = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(callLog.timestamp!));
        i++;
      }
    }

    recentCallContacts.addAll(allContacts.take(5 - recentCallContacts.length));
    for(ContactModel contact in recentCallContacts) {
      contact.timeSinceLastCall ??= Duration(days: 365);
    }

    return recentCallContacts;
  }


  static Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
    } else {
      throw 'Could not call';
    }
  }

  static Future<void> makePhoneSMS(String phoneNumber, {String body = ''}) async {
    final Uri launchUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: <String, String>{
        'body': Uri.encodeComponent(body),
      },
    );

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not sms';
    }
  }

  static Future<void> makeMail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
    );

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not sms';
    }
  }

  static Future<void> makeZoomMeet(String phoneNumber) async {
    final Uri launchUri = Uri.parse('https://zoom.us/j/$phoneNumber');

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not join to zoom meeting';
    }
  }

  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }


  static Future<String> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스 활성화 여부 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw "Location services are disabled.";
    }

    // 위치 권한 확인
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw "Location permissions are denied";
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw "Location permissions are permanently denied, we cannot request permissions.";
    }

    // 현재 위치 가져오기
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return "Lat: ${position.latitude}, Long: ${position.longitude}";
  }

  static String getFileDate(File file) {
    final lastModified = file.lastModifiedSync();
    final formattedDate = DateFormat('yyyy년 M월 d일 (E)', 'ko_KR').format(lastModified);
    return formattedDate;
  }
}

