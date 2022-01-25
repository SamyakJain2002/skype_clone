import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart';
import 'package:skype/enum/user_state.dart';
import 'package:skype/models/user.dart';
import 'package:skype/resources/auth_methods.dart';
import 'package:skype/utils/utils.dart';

class OnlineDotIndicator extends StatelessWidget {
  final String uid;
  final AuthMethods _authMethods = AuthMethods();

  OnlineDotIndicator({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    getColor(int state) {
      switch (Utils.numToState(state)) {
        case UserState.offline:
          return Colors.red;
        case UserState.online:
          return Colors.green;
        default:
          return Colors.orange;
      }
    }

    return StreamBuilder<DocumentSnapshot>(
        stream: _authMethods.getUserState(uid: uid),
        builder: (context, snapshot) {
          Userdetails? user;

          if (snapshot.hasData && snapshot.data!.data() != null) {
            user = Userdetails.fromMap(
                snapshot.data!.data() as Map<String, dynamic>);
          }

          return Container(
            height: 10,
            width: 10,
            margin: const EdgeInsets.only(right: 8, top: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: getColor(user?.state ?? 2),
            ),
          );
        });
  }
}
