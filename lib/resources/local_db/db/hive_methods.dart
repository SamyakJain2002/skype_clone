import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skype/models/log.dart';
import 'package:skype/resources/local_db/interface/log_interface.dart';

class HiveMethods implements LogInterface {
  String hive_box = 'Call Logs';

  @override
  init() async {
    Directory dir = await getApplicationDocumentsDirectory();

    Hive.init(dir.path);
  }

  @override
  addLogs(Log log) async {
    var box = await Hive.openBox(hive_box);

    var logMap = log.toMap(log);
    int idOfInput = await box.add(logMap);
    close();

    return idOfInput;
  }

  @override
  close() {
    return Hive.close();
  }

  @override
  deleteLogs(int logId) async {
    var box = await Hive.openBox(hive_box);

    await box.deleteAt(logId);
  }

  @override
  Future<List<Log>> getLogs() async {
    var box = await Hive.openBox(hive_box);

    List<Log> loglist = [];
    for (int i = 0; i < box.length; i++) {
      var logMap = box.get(i);
      loglist.add(Log.fromMap(logMap));
    }
    return loglist;
  }

  @override
  openDb(dbName) {
    hive_box = dbName;
  }
}
