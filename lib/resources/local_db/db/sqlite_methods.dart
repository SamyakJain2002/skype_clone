import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skype/models/log.dart';
import 'package:skype/resources/local_db/interface/log_interface.dart';
import 'package:sqflite/sqflite.dart';

class SqliteMethods implements LogInterface {
  Database? _db;

  String databaseName = 'LogDB';
  String tableName = 'Call_Logs';

  String id = 'log_id';
  String callerName = 'caller_name';
  String callerPic = 'caller_pic';
  String receiverName = 'receiver_name';
  String receiverPic = 'receiver_pic';
  String callStatus = 'call_status';
  String timestamp = 'timestamp';

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await init();
    return _db!;
  }

  @override
  init() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, databaseName);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    String createTableQuery =
        'CREATE TABLE $tableName ($id INTEGER PRIMARY KEY, $callerName TEXT, $callerPic TEXT, $receiverName TEXT, $receiverPic TEXT, $callStatus TEXT, $timestamp TEXT)';
    await db.execute(createTableQuery);
    print('table created');
  }

  @override
  addLogs(Log log) async {
    var dbClient = await db;
    await dbClient.insert(tableName, log.toMap(log));
  }

  @override
  deleteLogs(int logId) async {
    var dbClient = await db;
    return await dbClient
        .delete(tableName, where: '$id =?', whereArgs: [logId + 1]);
  }

  @override
  Future<List<Log>> getLogs() async {
    try {
      var dbClient = await db;
      // List<Map> maps = await dbClient.rawquery('SELECT * FROM $tableName');
      List<Map> maps = await dbClient.query(
        tableName,
        columns: [
          id,
          callerName,
          callerPic,
          receiverName,
          receiverPic,
          callStatus,
          timestamp
        ],
      );
      List<Log> logList = [];
      if (maps.isNotEmpty) {
        for (Map map in maps) {
          logList.add(Log.fromMap(map));
        }
      }
      return logList;
    } catch (e) {
      print(e);
      return [];
    }
  }

  @override
  close() async {
    var dbClient = await db;
    dbClient.close();
  }

  @override
  openDb(dbName) {
    databaseName = dbName;
  }
}
