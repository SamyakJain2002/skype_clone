import 'package:skype/models/user.dart';
import 'package:skype/resources/auth_methods.dart';
import 'package:flutter/widgets.dart';

class UserProvider with ChangeNotifier {
  Userdetails? _user;
  AuthMethods _authMethods = AuthMethods();

  Userdetails? get getUser => _user;

  Future<void> refreshUser() async {
    Userdetails user = (await _authMethods.getUserDetails());
    _user = user;
    notifyListeners();
  }
}
