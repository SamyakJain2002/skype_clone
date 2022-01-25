import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:skype/models/user.dart';
import 'package:skype/resources/auth_methods.dart';
import 'package:skype/screens/callscreens/pickup/pickup_layout.dart';
import 'package:skype/screens/chatscreens/chat_screen.dart';
import 'package:skype/utils/universal_variables.dart';
import 'package:skype/widgets/customfile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final AuthMethods _authMethods = AuthMethods();

  late List<Userdetails> userList;
  String query = '';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    User? user = _authMethods.getCurrentUser();
    if (user != null) {
      _authMethods.fetchAllUsers(user).then((List<Userdetails> list) {
        userList = list;
      });
    }
  }

  searchAppBar(BuildContext context) {
    return NewGradientAppBar(
      gradient: const LinearGradient(colors: [
        UniversalVariables.gradientColorStart,
        UniversalVariables.gradientColorEnd
      ]),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 20),
        child: TextField(
          controller: searchController,
          onChanged: (value) {
            setState(() {
              query = value;
            });
          },
          cursorColor: Colors.black,
          autofocus: true,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 35),
          decoration: InputDecoration(
              suffixIcon: IconButton(
                  onPressed: () {
                    searchController.clear();
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  )),
              border: InputBorder.none,
              hintText: 'Search',
              hintStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 35,
                color: Color(0x88ffffff),
              )),
        ),
      ),
    );
  }

  buildSuggestions(String query) {
    final Iterable<Userdetails> suggestionList = query.isEmpty
        ? []
        : userList.where((Userdetails user) {
            String _getUsername = user.username!.toLowerCase();
            String _query = query.toLowerCase();
            String _getName = user.name!.toLowerCase();
            bool matchesUsername = _getUsername.contains(_query);
            bool matchesName = _getName.contains(_query);
            return (matchesUsername || matchesName);
          }).toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: ((context, index) {
        Userdetails searchedUser = Userdetails(
            uid: suggestionList.elementAt(index).uid,
            state: suggestionList.elementAt(index).state,
            profilePhoto: suggestionList.elementAt(index).profilePhoto,
            name: suggestionList.elementAt(index).name,
            username: suggestionList.elementAt(index).username);

        return CustomTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(searchedUser.profilePhoto!),
              backgroundColor: Colors.grey,
            ),
            mini: false,
            title: Text(
              searchedUser.username!,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            icon: Container(),
            subtitle: Text(
              searchedUser.name!,
              style: const TextStyle(color: UniversalVariables.greyColor),
            ),
            trailing: Container(),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ChatScreen(receiver: searchedUser)));
            },
            onLongPress: () {});
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: Colors.black,
        appBar: searchAppBar(context),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: buildSuggestions(query),
        ),
      ),
    );
  }
}
