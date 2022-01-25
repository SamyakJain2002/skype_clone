import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skype/models/user.dart';
import 'package:skype/provider/user_provider.dart';
import 'package:skype/resources/auth_methods.dart';
import 'package:skype/screens/login_screen.dart';
import 'package:skype/screens/pageviews/widgets/shimmering_logo.dart';
import 'package:skype/widgets/cached_image.dart';
import 'package:skype/widgets/appbar.dart';

class UserDetailsContainer extends StatelessWidget {
  const UserDetailsContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    signOut() async {
      final bool isLoggedOut = await AuthMethods().signOut();
      if (isLoggedOut) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false);
      }
    }

    return Container(
      margin: const EdgeInsets.only(top: 25),
      child: Column(
        children: [
          CustomAppBar(
              title: const ShimmeringLogo(),
              actions: <Widget>[
                TextButton(
                    onPressed: () => signOut(),
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ))
              ],
              leading: IconButton(
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  )),
              centerTitle: true),
          const UserDetailsBody(),
        ],
      ),
    );
  }
}

class UserDetailsBody extends StatelessWidget {
  const UserDetailsBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final Userdetails user = userProvider.getUser!;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Row(
        children: [
          CachedImage(
            imageurl: user.profilePhoto!,
            isRound: true,
            radius: 50,
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name!,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                user.email!,
                style: const TextStyle(fontSize: 14, color: Colors.white),
              )
            ],
          )
        ],
      ),
    );
  }
}
