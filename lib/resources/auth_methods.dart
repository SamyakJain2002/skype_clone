import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:skype/constants/strings.dart';
import 'package:skype/enum/user_state.dart';
import 'package:skype/models/user.dart';
import 'package:skype/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthMethods {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static final CollectionReference _userCollection =
      _firestore.collection(kUsers_Collection);

  User? getCurrentUser() {
    User? currentUser;
    currentUser = _auth.currentUser;
    return currentUser;
  }

  Future<Userdetails> getUserDetails() async {
    User currentUser = getCurrentUser()!;
    DocumentSnapshot documentSnapshot =
        await _userCollection.doc(currentUser.uid).get();
    return Userdetails.fromMap(documentSnapshot.data() as Map<String, dynamic>);
  }

  Future<Userdetails?> getUserDetailsById(id) async {
    try {
      DocumentSnapshot documentSnapshot = await _userCollection.doc(id).get();
      return Userdetails.fromMap(
          documentSnapshot.data() as Map<String, dynamic>);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<User?> signIn() async {
    GoogleSignInAccount? _signInAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication _signInAuthentication =
        await _signInAccount!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: _signInAuthentication.accessToken,
      idToken: _signInAuthentication.idToken,
    );

    User? user = (await _auth.signInWithCredential(credential)).user;
    return user;
  }

  Future<bool> authenticateUser(User user) async {
    QuerySnapshot result = await _firestore
        .collection(kUsers_Collection)
        .where(kEmail_Field, isEqualTo: user.email)
        .get();

    final List<DocumentSnapshot> docs = result.docs;
    return (docs.isEmpty) ? true : false;
  }

  Future<void> addDatatoDb(User currentUser) async {
    String username = Utils.getUsername(currentUser.email!);

    Userdetails userdetails = Userdetails(
        uid: currentUser.uid,
        email: currentUser.email,
        name: currentUser.displayName,
        profilePhoto: currentUser.photoURL,
        username: username,
        state: 0);
    _firestore
        .collection(kUsers_Collection)
        .doc(currentUser.uid)
        .set(userdetails.toMap(userdetails));
  }

  Future<List<Userdetails>> fetchAllUsers(User currentUser) async {
    List<Userdetails> userList = [];

    QuerySnapshot querySnapshot =
        await _firestore.collection(kUsers_Collection).get();
    for (var i = 0; i < querySnapshot.docs.length; i++) {
      if (querySnapshot.docs[i].id != currentUser.uid) {
        userList.add(Userdetails.fromMap(
            querySnapshot.docs[i].data() as Map<String, dynamic>));
      }
    }
    return userList;
  }

  Future<bool> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }

  void setUserState({required String userId, required UserState userState}) {
    int stateNum = Utils.statetoNum(userState);
    _userCollection.doc(userId).update({'state': stateNum});
  }

  Stream<DocumentSnapshot> getUserState({required String uid}) =>
      _userCollection.doc(uid).snapshots();
}
