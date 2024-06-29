import 'package:flutter/material.dart';
import 'package:kaist_summer_camp/util/util.dart';

import '../model/contact_model.dart';

typedef OnContactTap = void Function(ContactModel contact);

class HorizontalContactsView extends StatefulWidget {
  final List<ContactModel> contacts;
  final OnContactTap onContactTap;

  const HorizontalContactsView({required this.contacts, required this.onContactTap,super.key});

  @override
  State<HorizontalContactsView> createState() => _HorizontalContactsViewState();
}

class _HorizontalContactsViewState extends State<HorizontalContactsView> {

  late Future<List<ContactModel>> recentContacts;

  @override
  void initState() {
    // TODO: implement initStat
    super.initState();
    recentContacts = Util.getRecentCallContacts(widget.contacts);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: recentContacts,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.2,
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.2,
              child: Center(child: Text('Error: ${snapshot.error}')),
            );
          }

          List<ContactModel> recentContacts = snapshot.data;
          return Ink(
            height: MediaQuery.of(context).size.height * 0.25,
            child: ListView.builder(
              itemBuilder: (_, index) => Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                child: InkWell(
                  radius: 50.0,
                  borderRadius: BorderRadius.circular(24.0),
                  onTap: (){
                    widget.onContactTap(recentContacts[index]);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * (7/24),
                        height: MediaQuery.of(context).size.height * 0.16,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24.0),
                          child: recentContacts[index].image != null && recentContacts[index].image!.isNotEmpty
                              ? Image.memory(
                            recentContacts[index].image!,
                            fit: BoxFit.cover,
                          )
                              : Container(color: Colors.green.withOpacity(1 -index / 5)),
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        recentContacts[index].name,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        recentContacts[index].timeSinceLastCall!.inMinutes < 60
                            ? '${recentContacts[index].timeSinceLastCall!.inMinutes} minutes ago'
                            : recentContacts[index].timeSinceLastCall!.inHours < 24 ? '${recentContacts[index].timeSinceLastCall!.inHours} hours ago'
                            : '${recentContacts[index].timeSinceLastCall!.inDays} days ago',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              scrollDirection: Axis.horizontal,
              itemCount: recentContacts.length,
            ),
          );
        });
  }
}
