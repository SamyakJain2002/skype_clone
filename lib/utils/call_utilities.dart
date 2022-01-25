import 'dart:math';

import 'package:flutter/material.dart';
import 'package:skype/constants/strings.dart';
import 'package:skype/models/call.dart';
import 'package:skype/models/log.dart';
import 'package:skype/models/user.dart';
import 'package:skype/resources/call_methods.dart';
import 'package:skype/resources/local_db/repository/log_repostiory.dart';
import 'package:skype/screens/callscreens/call_screen.dart';

class CallUtils {
  static final CallMethods callMethods = CallMethods();

  static dial(
      {required Userdetails from, required Userdetails to, context}) async {
    Call call = Call(
        callerId: from.uid,
        callerName: from.name,
        callerPic: from.profilePhoto,
        channelId: Random().nextInt(1000).toString(),
        receiverId: to.uid,
        receiverName: to.name,
        receiverPic: to.profilePhoto);

    Log log = Log(
        callerName: from.name,
        callerPic: from.profilePhoto,
        callStatus: kCall_status_dialled,
        receiverName: to.name,
        receiverPic: to.profilePhoto,
        timestamp: DateTime.now().toString());

    bool callMade = await callMethods.makeCall(call: call);
    call.hasDialled = true;
    if (callMade) {
      LogRepository.addLogs(log);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CallScreen(call: call),
          ));
    }
  }
}
