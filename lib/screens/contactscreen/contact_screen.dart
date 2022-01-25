import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skype/models/contact.dart';
import 'package:skype/provider/user_provider.dart';
import 'package:skype/resources/chat_methods.dart';
import 'package:skype/screens/callscreens/pickup/pickup_layout.dart';
import 'package:skype/screens/pageviews/widgets/contact_view.dart';
import 'package:skype/screens/pageviews/widgets/quiet_box.dart';
import 'package:skype/widgets/skype_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactScreen extends StatelessWidget {
  ContactScreen({Key? key}) : super(key: key);
  final ChatMethods _chatMethods = ChatMethods();

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return PickupLayout(
        scaffold: Scaffold(
      appBar: SkypeAppBar(
        title: 'Contacts',
        actions: <Widget>[
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/search_screen');
              },
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              )),
        ],
      ),
      backgroundColor: Colors.black,
      body: StreamBuilder<QuerySnapshot>(
        stream: _chatMethods.fetchContacts(userId: userProvider.getUser!.uid!),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var docList = snapshot.data!.docs;
            if (docList.isEmpty) {
              return const QuietBox(
                  heading: 'This is where all the contacts are listed',
                  subtitle: '');
            }
            return ListView.builder(
              itemBuilder: (context, index) {
                Contact contact = Contact.fromMap(
                    docList[index].data() as Map<String, dynamic>);
                return ContactView(contact: contact, showtext: false);
              },
              itemCount: docList.length,
              padding: const EdgeInsets.all(10),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    ));
  }
}
