import 'package:flutter/material.dart';
import 'package:kaist_summer_camp/component/button_with_theme.dart';
import 'package:kaist_summer_camp/const/const.dart';
import 'package:kaist_summer_camp/model/contact_model.dart';
import 'package:kaist_summer_camp/util/util.dart';

class ContactDetailScreen extends StatelessWidget {
  final ContactModel contact;
  const ContactDetailScreen({required this.contact, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _Top(context),
            SizedBox(height: 8.0),
            Container(
              width: double.infinity,
              height: 24.0,
              color: SILVERCOLOR,
            ),
            _Bottom(context),
            SizedBox(height: 16.0)
          ],
        ),
      ),
    );
  }

  Widget _Top(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).padding.top,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ButtonWithTheme(
                  icon: Icons.arrow_back_ios_new,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  boxColor: Colors.white,
                  isBorder: true),
              ButtonWithTheme(
                icon: Icons.edit,
                onPressed: () {},
                boxColor: Colors.blue,
                isBorder: false,
                iconColor: Colors.white,
              ),
            ],
          ),
        ),
        SizedBox(height: 16.0),
        Container(
          width: MediaQuery.of(context).size.width * (7 / 24),
          height: MediaQuery.of(context).size.height * 0.16,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.0),
            child: contact.image != null && contact.image!.isNotEmpty
                ? Image.memory(
                    contact.image!,
                    fit: BoxFit.cover,
                  )
                : Image.asset('asset/default_profile.png'),
          ),
        ),
        SizedBox(height: 8.0),
        Text(
          contact.name,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 2.0),
        Text(
          contact.phone,
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.black,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ButtonWithTheme(
              icon: Icons.call_outlined,
              onPressed: () {
                Util.makePhoneCall(contact.phone);
              },
              boxColor: Colors.green,
              isBorder: false,
              iconColor: Colors.white,
              degreeOfRoundness: 12,
              iconSize: 42,
            ),
            SizedBox(width: 16.0),
            ButtonWithTheme(
              icon: Icons.message_outlined,
              onPressed: () {
                // 메시지 아이콘 클릭 시 액션
                Util.makePhoneSMS(contact.phone);
              },
              boxColor: Colors.blue,
              isBorder: false,
              iconColor: Colors.white,
              degreeOfRoundness: 12,
              iconSize: 42,
            ),
            SizedBox(width: 16.0),
            ButtonWithTheme(
              icon: Icons.videocam_outlined,
              onPressed: () {
                Util.makeZoomMeet(contact.phone);
              },
              boxColor: Colors.red,
              isBorder: false,
              iconColor: Colors.white,
              degreeOfRoundness: 12,
              iconSize: 42,
            ),
            SizedBox(width: 16.0),
            ButtonWithTheme(
              icon: Icons.email_outlined,
              onPressed: () {
                // 메일 아이콘 클릭 시 액션
                if (contact.email != null || contact.email!.isNotEmpty) Util.makeMail(contact.email!);
                else Util.showSnackBar(context, 'email is not available');
              },
              boxColor: Colors.grey,
              isBorder: false,
              iconColor: Colors.white,
              degreeOfRoundness: 12,
              iconSize: 42,
            ),
          ],
        ),
      ],
    );
  }

  Widget _Bottom(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            'Mobile',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            contact.phone,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
            IconButton(
              icon: Icon(Icons.message_outlined, color: Colors.grey.shade500),
              onPressed: () {
                // 메시지 아이콘 클릭 시 액션
                Util.makePhoneSMS(contact.phone);
              },
            ),
            IconButton(
              icon: Icon(Icons.phone, color: Colors.grey.shade500),
              onPressed: () {
                // 전화 아이콘 클릭 시 액션
                Util.makePhoneCall(contact.phone);
              },
            ),
          ]),
        ),
        ListTile(
          title: Text(
            'Home',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            contact.homeNumber ?? 'No home number',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
            IconButton(
              icon: Icon(Icons.message_outlined, color: Colors.grey.shade500),
              onPressed: () {
                // 메시지 아이콘 클릭 시 액션
                if (contact.homeNumber != null) {
                  Util.makePhoneSMS(contact.homeNumber!);
                } else {
                  Util.showSnackBar(context, 'home number is not available');
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.phone, color: Colors.grey.shade500),
              onPressed: () {
                // 전화 아이콘 클릭 시 액션
                if (contact.homeNumber != null) {
                  Util.makePhoneCall(contact.homeNumber!);
                } else {
                  Util.showSnackBar(context, 'home number is not available');
                }
              },
            ),
          ]),
        ),
        ListTile(
          title: Text(
            'e-Mail',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            contact.email == null || contact.email!.isEmpty
                ? 'No email'
                : contact.email!,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
            IconButton(
              icon: Icon(Icons.outgoing_mail, color: Colors.grey.shade500),
              onPressed: () {
                // 메시지 아이콘 클릭 시 액션
                if (contact.email != null || contact.email!.isNotEmpty) Util.makeMail(contact.email!);
                else Util.showSnackBar(context, 'email is not available');
              },
            ),
          ]),
        ),
        SizedBox(height: 32.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                ButtonWithTheme(
                  icon: Icons.location_on_outlined,
                  iconColor: Colors.white,
                  iconSize: 48.0,
                  onPressed: () async {
                    String myLocation = await Util.getCurrentLocation();
                    Util.makePhoneSMS(contact.phone, body: myLocation);
                  },
                  boxColor: Colors.deepPurple,
                ),
                Text('Share location', style: TextStyle(color: Colors.grey.shade700),)
              ],
            ),
            Column(
              children: [
                ButtonWithTheme(
                  icon: Icons.qr_code_2,
                  iconColor: Colors.black,
                  iconSize: 48.0,
                  onPressed: (){},
                  boxColor: Colors.grey.withOpacity(0.3),
                ),
                Text('Qr code', style: TextStyle(color: Colors.grey.shade700),)
              ],
            ),
            Column(
              children: [
                ButtonWithTheme(
                  icon: Icons.send,
                  iconColor: Colors.white,
                  iconSize: 48.0,
                  onPressed: (){},
                  boxColor: Colors.greenAccent,
                ),
                Text('Send Contact', style: TextStyle(color: Colors.grey.shade700),)
              ],
            ),
          ],
        ),
      ],
    );
  }
}
