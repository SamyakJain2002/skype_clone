import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skype/models/contact.dart';
import 'package:skype/provider/user_provider.dart';
import 'package:skype/resources/chat_methods.dart';
import 'package:skype/screens/callscreens/pickup/pickup_layout.dart';
import 'package:skype/screens/pageviews/widgets/contact_view.dart';
import 'package:skype/screens/pageviews/widgets/new_chat_button.dart';
import 'package:skype/screens/pageviews/widgets/quiet_box.dart';
import 'package:skype/screens/pageviews/widgets/user_circle.dart';
import 'package:skype/widgets/appbar.dart';
import 'package:skype/widgets/skype_appbar.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  CustomAppBar customAppBar(BuildContext context) {
    return CustomAppBar(
        title: const UserCircle(),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/search_screen');
            },
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
          ),
        ],
        leading: IconButton(
          icon: const Icon(
            Icons.notifications,
            color: Colors.white,
          ),
          onPressed: () {},
        ),
        centerTitle: true);
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: Colors.black,
        appBar: SkypeAppBar(
          title: const UserCircle(),
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/search_screen');
                },
                icon: const Icon(
                  Icons.search,
                  color: Colors.white,
                )),
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.white,
                )),
          ],
        ),
        floatingActionButton: const NewChatButton(),
        body: ChatListContainer(),
      ),
    );
  }
}

class ChatListContainer extends StatelessWidget {
  ChatListContainer({Key? key}) : super(key: key);
  final ChatMethods _chatMethods = ChatMethods();

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return StreamBuilder<QuerySnapshot>(
        stream: _chatMethods.fetchContacts(userId: userProvider.getUser!.uid!),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var docList = snapshot.data!.docs;

            if (docList.isEmpty) {
              return const QuietBox(
                heading: 'This is where all the contacts are listed',
                subtitle: 'Talk to anyone around the world',
              );
            }

            return ListView.builder(
              itemBuilder: (context, index) {
                Contact contact = Contact.fromMap(
                    docList[index].data() as Map<String, dynamic>);
                return ContactView(
                  contact: contact,
                  showtext: true,
                );
              },
              padding: const EdgeInsets.all(10),
              itemCount: docList.length,
            );
          }
          return const Center(child: CircularProgressIndicator());
        });
  }
}
