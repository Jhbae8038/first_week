import 'package:flutter/material.dart';
import 'package:kaist_summer_camp/const/const.dart';
import 'package:kaist_summer_camp/model/contact_model.dart';
import 'package:kaist_summer_camp/util/util.dart';

List<ContactModel> sortContacts(List<ContactModel> contacts) {
  contacts.sort((a, b) {
    final nameA = a.name.toLowerCase();
    final nameB = b.name.toLowerCase();

    final isKoreanA = _isKorean(nameA);
    final isKoreanB = _isKorean(nameB);
    final isAlphabetA = _isAlphabet(nameA);
    final isAlphabetB = _isAlphabet(nameB);
    final isDigitA = _isDigit(nameA);
    final isDigitB = _isDigit(nameB);

    if (isKoreanA && !isKoreanB) {
      return -1;
    } else if (!isKoreanA && isKoreanB) {
      return 1;
    } else if (isAlphabetA && !isAlphabetB) {
      return -1;
    } else if (!isAlphabetA && isAlphabetB) {
      return 1;
    } else if (isDigitA && !isDigitB) {
      return 1;
    } else if (!isDigitA && isDigitB) {
      return -1;
    } else {
      return nameA.compareTo(nameB);
    }
  });

  return contacts;
}

bool _isKorean(String text) {
  return RegExp(r'^[가-힣]').hasMatch(text);
}

bool _isAlphabet(String text) {
  return RegExp(r'^[a-zA-Z]').hasMatch(text);
}

bool _isDigit(String text) {
  return RegExp(r'^\d').hasMatch(text);
}

typedef OnContactTap = void Function(ContactModel contact);

class ContactScrollComponent extends StatefulWidget {
  final List<ContactModel> contactsToShow;
  final OnContactTap onContactTap;

  const ContactScrollComponent(
      {required this.contactsToShow, required this.onContactTap, super.key});

  @override
  State<ContactScrollComponent> createState() => _ContactScrollComponentState();
}

class _ContactScrollComponentState extends State<ContactScrollComponent> {
  @override
  Widget build(BuildContext context) {
    final totalContacts = widget.contactsToShow.length;

    final List<ContactModel> sortedContacts =
        sortContacts(widget.contactsToShow);

    final firstLetters = sortedContacts.fold([], (previousValue, element) {
      String firstLetter = element.name[0].toUpperCase();
      if (!previousValue.contains(firstLetter)) {
        previousValue.add(firstLetter);
      }
      return previousValue;
    });

    String firstLetter = '';

    return ListView.builder(
      itemCount: totalContacts,
      itemBuilder: (context, index) {
        if (index == 0) {
          firstLetter = sortedContacts[index].name[0];

          return Column(
            children: [
              Container(
                height: 24.0,
                color: SILVERCOLOR,
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                alignment: Alignment.centerLeft,
                child: Text(
                  firstLetter,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _commonTile(sortedContacts[index], index),
            ],
          );
        } else if (sortedContacts[index].name[0] != firstLetter) {
          firstLetter = sortedContacts[index].name[0];
          return Column(
            children: [
              Container(
                height: 24.0,
                color: SILVERCOLOR,
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                alignment: Alignment.centerLeft,
                child: Text(
                  firstLetter,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _commonTile(sortedContacts[index], index),
            ],
          );
        }

        return _commonTile(sortedContacts[index], index);
      },
    );
  }

  Widget _commonTile(ContactModel contact, int index) {
    return Dismissible(
      key: Key(index.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.green,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Icon(
          Icons.call,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (_) async {
        // 전화 걸기 기능
        Util.makePhoneCall(contact.phone);
        return false;
      },
      child: ListTile(
        onTap: () {
          widget.onContactTap(contact);
        },
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0), // 둥근 모서리 설정
          child: Container(
            width: 48.0, // ListTile의 높이에 맞게 설정
            height: 48.0,
            color: Colors.grey.shade300,
            child: contact.image != null && contact.image!.isNotEmpty
                ? Image.memory(
                    contact.image!,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    'asset/default_profile.png',
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        title: Text(contact.name),
        subtitle: Text(
          contact.phone != '' ? contact.phone : 'No Phone',
          style: TextStyle(color: Colors.grey.shade700),
        ),
      ),
    );
  }
}
