import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skype/constants/strings.dart';
import 'package:skype/models/contact.dart';
import 'package:skype/models/message.dart';
import 'package:skype/models/user.dart';

class ChatMethods {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final CollectionReference _messageCollection =
      _firestore.collection(kMessages_Collection);

  final CollectionReference _userCollection =
      _firestore.collection(kUsers_Collection);

  Future<void> addMessagetoDb(
      Message message, Userdetails sender, Userdetails receiver) async {
    Map<String, dynamic> map = message.toMap();
    await _messageCollection
        .doc(message.senderId)
        .collection(message.receiverId!)
        .add(map);

    addToContacts(senderId: message.senderId!, receiverId: message.receiverId!);

    await _messageCollection
        .doc(message.receiverId)
        .collection(message.senderId!)
        .add(map);
  }

  DocumentReference getContactsDocument(
          {required String of, required String forContact}) =>
      _userCollection.doc(of).collection(kContacts_Collection).doc(forContact);

  addToContacts({required String senderId, required String receiverId}) async {
    Timestamp currentTime = Timestamp.now();
    await addToSenderContact(senderId, receiverId, currentTime);
    await addToReceiverContact(senderId, receiverId, currentTime);
  }

  Future<void> addToSenderContact(
      String senderId, String receiverId, currentTime) async {
    DocumentSnapshot senderSnapshot =
        await getContactsDocument(of: senderId, forContact: receiverId).get();

    if (!senderSnapshot.exists) {
      Contact receiverContact = Contact(uid: receiverId, addedOn: currentTime);

      var receiverMap = receiverContact.toMap(receiverContact);

      await getContactsDocument(of: senderId, forContact: receiverId)
          .set(receiverMap);
    }
  }

  Future<void> addToReceiverContact(
      String senderId, String receiverId, currentTime) async {
    DocumentSnapshot receiverSnapshot =
        await getContactsDocument(of: receiverId, forContact: senderId).get();

    if (!receiverSnapshot.exists) {
      Contact senderContact = Contact(uid: senderId, addedOn: currentTime);

      var senderMap = senderContact.toMap(senderContact);

      await getContactsDocument(of: receiverId, forContact: senderId)
          .set(senderMap);
    }
  }

  void setImageMsg(String url, String receiverId, String senderId) async {
    Message _message;
    _message = Message.imageMessage(
        senderId: senderId,
        receiverId: receiverId,
        message: 'IMAGE',
        type: 'image',
        timestamp: Timestamp.now(),
        photoUrl: url);
    var map = _message.toImageMap();
    await _messageCollection
        .doc(_message.senderId)
        .collection(_message.receiverId!)
        .add(map);

    await _messageCollection
        .doc(_message.receiverId)
        .collection(_message.senderId!)
        .add(map);
  }

  Stream<QuerySnapshot> fetchContacts({required String userId}) =>
      _userCollection.doc(userId).collection(kContacts_Collection).snapshots();

  Stream<QuerySnapshot> fetchLastMessageBetween(
          {required String senderId, required String receiverId}) =>
      _messageCollection
          .doc(senderId)
          .collection(receiverId)
          .orderBy(kTimestamp_Field)
          .snapshots();
}
