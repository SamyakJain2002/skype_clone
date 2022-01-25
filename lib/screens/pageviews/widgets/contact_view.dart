import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skype/models/contact.dart';
import 'package:skype/models/user.dart';
import 'package:skype/provider/user_provider.dart';
import 'package:skype/resources/auth_methods.dart';
import 'package:skype/resources/chat_methods.dart';
import 'package:skype/screens/chatscreens/chat_screen.dart';
import 'package:skype/screens/pageviews/widgets/last_message_container.dart';
import 'package:skype/screens/pageviews/widgets/online_dot_indicator.dart';
import 'package:skype/utils/universal_variables.dart';
import 'package:skype/widgets/cached_image.dart';
import 'package:skype/widgets/customfile.dart';

class ContactView extends StatelessWidget {
  final Contact contact;
  final bool showtext;
  final AuthMethods _authMethods = AuthMethods();
  ContactView({Key? key, required this.contact, required this.showtext})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Userdetails?>(
      future: _authMethods.getUserDetailsById(contact.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Userdetails user = snapshot.data!;
          return ViewLayout(
            contact: user,
            showtext: showtext,
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class ViewLayout extends StatelessWidget {
  final Userdetails contact;
  final ChatMethods _chatMethods = ChatMethods();
  final bool showtext;

  ViewLayout({Key? key, required this.contact, required this.showtext})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return CustomTile(
      mini: false,
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChatScreen(receiver: contact))),
      onLongPress: () {},
      subtitle: (showtext)
          ? LastMessageContainer(
              stream: _chatMethods.fetchLastMessageBetween(
                  senderId: userProvider.getUser!.uid!,
                  receiverId: contact.uid!),
            )
          : Container(),
      icon: Container(),
      trailing: Container(),
      title: Text(
        contact.name ?? '..',
        style: const TextStyle(
          color: UniversalVariables.greyColor,
          fontSize: 14,
        ),
      ),
      leading: Container(
        constraints: const BoxConstraints(maxHeight: 60, maxWidth: 60),
        child: Stack(
          children: [
            CachedImage(
              imageurl: contact.profilePhoto!,
              radius: 80,
              isRound: true,
            ),
            (showtext) ? OnlineDotIndicator(uid: contact.uid!) : Container(),
          ],
        ),
      ),
    );
  }
}
