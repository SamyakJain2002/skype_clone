import 'package:flutter/material.dart';
import 'package:skype/constants/strings.dart';
import 'package:skype/models/call.dart';
import 'package:skype/models/log.dart';
import 'package:skype/resources/call_methods.dart';
import 'package:skype/resources/local_db/repository/log_repostiory.dart';
import 'package:skype/screens/callscreens/call_screen.dart';
import 'package:skype/utils/permissions.dart';
import 'package:skype/widgets/cached_image.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class PickupScreen extends StatefulWidget {
  final Call call;

  const PickupScreen({Key? key, required this.call}) : super(key: key);

  @override
  State<PickupScreen> createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  final CallMethods callMethods = CallMethods();

  bool isCallMissed = true;

  addToLocalStorage({required String callStatus}) {
    Log log = Log(
        callerName: widget.call.callerName,
        callerPic: widget.call.callerPic,
        receiverName: widget.call.receiverName,
        receiverPic: widget.call.receiverPic,
        timestamp: DateTime.now().toString(),
        callStatus: callStatus);
    LogRepository.addLogs(log);
  }

  @override
  void initState() {
    super.initState();
    FlutterRingtonePlayer.play(
      android: AndroidSounds.notification,
      ios: IosSounds.glass,
      looping: true, // Android only - API >= 28
      volume: 0.1, // Android only - API >= 28
      asAlarm: false, // Android only - all APIs
    );
  }

  @override
  void dispose() {
    super.dispose();

    if (isCallMissed) {
      addToLocalStorage(callStatus: kCall_status_missed);
    }
    FlutterRingtonePlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Incoming...',
              style: TextStyle(fontSize: 30),
            ),
            const SizedBox(
              height: 50,
            ),
            CachedImage(
              imageurl: widget.call.callerPic!,
              isRound: true,
              radius: 180,
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              widget.call.callerName!,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 75,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () async {
                    isCallMissed = false;
                    addToLocalStorage(callStatus: kCall_status_received);
                    await callMethods.endCall(call: widget.call);
                  },
                  icon: const Icon(
                    Icons.call_end,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(
                  width: 25,
                ),
                IconButton(
                  onPressed: () async {
                    isCallMissed = false;
                    addToLocalStorage(callStatus: kCall_status_received);
                    await Permissions.cameraAndMicrophonePermissionsGranted()
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CallScreen(call: widget.call)))
                        : {};
                  },
                  icon: const Icon(Icons.call),
                  color: Colors.green,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
