import 'package:flutter/material.dart';
import 'package:skype/constants/strings.dart';
import 'package:skype/models/log.dart';
import 'package:skype/resources/local_db/repository/log_repostiory.dart';
import 'package:skype/screens/pageviews/widgets/quiet_box.dart';
import 'package:skype/utils/utils.dart';
import 'package:skype/widgets/cached_image.dart';
import 'package:skype/widgets/customfile.dart';

class LogListContainer extends StatefulWidget {
  const LogListContainer({Key? key}) : super(key: key);

  @override
  _LogListContainerState createState() => _LogListContainerState();
}

class _LogListContainerState extends State<LogListContainer> {
  getIcon(String callStatus) {
    Icon _icon;
    double _iconSize = 15;
    switch (callStatus) {
      case kCall_status_dialled:
        _icon = Icon(
          Icons.call_made,
          size: _iconSize,
          color: Colors.green,
        );
        break;
      case kCall_status_missed:
        _icon = Icon(
          Icons.call_missed,
          color: Colors.red,
          size: _iconSize,
        );
        break;
      default:
        _icon = Icon(
          Icons.call_received,
          size: _iconSize,
          color: Colors.grey,
        );
    }
    return Container(
      margin: const EdgeInsets.only(right: 5),
      child: _icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: LogRepository.getLogs(),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasData) {
          List<dynamic> logList = snapshot.data;
          if (logList.isNotEmpty) {
            return ListView.builder(
              itemBuilder: (context, index) {
                Log _log = logList[index];
                bool hasDialled = _log.callStatus == kCall_status_dialled;
                return CustomTile(
                  leading: CachedImage(
                    imageurl: hasDialled ? _log.receiverPic! : _log.callerPic!,
                    isRound: true,
                    radius: 45,
                  ),
                  title: Text(
                    hasDialled ? _log.receiverName! : _log.callerName!,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  icon: getIcon(_log.callStatus!),
                  subtitle: Text(
                    Utils.formatDateString(_log.timestamp!),
                    style: const TextStyle(fontSize: 13),
                  ),
                  trailing: Container(),
                  onTap: () {},
                  onLongPress: () => showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: const Text('Delete this log'),
                            content: const Text(
                                'Are you sure you want to delete this log?'),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  Navigator.maybePop(context);
                                  await LogRepository.deleteLogs(index);
                                  if (mounted) {
                                    setState(() {});
                                  }
                                },
                                child: const Text('Yes'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.maybePop(context);
                                },
                                child: const Text('No'),
                              ),
                            ],
                          )),
                  mini: false,
                );
              },
              itemCount: logList.length,
            );
          }
          return const QuietBox(
            heading: 'This is where your call logs are listed',
            subtitle: 'Calling people all over the world with just one click',
          );
        }
        return const Text('No Call Logs');
      },
    );
  }
}
