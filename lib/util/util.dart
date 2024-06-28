// Import package
import 'package:call_log/call_log.dart';
import 'package:contacts_service/contacts_service.dart';
import 'dart:typed_data';

import 'package:kaist_summer_camp/model/contact_model.dart';
import 'package:permission_handler/permission_handler.dart';

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

      Uint8List? image = contact.avatar;

      if (contact.emails == null || contact.emails!.isEmpty) {
        String email = '';
        contactList.add(ContactModel(name: name, phone: phone, email: email, image: image));
        continue;

      }
      else {
        String email = contact.emails?.elementAt(0).value ?? '';
        contactList.add(ContactModel(name: name, phone: phone, email: email, image: image));
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
}

