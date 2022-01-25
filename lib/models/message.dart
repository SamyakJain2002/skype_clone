import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String? senderId;
  String? receiverId;
  String? type;
  String? message;
  Timestamp? timestamp;
  String? photoUrl;

  Message(
      {required this.senderId,
      required this.receiverId,
      required this.type,
      required this.message,
      required this.timestamp,
      this.photoUrl});

  Message.imageMessage(
      {required this.senderId,
      required this.receiverId,
      required this.message,
      required this.type,
      required this.timestamp,
      this.photoUrl});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['senderId'] = senderId;
    map['receiverId'] = receiverId;
    map['type'] = type;
    map['message'] = message;
    map['timestamp'] = timestamp;
    return map;
  }

  Map<String, dynamic> toImageMap() {
    var map = <String, dynamic>{};
    map['senderId'] = senderId;
    map['receiverId'] = receiverId;
    map['type'] = type;
    map['message'] = message;
    map['timestamp'] = timestamp;
    map['photoUrl'] = photoUrl;
    return map;
  }

  Message.fromMap(Map<String, dynamic> map) {
    senderId = map['senderId'];
    receiverId = map['receiverId'];
    type = map['type'];
    message = map['message'];
    timestamp = map['timestamp'];
    photoUrl = map['photoUrl'];
  }
}
