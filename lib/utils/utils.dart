import 'dart:io';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as Im;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skype/enum/user_state.dart';

class Utils {
  static String getUsername(String email) {
    return 'live:${email.split('@')[0]}';
  }

  static String getInitials(String name) {
    List<String> nameSplit = name.split(' ');
    String firstNameInitial = nameSplit[0][0];
    String lastNameInitial = nameSplit[1][0];
    return firstNameInitial + lastNameInitial;
  }

  static Future<File> pickImage(ImageSource source) async {
    File selectedImage =
        File((await ImagePicker().pickImage(source: source))!.path);
    return compressImage(selectedImage);
  }

  static Future<File> compressImage(File imagetoComapress) async {
    final tempdir = await getTemporaryDirectory();
    final path = tempdir.path;

    int random = Random().nextInt(1000);

    Im.Image image = Im.decodeImage(imagetoComapress.readAsBytesSync())!;
    Im.copyResize(image, width: 500, height: 500);
    return File('$path/img_$random.jpg')
      ..writeAsBytesSync(Im.encodeJpg(image, quality: 85));
  }

  static int statetoNum(UserState userState) {
    switch (userState) {
      case UserState.offline:
        return 0;
      case UserState.online:
        return 1;
      default:
        return 2;
    }
  }

  static UserState numToState(int number) {
    switch (number) {
      case 0:
        return UserState.offline;
      case 1:
        return UserState.online;
      default:
        return UserState.waiting;
    }
  }

  static String formatDateString(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    var formatter = DateFormat('dd/MM/yy');
    return formatter.format(dateTime);
  }
}
