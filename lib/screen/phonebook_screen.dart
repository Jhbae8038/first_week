import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../model/contact_model.dart';
import '../util/util.dart';

class PhoneBookScreen extends StatefulWidget {
  const PhoneBookScreen({super.key});

  @override
  State<PhoneBookScreen> createState() => _PhoneBookScreenState();
}

class _PhoneBookScreenState extends State<PhoneBookScreen> {
  late Future<List<ContactModel>> contactList;

  @override
  void initState() {
    super.initState();
    contactList = Util.getContactInfoFromPhoneContact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phone Book'),
      ),
      body: FutureBuilder<List<ContactModel>>(
          future: contactList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // 로딩 중일 때 표시할 위젯
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // 오류 발생 시 표시할 위젯

              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              // 데이터가 없을 때 표시할 위젯
              return Center(child: Text('No contacts found'));
            } else {
              // 데이터가 로드되었을 때 표시할 위젯
              List<ContactModel> contacts = snapshot.data!;

              return SingleChildScrollView(
                  child: Column(
                children: [
                  ...List.generate(contacts.length, (index) {
                    final contact = contacts[index];
                    return ListTile(
                        onTap: () {},
                        title: Text(contact.name),
                        subtitle: Text(
                            contact.phone != '' ? contact.phone : 'No Phone'));
                  }),
                  ListTile(
                    leading: Icon(Icons.add),
                    onTap: () {},
                    title: Text('Add Contract'),
                  )
                ],
              ));
            }
          }),
    );
  }
}
