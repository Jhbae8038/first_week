// Import package
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
}

